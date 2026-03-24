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
            Color("BackgroundPrimary").ignoresSafeArea()

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
                                    .fill(i == currentPage ? Color("BrandAnchor") : Color("TextSecondary").opacity(0.3))
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
                                        .font(.system(size: 17, weight: .semibold))
                                    Image(systemName: "arrow.right")
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color("BrandAnchor"))
                                .foregroundColor(.white)
                                .cornerRadius(14)
                                .padding(.horizontal, 32)
                            }

                            if currentPage == 0 {
                                Button("Already have an account? Sign In") {
                                    isSignUp = false
                                    withAnimation(.spring()) { showAuth = true }
                                }
                                .font(.system(size: 14))
                                .foregroundColor(Color("TextSecondary"))
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
                            colors: [Color("BrandAnchor").opacity(0.11), Color.clear],
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
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundColor(Color("TextPrimary"))

                Text("Anchor & Arrow is a daily habit journal built for men who are done drifting and ready to stand firm in Christ.")
                    .font(.system(size: 17))
                    .foregroundColor(Color("TextSecondary"))
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
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundColor(Color("TextPrimary"))
            }
            .opacity(appeared ? 1.0 : 0.0)
            .animation(.easeOut(duration: 0.4).delay(0.1), value: appeared)

            // Scripture card
            VStack(spacing: 12) {
                Text("\"Be watchful, stand firm in the faith, act like men, be strong. Let all that you do be done in love.\"")
                    .font(.system(size: 18, weight: .medium, design: .serif))
                    .italic()
                    .foregroundColor(Color("TextPrimary"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)

                Text("— 1 Corinthians 16:13-14")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("BrandAnchor"))
            }
            .padding(24)
            .background(Color("CardBackground"))
            .cornerRadius(18)
            .padding(.horizontal, 24)
            .opacity(appeared ? 1.0 : 0.0)
            .offset(y: appeared ? 0 : 16)
            .animation(.easeOut(duration: 0.5).delay(0.2), value: appeared)

            // Two concepts
            HStack(spacing: 16) {
                ConceptCard(color: "BrandAnchor",
                            title: "The Anchor",
                            description: "Be watchful. Stand firm. Root yourself in Christ daily.") {
                    AnchorSymbolView()
                        .frame(width: 28, height: 35)
                }
                ConceptCard(color: "BrandArrow",
                            title: "The Arrow",
                            description: "Act like men. Be strong in love. Pursue God's purpose.") {
                    SingleArcheryArrowView(color: Color("BrandArrow"))
                        .frame(width: 26, height: 26)
                }
            }
            .padding(.horizontal, 24)
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

// Single archery arrow pointing up-right with shaft, head, and fletching.
private struct SingleArcheryArrowView: View {
    var color: Color

    var body: some View {
        Canvas { context, size in
            let w = size.width, h = size.height
            let tail = CGPoint(x: w * 0.15, y: h * 0.85)
            let tip  = CGPoint(x: w * 0.85, y: h * 0.15)
            let dx = tip.x - tail.x, dy = tip.y - tail.y
            let len = sqrt(dx*dx + dy*dy)
            let ux = dx/len, uy = dy/len
            let px = -uy,    py =  ux
            let lw       = max(w * 0.082, 1.2)
            let headLen  = w * 0.30
            let fletchLen = w * 0.19
            let shading  = GraphicsContext.Shading.color(color)

            var shaft = Path()
            shaft.move(to: tail); shaft.addLine(to: tip)
            context.stroke(shaft, with: shading,
                           style: StrokeStyle(lineWidth: lw, lineCap: .round))

            let angle = atan2(dy, dx), spread: CGFloat = .pi / 5
            var head = Path()
            head.move(to: tip)
            head.addLine(to: CGPoint(x: tip.x - headLen * cos(angle - spread),
                                     y: tip.y - headLen * sin(angle - spread)))
            head.move(to: tip)
            head.addLine(to: CGPoint(x: tip.x - headLen * cos(angle + spread),
                                     y: tip.y - headLen * sin(angle + spread)))
            context.stroke(head, with: shading,
                           style: StrokeStyle(lineWidth: lw, lineCap: .round))

            for t: CGFloat in [0.08, 0.18] {
                let base = CGPoint(x: tail.x + ux * len * t,
                                   y: tail.y + uy * len * t)
                var fletch = Path()
                fletch.move(to: CGPoint(x: base.x + px * fletchLen,
                                        y: base.y + py * fletchLen))
                fletch.addLine(to: base)
                fletch.addLine(to: CGPoint(x: base.x - px * fletchLen,
                                           y: base.y - py * fletchLen))
                context.stroke(fletch, with: .color(color.opacity(0.55)),
                               style: StrokeStyle(lineWidth: max(lw * 0.8, 1.0),
                                                 lineCap: .round, lineJoin: .round))
            }
        }
    }
}

