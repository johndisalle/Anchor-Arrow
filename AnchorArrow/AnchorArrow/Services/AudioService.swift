// AudioService.swift
// Central audio engine for Anchor & Arrow.
//
// Responsibilities:
//   1. Resolve AudioAsset → playable URL (local cache first, then Firebase Storage)
//   2. Stream playback via AVPlayer with background audio session
//   3. Manage a queue for continuous play (scripture → prompt → prayer)
//   4. Publish playback state to SwiftUI views via @Published
//   5. Cache files on disk so each asset only downloads once per device
//
// Integration points:
//   - AnchorView/ArrowView tap "Play All" → .playQueue([scripture, prompt, prayer])
//   - JourneyView tap play on day card → .play(devotional)
//   - RootView overlays AudioPlayerBar whenever currentAsset != nil
//
// NOT included in this sketch for brevity:
//   - Remote Command Center integration (lock screen play/pause). Wire via
//     MPRemoteCommandCenter.shared() in configureSession().
//   - Now Playing Info Center updates (song title on lock screen).
//   - Silent-mode handling (AVAudioSession category .playback respects user
//     intent — audio plays even with ringer off, which is correct for devotionals).

import Foundation
import AVFoundation
import FirebaseStorage
import Combine

final class AudioService: ObservableObject {

    static let shared = AudioService()

    // MARK: - Published state (drives all UI)

    @Published private(set) var currentAsset: AudioAsset?
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var progress: Double = 0      // 0.0 - 1.0
    @Published private(set) var currentTime: Double = 0   // seconds
    @Published private(set) var duration: Double = 0      // seconds
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: String?
    @Published var playbackRate: Float = 1.0 { didSet { player?.rate = isPlaying ? playbackRate : 0 } }

    // MARK: - Queue (for continuous play)

    private var queue: [AudioAsset] = []
    private var queueIndex: Int = 0

    // MARK: - AVFoundation

    private var player: AVPlayer?
    private var timeObserver: Any?
    private var endObserver: NSObjectProtocol?

    // MARK: - Cache

    private let cacheDir: URL = {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("aa_audio", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    private init() {
        configureSession()
    }

    // MARK: - Public API

    /// Play a single asset. Replaces any currently playing queue.
    func play(_ asset: AudioAsset) {
        playQueue([asset])
    }

    /// Play a sequence of assets. Auto-advances on completion.
    /// This is what powers the continuous play experience:
    ///   playQueue([scriptureAsset, promptAsset, prayerAsset])
    func playQueue(_ assets: [AudioAsset]) {
        guard !assets.isEmpty else { return }
        queue = assets
        queueIndex = 0
        Task { await loadAndPlay(assets[0]) }
    }

    func togglePlayPause() {
        guard let player else { return }
        if isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.playImmediately(atRate: playbackRate)
            isPlaying = true
        }
    }

    func stop() {
        player?.pause()
        player = nil
        currentAsset = nil
        isPlaying = false
        progress = 0
        currentTime = 0
        duration = 0
        queue = []
        queueIndex = 0
        removeObservers()
    }

    func skip(seconds: Double) {
        guard let player else { return }
        let target = max(0, min(duration, currentTime + seconds))
        player.seek(to: CMTime(seconds: target, preferredTimescale: 600))
    }

    func seek(toProgress target: Double) {
        guard duration > 0 else { return }
        let t = max(0, min(1, target)) * duration
        player?.seek(to: CMTime(seconds: t, preferredTimescale: 600))
    }

    // MARK: - Load & play one asset

    @MainActor private func loadAndPlay(_ asset: AudioAsset) async {
        print("[Audio] loadAndPlay: \(asset.id) path=\(asset.storagePath)")
        currentAsset = asset
        isLoading = true
        error = nil
        progress = 0
        currentTime = 0
        duration = Double(asset.estimatedDurationSec)

        do {
            let url = try await resolveURL(for: asset)
            print("[Audio] resolved URL: \(url)")
            let item = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: item)
            player?.rate = playbackRate
            attachObservers(to: item)
            player?.playImmediately(atRate: playbackRate)
            isPlaying = true
            isLoading = false
            print("[Audio] playback started")
        } catch {
            print("[Audio] FAILED: \(asset.id) — \(error.localizedDescription)")
            self.error = "Couldn't load audio: \(error.localizedDescription)"
            isLoading = false
            isPlaying = false
            advanceQueue()
        }
    }

    // MARK: - URL resolution (cache, then Storage)

    private func resolveURL(for asset: AudioAsset) async throws -> URL {
        let local = cacheDir.appendingPathComponent("\(asset.id).mp3")
        if FileManager.default.fileExists(atPath: local.path) {
            return local
        }

        let ref = Storage.storage().reference(withPath: asset.storagePath)
        let downloadURL = try await ref.downloadURL()

        // Fire-and-forget download to local cache for next time.
        // We still return the remote URL so playback starts immediately (streaming).
        Task.detached(priority: .utility) {
            do {
                let (data, _) = try await URLSession.shared.data(from: downloadURL)
                try data.write(to: local)
            } catch {
                // Non-fatal — we'll just re-download next time.
                print("[Audio] Cache write failed: \(error)")
            }
        }
        return downloadURL
    }

    // MARK: - Queue advancement

    private func advanceQueue() {
        queueIndex += 1
        print("[Audio] advanceQueue: index=\(queueIndex) of \(queue.count)")
        if queueIndex < queue.count {
            Task { await loadAndPlay(queue[queueIndex]) }
        } else {
            print("[Audio] queue exhausted, stopping")
            stop()
        }
    }

    // MARK: - Observers

    private func attachObservers(to item: AVPlayerItem) {
        removeObservers()

        let interval = CMTime(seconds: 0.25, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self else { return }
            let seconds = time.seconds
            self.currentTime = seconds
            if let itemDuration = self.player?.currentItem?.duration.seconds,
               itemDuration.isFinite, itemDuration > 0 {
                self.duration = itemDuration
                self.progress = seconds / itemDuration
            }
        }

        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            DispatchQueue.main.async { self?.advanceQueue() }
        }
    }

    private func removeObservers() {
        if let t = timeObserver { player?.removeTimeObserver(t); timeObserver = nil }
        if let e = endObserver { NotificationCenter.default.removeObserver(e); endObserver = nil }
    }

    // MARK: - Audio session (background playback + lock screen)

    private func configureSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .spokenAudio, options: [])
            try session.setActive(true)
        } catch {
            print("[Audio] Session config failed: \(error)")
        }
    }
}
