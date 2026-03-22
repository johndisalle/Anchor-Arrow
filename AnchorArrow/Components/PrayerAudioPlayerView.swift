// PrayerAudioPlayerView.swift
// Audio prayer player using AVFoundation

import SwiftUI
import Combine
import AVFoundation

// MARK: - PrayerAudioPlayerView (Sheet)
struct PrayerAudioPlayerView: View {
    let title: String
    let fileName: String
    let prayerText: String

    @StateObject private var player = AudioPlayerManager()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 28) {
            // Drag indicator
            Capsule()
                .fill(Color("TextSecondary").opacity(0.3))
                .frame(width: 36, height: 4)
                .padding(.top, 12)

            // Icon
            ZStack {
                SwiftUI.Circle()
                    .fill(Color("BrandAnchor").opacity(0.1))
                    .frame(width: 90, height: 90)

                Image(systemName: player.isPlaying ? "waveform.circle.fill" : "play.circle.fill")
                    .font(.system(size: 52))
                    .foregroundColor(Color("BrandAnchor"))
                    .symbolEffect(.bounce, value: player.isPlaying)
            }

            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundColor(Color("TextPrimary"))

                if player.duration > 0 {
                    Text(timeString(player.duration))
                        .font(.system(size: 14))
                        .foregroundColor(Color("TextSecondary"))
                }
            }

            // Progress bar
            if player.duration > 0 {
                VStack(spacing: 8) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color("TextSecondary").opacity(0.2))
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color("BrandAnchor"))
                                .frame(
                                    width: geo.size.width * CGFloat(player.currentTime / player.duration),
                                    height: 6
                                )
                                .animation(.linear(duration: 0.1), value: player.currentTime)
                        }
                    }
                    .frame(height: 6)
                    .padding(.horizontal, 32)

                    HStack {
                        Text(timeString(player.currentTime))
                        Spacer()
                        Text(timeString(player.duration))
                    }
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color("TextSecondary"))
                    .padding(.horizontal, 32)
                }
            }

            // Controls
            HStack(spacing: 40) {
                Button {
                    player.skipBack()
                } label: {
                    Image(systemName: "gobackward.10")
                        .font(.system(size: 28))
                        .foregroundColor(Color("TextSecondary"))
                }

                Button {
                    player.isPlaying ? player.pause() : player.play()
                } label: {
                    ZStack {
                        SwiftUI.Circle()
                            .fill(Color("BrandAnchor"))
                            .frame(width: 64, height: 64)
                        Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                Button {
                    player.skipForward()
                } label: {
                    Image(systemName: "goforward.10")
                        .font(.system(size: 28))
                        .foregroundColor(Color("TextSecondary"))
                }
            }

            // Prayer text (always visible as fallback)
            VStack(alignment: .leading, spacing: 10) {
                Text("Prayer Text")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("TextSecondary"))

                ScrollView {
                    Text(prayerText)
                        .font(.system(size: 15, weight: .medium, design: .serif))
                        .italic()
                        .foregroundColor(Color("TextPrimary"))
                        .lineSpacing(6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 140)
            }
            .padding(16)
            .background(Color("CardBackground"))
            .cornerRadius(14)
            .padding(.horizontal, 24)

            // File notice
            if player.fileNotFound {
                Text("⚠ Audio file '\(fileName).mp3' not yet added to project.\nRefer to SETUP.md for audio file placement instructions.")
                    .font(.system(size: 12))
                    .foregroundColor(Color("BrandWarning"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button("Close") { dismiss() }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color("BrandAnchor"))
                .padding(.bottom, 20)
        }
        .background(Color("BackgroundPrimary"))
        .presentationDetents([.large])
        .onAppear { player.load(fileName: fileName) }
        .onDisappear { player.stop() }
    }

    private func timeString(_ seconds: Double) -> String {
        let s = Int(seconds)
        return String(format: "%d:%02d", s / 60, s % 60)
    }
}

// MARK: - AudioPlayerManager
@MainActor
class AudioPlayerManager: NSObject, ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var fileNotFound = false

    private var player: AVAudioPlayer?
    private var timer: Timer?

    func load(fileName: String) {
        // Look for .mp3 file in app bundle
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            // Try .m4a as fallback
            guard let m4aUrl = Bundle.main.url(forResource: fileName, withExtension: "m4a") else {
                fileNotFound = true
                return
            }
            setupPlayer(url: m4aUrl)
            return
        }
        setupPlayer(url: url)
    }

    private func setupPlayer(url: URL) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.prepareToPlay()
            duration = player?.duration ?? 0
            fileNotFound = false
            // Auto-play when loaded
            play()
        } catch {
            fileNotFound = true
        }
    }

    func play() {
        player?.play()
        isPlaying = true
        startTimer()
    }

    func pause() {
        player?.pause()
        isPlaying = false
        stopTimer()
    }

    func stop() {
        player?.stop()
        player?.currentTime = 0
        isPlaying = false
        stopTimer()
        currentTime = 0
    }

    func skipBack() {
        guard let player else { return }
        player.currentTime = max(0, player.currentTime - 10)
        currentTime = player.currentTime
    }

    func skipForward() {
        guard let player else { return }
        player.currentTime = min(player.duration, player.currentTime + 10)
        currentTime = player.currentTime
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.currentTime = self?.player?.currentTime ?? 0
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - AVAudioPlayerDelegate
extension AudioPlayerManager: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            isPlaying = false
            currentTime = 0
            stopTimer()
        }
    }
}