struct ConceptCard<Icon: View>: View {
    let color: String
    let title: String
    let description: String
    @ViewBuilder let icon: () -> Icon

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                SwiftUI.Circle()
                    .fill(Color(color).opacity(0.15))
                    .frame(width: 48, height: 48)
                icon()
            }

            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color("TextPrimary"))

            Text(description)
                .font(.system(size: 13))
                .foregroundColor(Color("TextSecondary"))
                .lineSpacing(3)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("CardBackground"))
        .cornerRadius(16)
    }
}

// MARK: - Onboarding Page 3 — How it Works
struct OnboardingPage3: View {
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("How it works")
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundColor(Color("TextPrimary"))
                .opacity(appeared ? 1.0 : 0.0)

            VStack(spacing: 16) {
                HowItWorksRow(
                    number: "1",
                    color: "BrandAnchor",
                    title: "Morning Anchor",
                    description: "Start your day grounded — scripture, reflection, reject the drift."
                )
                HowItWorksRow(
                    number: "2",
                    color: "BrandArrow",
                    title: "Evening Arrow",
                    description: "End your day purposeful — log one action that advanced God's kingdom."
                )
                HowItWorksRow(
                    number: "3",
                    color: "BrandWarning",
                    title: "Drift Log",
                    description: "Any moment you slip? Tap the shield. Hear a prayer. Anchor back fast."
                )
                HowItWorksRow(
                    number: "4",
                    color: "BrandGold",
                    title: "Iron Sharpeners",
                    description: "Join a private circle of brothers. Sharpen each other. Stay accountable."
                )
            }
            .padding(.horizontal, 24)
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
    let color: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                SwiftUI.Circle()
                    .fill(Color(color).opacity(0.15))
                    .frame(width: 40, height: 40)
                Text(number)
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundColor(Color(color))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(Color("TextSecondary"))
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
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "figure.stand")
                .font(.system(size: 72, weight: .light))
                .foregroundColor(Color("BrandAnchor"))
                .scaleEffect(appeared ? 1.0 : 0.5)
                .opacity(appeared ? 1.0 : 0.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: appeared)

            VStack(spacing: 14) {
                Text("Ready to stand firm?")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(Color("TextPrimary"))

                Text("No fluff. No performance. Just daily faithfulness — one anchor, one arrow, one day at a time.")
                    .font(.system(size: 16))
                    .foregroundColor(Color("TextSecondary"))
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
                        .font(.system(size: 18, weight: .bold))
                    Image(systemName: "arrow.right")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        colors: [Color("BrandAnchor"), Color("BrandArrow")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(16)
                .padding(.horizontal, 32)
            }
            .opacity(appeared ? 1.0 : 0.0)
            .offset(y: appeared ? 0 : 16)
            .animation(.easeOut(duration: 0.5).delay(0.45), value: appeared)

            Text("Free to start. No credit card required.")
                .font(.system(size: 12))
                .foregroundColor(Color("TextSecondary"))
                .opacity(appeared ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.5).delay(0.55), value: appeared)

            Spacer()
            Spacer()
        }
        .onAppear { appeared = true }
        .onDisappear { appeared = false }
    }
}
