// AudioPlayerBar.swift
// Mini player that appears above the tab bar whenever audio is playing.
// Tap to expand to full-screen player. Swipe down to dismiss (stop playback).
//
// Mount in RootView as an overlay:
//
//   TabView { ... }
//     .overlay(alignment: .bottom) {
//         if AudioService.shared.currentAsset != nil {
//             AudioPlayerBar()
//                 .padding(.bottom, 50)  // clear tab bar
//                 .transition(.move(edge: .bottom).combined(with: .opacity))
//         }
//     }

import SwiftUI

struct AudioPlayerBar: View {
    @StateObject private var audio = AudioService.shared
    @State private var showFullPlayer = false

    var body: some View {
        if let asset = audio.currentAsset {
            Button { showFullPlayer = true } label: {
                HStack(spacing: 12) {
                    // Progress ring around play button
                    ZStack {
                        SwiftUI.Circle()
                            .stroke(AATheme.amber.opacity(0.25), lineWidth: 2)
                            .frame(width: 36, height: 36)
                        SwiftUI.Circle()
                            .trim(from: 0, to: CGFloat(audio.progress))
                            .stroke(AATheme.amber, style: .init(lineWidth: 2, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .frame(width: 36, height: 36)
                        Image(systemName: audio.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AATheme.amber)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(asset.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(AATheme.steel)
                            .lineLimit(1)
                        if let subtitle = asset.subtitle {
                            Text(subtitle)
                                .font(.caption)
                                .foregroundColor(AATheme.steel.opacity(0.7))
                                .lineLimit(1)
                        }
                    }

                    Spacer()

                    // Stop button
                    Button { audio.stop() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AATheme.steel.opacity(0.6))
                            .frame(width: 32, height: 32)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(AATheme.steel.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .onTapGesture { showFullPlayer = true }
            .sheet(isPresented: $showFullPlayer) { AudioFullPlayerView() }
        }
    }
}

// MARK: - Full-screen player

struct AudioFullPlayerView: View {
    @StateObject private var audio = AudioService.shared
    @Environment(\.dismiss) private var dismiss

    private var speedLabel: String {
        String(format: "%.2g×", audio.playbackRate)
    }

    var body: some View {
        VStack(spacing: 32) {
            // Drag handle
            Capsule()
                .fill(AATheme.steel.opacity(0.2))
                .frame(width: 40, height: 5)
                .padding(.top, 8)

            Spacer()

            // Anchor/arrow illustration or scripture card could go here.
            // For MVP: large title + subtitle.
            VStack(spacing: 12) {
                if let asset = audio.currentAsset {
                    Text(asset.title)
                        .font(.title2.weight(.semibold))
                        .foregroundColor(AATheme.steel)
                    if let s = asset.subtitle {
                        Text(s)
                            .font(.body)
                            .foregroundColor(AATheme.steel.opacity(0.7))
                    }
                }
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal)

            Spacer()

            // Scrubber
            VStack(spacing: 6) {
                Slider(
                    value: Binding(
                        get: { audio.progress },
                        set: { audio.seek(toProgress: $0) }
                    )
                )
                .tint(AATheme.amber)

                HStack {
                    Text(format(audio.currentTime))
                    Spacer()
                    Text(format(audio.duration))
                }
                .font(.caption.monospacedDigit())
                .foregroundColor(AATheme.steel.opacity(0.6))
            }
            .padding(.horizontal)

            // Transport
            HStack(spacing: 36) {
                Button { audio.skip(seconds: -15) } label: {
                    Image(systemName: "gobackward.15")
                        .font(.system(size: 28, weight: .regular))
                        .foregroundColor(AATheme.steel)
                }

                Button { audio.togglePlayPause() } label: {
                    ZStack {
                        SwiftUI.Circle().fill(AATheme.amber).frame(width: 68, height: 68)
                        Image(systemName: audio.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                Button { audio.skip(seconds: 15) } label: {
                    Image(systemName: "goforward.15")
                        .font(.system(size: 28, weight: .regular))
                        .foregroundColor(AATheme.steel)
                }
            }
            .padding(.vertical, 8)

            // Speed control
            Menu {
                ForEach([0.8, 1.0, 1.25, 1.5], id: \.self) { rate in
                    Button(String(format: "%.2g×", rate)) {
                        audio.playbackRate = Float(rate)
                    }
                }
            } label: {
                Text(speedLabel)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(AATheme.steel)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Capsule().stroke(AATheme.steel.opacity(0.3)))
            }

            Spacer()
        }
        .presentationDetents([.large])
        .background(AATheme.background.ignoresSafeArea())
    }

    private func format(_ seconds: Double) -> String {
        guard seconds.isFinite, seconds >= 0 else { return "0:00" }
        let s = Int(seconds)
        return String(format: "%d:%02d", s / 60, s % 60)
    }
}
