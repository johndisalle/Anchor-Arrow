// PremiumWelcomeView.swift
// Shown once after a user first subscribes to premium

import SwiftUI

struct PremiumWelcomeView: View {
    @Environment(\.dismiss) var dismiss
    @State private var appeared = false

    var body: some View {
        ZStack {
            AATheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: AATheme.paddingXLarge) {

                    Spacer(minLength: 20)

                    // Animated crown
                    ZStack {
                        // Outer glow
                        SwiftUI.Circle()
                            .fill(
                                RadialGradient(
                                    colors: [AATheme.warmGold.opacity(0.25), Color.clear],
                                    center: .center,
                                    startRadius: 30,
                                    endRadius: 80
                                )
                            )
                            .frame(width: 160, height: 160)
                            .scaleEffect(appeared ? 1 : 0.6)
                            .opacity(appeared ? 1 : 0)

                        SwiftUI.Circle()
                            .fill(AATheme.warmGold.opacity(0.12))
                            .frame(width: 100, height: 100)
                            .scaleEffect(appeared ? 1 : 0.5)

                        Image(systemName: "crown.fill")
                            .font(.system(size: 48))
                            .foregroundColor(AATheme.warmGold)
                            .scaleEffect(appeared ? 1 : 0.3)
                            .opacity(appeared ? 1 : 0)
                    }

                    // Welcome text
                    VStack(spacing: 10) {
                        Text("Welcome to Premium")
                            .font(AATheme.titleFont)
                            .foregroundColor(AATheme.primaryText)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 12)

                        Text("Your subscription directly funds missions\nand service. Here's what's unlocked:")
                            .font(.system(size: 15))
                            .foregroundColor(AATheme.secondaryText)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 12)
                    }

                    // Feature cards
                    VStack(spacing: 14) {
                        PremiumWelcomeCard(
                            icon: "map.fill",
                            iconColor: AATheme.amber,
                            title: "5 New Journeys",
                            description: "Armor of God, Surrender First, Prophet Priest King, Strength in Love, and Guard the Gates — 150 additional daily devotionals.",
                            delay: 0.15
                        )

                        PremiumWelcomeCard(
                            icon: "person.3.fill",
                            iconColor: AATheme.steel,
                            title: "Full Circle Access",
                            description: "Create unlimited Iron Sharpeners circles. Post, comment, and rally your brothers.",
                            delay: 0.25
                        )

                        PremiumWelcomeCard(
                            icon: "book.fill",
                            iconColor: AATheme.steel,
                            title: "Journal History",
                            description: "Browse and search your full reflection history. Revisit past entries and see how God has moved.",
                            delay: 0.35
                        )

                        PremiumWelcomeCard(
                            icon: "chart.bar.fill",
                            iconColor: AATheme.warning,
                            title: "Drift Insights & Weekly Report",
                            description: "See your drift patterns, weakest days, accountability streaks, and a weekly accountability summary.",
                            delay: 0.45
                        )

                        PremiumWelcomeCard(
                            icon: "tag.fill",
                            iconColor: AATheme.warning,
                            title: "Custom Drift Categories",
                            description: "Add your own drift categories beyond the defaults. Name your specific struggles for sharper accountability.",
                            delay: 0.55
                        )

                        PremiumWelcomeCard(
                            icon: "shield.fill",
                            iconColor: AATheme.warmGold,
                            title: "Grace Day",
                            description: "Life happens. Save your streak once per month when you miss a day.",
                            delay: 0.65
                        )

                        PremiumWelcomeCard(
                            icon: "heart.fill",
                            iconColor: AATheme.destructive,
                            title: "Kingdom Funded",
                            description: "All profits go to missions and service. Your subscription makes a difference beyond this app.",
                            delay: 0.75
                        )
                    }
                    .padding(.horizontal, 20)

                    // CTA
                    Button {
                        dismiss()
                    } label: {
                        Text("Let's Go")
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                    }
                    .buttonStyle(AAPremiumButtonStyle())
                    .padding(.horizontal, AATheme.paddingLarge)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)

                    Spacer(minLength: 30)
                }
            }
        }
        .interactiveDismissDisabled()
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.1)) {
                appeared = true
            }
        }
    }
}

// MARK: - PremiumWelcomeCard
private struct PremiumWelcomeCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let delay: Double

    @State private var visible = false

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: AATheme.cornerRadiusSmall)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 40, height: 40)

                AAIcon(icon, size: 18, color: iconColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .serif))
                    .foregroundColor(AATheme.primaryText)

                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(AATheme.secondaryText)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(AATheme.cardBackground)
        .cornerRadius(AATheme.cornerRadius)
        .shadow(color: AATheme.cardShadow, radius: AATheme.cardShadowRadius, x: 0, y: 2)
        .opacity(visible ? 1 : 0)
        .offset(x: visible ? 0 : 30)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay)) {
                visible = true
            }
        }
    }
}
