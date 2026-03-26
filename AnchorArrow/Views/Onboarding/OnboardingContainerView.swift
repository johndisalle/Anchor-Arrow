// OnboardingContainerView.swift
// Manages the 4-step onboarding flow

import SwiftUI

struct OnboardingContainerView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userStore: UserStore
    @State private var currentPage = 0
    @State private var showAuth = false
    @State private var isSignUp = true

    var body: some View {
        ZStack {
            AATheme.background.ignoresSafeArea()

            if showAuth {
                AuthView(isSignUp: $isSignUp)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
            } else {
                VStack(spacing: 0) {
                    // Page content
                    TabView(selection: $currentPage) {
                        OnboardingPage1()
                            .tag(0)
                        OnboardingPage2()
                            .tag(1)
                        OnboardingPage3()
                            .tag(2)
                        OnboardingPage4(onGetStarted: {
                            withAnimation(.spring()) { showAuth = true }
                        })
                        .tag(3)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut, value: currentPage)

                    // Bottom controls
                    VStack(spacing: 16) {
                        // Page indicators
                        HStack(spacing: 8) {
                            ForEach(0..<4) { i in
                                Capsule()
                                    .fill(i == currentPage ? AATheme.steel : AATheme.secondaryText.opacity(0.3))
                                    .frame(width: i == currentPage ? 24 : 8, height: 8)
                                    .animation(.spring(response: 0.3), value: currentPage)
                            }
                        }

                        if currentPage < 3 {
                            Button {
                                withAnimation { currentPage += 1 }
                            } label: {
                                HStack {
                                    Text("Continue")
                                    Image(systemName: "arrow.right")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(AAPrimaryButtonStyle())
                            .padding(.horizontal, 32)

                            if currentPage == 0 {
                                Button("Already have an account? Sign In") {
                                    isSignUp = false
                                    withAnimation(.spring()) { showAuth = true }
                                }
                                .font(.system(size: 14))
                                .foregroundColor(AATheme.secondaryText)
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

// MARK: - Onboarding Page 1 — Welcome
struct OnboardingPage1: View {
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Brand mark hero — same composition as splash screen
            ZStack {
                // Subtle atmospheric glow (no ring border — it clipped the arrows)
                SwiftUI.Circle()
                    .fill(
                        RadialGradient(
                            colors: [AATheme.steel.opacity(0.11), Color.clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 148
                        )
                    )
                    .frame(width: 296, height: 296)
                    .opacity(appeared ? 1.0 : 0)
                    .animation(.easeOut(duration: 1.0).delay(0.2), value: appeared)

                VStack(spacing: -30) {
                    CrossedArrowsView()
                        .frame(width: 196, height: 122)
                        .scaleEffect(appeared ? 1.0 : 0.1)
                        .opacity(appeared ? 1.0 : 0)
                        .animation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.85), value: appeared)

                    AnchorSymbolView()
                        .frame(width: 158, height: 198)
                        .opacity(appeared ? 1.0 : 0)
                        .animation(.easeOut(duration: 0.7).delay(0.15), value: appeared)
                }
            }

            Spacer().frame(height: 44)

            VStack(spacing: 16) {
                Text("Welcome, Brother.")
                    .font(AATheme.titleFont)
                    .foregroundColor(AATheme.primaryText)

                Text("Anchor & Arrow is a daily habit journal built for men who are done drifting and ready to stand firm in Christ.")
                    .font(.system(size: 17))
                    .foregroundColor(AATheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
            }
            .opacity(appeared ? 1.0 : 0.0)
            .offset(y: appeared ? 0 : 20)
            .animation(.easeOut(duration: 0.5).delay(0.4), value: appeared)

            Spacer()
            Spacer()
        }
        .onAppear { appeared = true }
        .onDisappear { appeared = false }
    }
}

// MARK: - Onboarding Page 2 — The Concept
struct OnboardingPage2: View {
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            VStack(spacing: 6) {
                Text("One verse. Two callings.")
                    .font(AATheme.headlineFont)
                    .foregroundColor(AATheme.primaryText)
            }
            .opacity(appeared ? 1.0 : 0.0)
            .animation(.easeOut(duration: 0.4).delay(0.1), value: appeared)

            // Scripture card
            VStack(spacing: 12) {
                Text("\"Be watchful, stand firm in the faith, act like men, be strong. Let all that you do be done in love.\"")
                    .font(.system(size: 18, weight: .medium, design: .serif))
                    .italic()
                    .foregroundColor(AATheme.primaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)

                Text("— 1 Corinthians 16:13-14")
                    .font(.system(size: 14, weight: .semibold, design: .serif))
                    .foregroundColor(AATheme.steel)
            }
            .aaCard()
            .shadow(color: AATheme.cardShadow, radius: AATheme.cardShadowRadius, x: 0, y: 2)
            .padding(.horizontal, AATheme.paddingLarge)
            .opacity(appeared ? 1.0 : 0.0)
            .offset(y: appeared ? 0 : 16)
            .animation(.easeOut(duration: 0.5).delay(0.2), value: appeared)

            // Two concepts
            HStack(spacing: 16) {
                ConceptCard(color: AATheme.steel,
                            title: "The Anchor",
                            description: "Be watchful. Stand firm. Root yourself in Christ daily.") {
                    AnchorSymbolView()
                        .frame(width: 28, height: 35)
                }
                ConceptCard(color: AATheme.amber,
                            title: "The Arrow",
                            description: "Act like men. Be strong in love. Pursue God's purpose.") {
                    SingleArcheryArrowView(color: AATheme.amber)
                        .frame(width: 26, height: 26)
                }
            }
            .padding(.horizontal, AATheme.paddingLarge)
            .opacity(appeared ? 1.0 : 0.0)
            .offset(y: appeared ? 0 : 16)
            .animation(.easeOut(duration: 0.5).delay(0.35), value: appeared)

            Spacer()
            Spacer()
        }
        .onAppear { appeared = true }
        .onDisappear { appeared = false }
    }
}


struct ConceptCard<Icon: View>: View {
    let color: Color
    let title: String
    let description: String
    @ViewBuilder let icon: () -> Icon

    var body: some View {
        VStack(alignment: .leading, spacing: AATheme.paddingSmall) {
            ZStack {
                SwiftUI.Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                icon()
            }

            Text(title)
                .font(AATheme.subheadlineFont)
                .foregroundColor(AATheme.primaryText)

            Text(description)
                .font(.system(size: 13))
                .foregroundColor(AATheme.secondaryText)
                .lineSpacing(3)
        }
        .padding(AATheme.paddingMedium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AATheme.cardBackground)
        .cornerRadius(AATheme.cornerRadius)
        .shadow(color: AATheme.cardShadow, radius: AATheme.cardShadowRadius, x: 0, y: 2)
    }
}

// MARK: - Onboarding Page 3 — How it Works
struct OnboardingPage3: View {
    @State private var appeared = false

    var body: some View {
        VStack(spacing: AATheme.paddingLarge) {
            Spacer()

            Text("How it works")
                .font(AATheme.headlineFont)
                .foregroundColor(AATheme.primaryText)
                .opacity(appeared ? 1.0 : 0.0)

            VStack(spacing: 16) {
                HowItWorksRow(
                    number: "1",
                    color: AATheme.steel,
                    title: "Morning Anchor",
                    description: "Start your day grounded — scripture, reflection, reject the drift."
                )
                HowItWorksRow(
                    number: "2",
                    color: AATheme.amber,
                    title: "Evening Arrow",
                    description: "End your day purposeful — log one action that advanced God's kingdom."
                )
                HowItWorksRow(
                    number: "3",
                    color: AATheme.warning,
                    title: "Drift Log",
                    description: "Any moment you slip? Tap the shield. Hear a prayer. Anchor back fast."
                )
                HowItWorksRow(
                    number: "4",
                    color: AATheme.warmGold,
                    title: "Iron Sharpeners",
                    description: "Join a private circle of brothers. Sharpen each other. Stay accountable."
                )
            }
            .padding(.horizontal, AATheme.paddingLarge)
            .opacity(appeared ? 1.0 : 0.0)
            .offset(y: appeared ? 0 : 20)
            .animation(.easeOut(duration: 0.5).delay(0.2), value: appeared)

            Spacer()
            Spacer()
        }
        .onAppear { appeared = true }
        .onDisappear { appeared = false }
    }
}

struct HowItWorksRow: View {
    let number: String
    let color: Color
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                SwiftUI.Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                Text(number)
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AATheme.subheadlineFont)
                    .foregroundColor(AATheme.primaryText)
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(AATheme.secondaryText)
                    .lineSpacing(3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Onboarding Page 4 — CTA
struct OnboardingPage4: View {
    let onGetStarted: () -> Void
    @State private var appeared = false

    var body: some View {
        VStack(spacing: AATheme.paddingXLarge) {
            Spacer()

            Image(systemName: "figure.stand")
                .font(.system(size: 72, weight: .light))
                .foregroundColor(AATheme.steel)
                .scaleEffect(appeared ? 1.0 : 0.5)
                .opacity(appeared ? 1.0 : 0.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: appeared)

            VStack(spacing: 14) {
                Text("Ready to stand firm?")
                    .font(AATheme.titleFont)
                    .foregroundColor(AATheme.primaryText)

                Text("No fluff. No performance. Just daily faithfulness — one anchor, one arrow, one day at a time.")
                    .font(.system(size: 16))
                    .foregroundColor(AATheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, 32)
            }
            .opacity(appeared ? 1.0 : 0.0)
            .offset(y: appeared ? 0 : 16)
            .animation(.easeOut(duration: 0.5).delay(0.3), value: appeared)

            Button(action: onGetStarted) {
                HStack {
                    Text("Create My Account")
                    Image(systemName: "arrow.right")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(AAPrimaryButtonStyle())
            .padding(.horizontal, 32)
            .opacity(appeared ? 1.0 : 0.0)
            .offset(y: appeared ? 0 : 16)
            .animation(.easeOut(duration: 0.5).delay(0.45), value: appeared)

            Text("Free to start. No credit card required.")
                .font(.system(size: 12))
                .foregroundColor(AATheme.secondaryText)
                .opacity(appeared ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.5).delay(0.55), value: appeared)

            Spacer()
            Spacer()
        }
        .onAppear { appeared = true }
        .onDisappear { appeared = false }
    }
}
