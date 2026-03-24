// PremiumWelcomeView.swift
// Shown once after a user first subscribes to premium

import SwiftUI

struct PremiumWelcomeView: View {
    @Environment(\.dismiss) var dismiss
    @State private var appeared = false

    var body: some View {
        ZStack {
            Color("BackgroundPrimary").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {

                    Spacer(minLength: 20)

                    // Animated crown
                    ZStack {
                        // Outer glow
                        SwiftUI.Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color("BrandGold").opacity(0.25), Color.clear],
                                    center: .center,
                                    startRadius: 30,
                                    endRadius: 80
                                )
                            )
                            .frame(width: 160, height: 160)
                            .scaleEffect(appeared ? 1 : 0.6)
                            .opacity(appeared ? 1 : 0)

                        SwiftUI.Circle()
                            .fill(Color("BrandGold").opacity(0.12))
                            .frame(width: 100, height: 100)
                            .scaleEffect(appeared ? 1 : 0.5)

                        Image(systemName: "crown.fill")
                            .font(.system(size: 48))
                            .foregroundColor(Color("BrandGold"))
                            .scaleEffect(appeared ? 1 : 0.3)
                            .opacity(appeared ? 1 : 0)
                    }

                    // Welcome text
                    VStack(spacing: 10) {
                        Text("Welcome to Premium")
                            .font(.system(size: 30, weight: .heavy, design: .rounded))
                            .foregroundColor(Color("TextPrimary"))
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 12)

                        Text("Your subscription directly funds missions\nand service. Here's what's unlocked:")
                            .font(.system(size: 15))
                            .foregroundColor(Color("TextSecondary"))
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 12)
                    }

                    // Feature cards
                    VStack(spacing: 14) {
                        PremiumWelcomeCard(
                            icon: "map.fill",
                            iconColor: "BrandArrow",
                            title: "5 New Journeys",
                            description: "Armor of God, Surrender First, Prophet Priest King, Strength in Love, and Guard the Gates — 150 additional daily devotionals.",
                            delay: 0.15
                        )

                        PremiumWelcomeCard(
                            icon: "person.3.fill",
                            iconColor: "BrandAnchor",
                            title: "Full Circle Access",
                            description: "Create unlimited Iron Sharpeners circles. Post, comment, and rally your brothers.",
                            delay: 0.25
                        )

                        PremiumWelcomeCard(
                            icon: "book.fill",
                            iconColor: "BrandAnchor",
                            title: "Journal History",
                            description: "Browse and search your full reflection history. Revisit past entries and see how God has moved.",
                            delay: 0.35
                        )

                        PremiumWelcomeCard(
                            icon: "chart.bar.fill",
                            iconColor: "BrandWarning",
                            title: "Drift Insights & Weekly Report",
                            description: "See your drift patterns, weakest days, accountability streaks, and a weekly accountability summary.",
                            delay: 0.45
                        )

                        PremiumWelcomeCard(
                            icon: "tag.fill",
                            iconColor: "BrandWarning",
                            title: "Custom Drift Categories",
                            description: "Add your own drift categories beyond the defaults. Name your specific struggles for sharper accountability.",
                            delay: 0.55
                        )

                        PremiumWelcomeCard(
                            icon: "shield.fill",
                            iconColor: "BrandGold",
                            title: "Grace Day",
                            description: "Life happens. Save your streak once per month when you miss a day.",
                            delay: 0.65
                        )

                        PremiumWelcomeCard(
                            icon: "heart.fill",
                            iconColor: "BrandDanger",
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
                            .font(.system(size: 18, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [Color("BrandGold"), Color("BrandArrow")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 24)
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
    let iconColor: String
    let title: String
    let description: String
    let delay: Double

    @State private var visible = false

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(iconColor).opacity(0.12))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(iconColor))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color("TextPrimary"))

                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(Color("TextSecondary"))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(Color("CardBackground"))
        .cornerRadius(14)
        .opacity(visible ? 1 : 0)
        .offset(x: visible ? 0 : 30)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay)) {
                visible = true
            }
        }
    }
}
