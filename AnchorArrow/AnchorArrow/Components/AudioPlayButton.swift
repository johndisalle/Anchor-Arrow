// AudioPlayButton.swift
// A small amber circle button that drops onto scripture/prompt/prayer cards.
// Handles premium gating — free users see the button but tapping triggers upsell.

import SwiftUI

struct AudioPlayButton: View {
    let queue: [AudioAsset]
    var label: String? = nil

    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var storeKit: StoreKitManager
    @StateObject private var audio = AudioService.shared

    @State private var showPaywall = false

    private var isCurrent: Bool {
        guard let first = queue.first, let now = audio.currentAsset else { return false }
        return first.id == now.id
    }

    private var isActive: Bool {
        isCurrent && audio.isPlaying
    }

    var body: some View {
        Button(action: tap) {
            HStack(spacing: 8) {
                ZStack {
                    SwiftUI.Circle()
                        .fill(AATheme.amber)
                        .frame(width: 36, height: 36)

                    if audio.isLoading && isCurrent {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                    } else {
                        Image(systemName: isActive ? "pause.fill" : "play.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .offset(x: isActive ? 0 : 1)
                    }

                    if !storeKit.hasActiveSubscription {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(AATheme.amber)
                            .padding(3)
                            .background(SwiftUI.Circle().fill(Color.white))
                            .offset(x: 12, y: 12)
                    }
                }

                if let label {
                    Text(label)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(AATheme.steel)
                }
            }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showPaywall) {
            PremiumUpsellView(reason: "audio")
        }
    }

    private func tap() {
        guard storeKit.hasActiveSubscription else {
            AnalyticsService.log(.premiumUpsellViewed, params: ["trigger": "audio_play"])
            showPaywall = true
            return
        }
        if isCurrent {
            audio.togglePlayPause()
        } else {
            audio.playQueue(queue)
            AnalyticsService.log(.audioStarted, params: [
                "audio_kind": queue.first?.kind.rawValue ?? "",
                "queue_length": queue.count
            ])
        }
    }
}
