// RootView.swift
// Root navigation controller — routes between Onboarding and Main app

import SwiftUI

struct RootView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userStore: UserStore
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else if authManager.isAuthenticated {
                if userStore.hasCompletedOnboarding {
                    MainTabView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .opacity
                        ))
                } else {
                    OnboardingContainerView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .opacity
                        ))
                }
            } else {
                OnboardingContainerView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .opacity
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.4), value: showSplash)
        .animation(.easeInOut(duration: 0.4), value: authManager.isAuthenticated)
        .animation(.easeInOut(duration: 0.4), value: userStore.hasCompletedOnboarding)
        .onAppear {
            // Show splash for 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation { showSplash = false }
            }
        }
    }
}

// MARK: - Splash Screen
struct SplashView: View {
    @State private var anchorShown = false
    @State private var arrowsShown = false
    @State private var glowOpacity = 0.0
    @State private var titleOpacity = 0.0
    @State private var subtitleOpacity = 0.0

    var body: some View {
        ZStack {
            Color("BackgroundPrimary").ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Hero composition
                // Arrows sit above anchor ring with ~30pt overlap so they
                // cross ABOVE the ring, not through the anchor body.
                ZStack {
                    // Subtle atmospheric glow
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
                        .opacity(glowOpacity)

                    VStack(spacing: -30) {
                        CrossedArrowsView()
                            .frame(width: 200, height: 124)
                            .scaleEffect(arrowsShown ? 1.0 : 0.1)
                            .opacity(arrowsShown ? 1.0 : 0)
                            .animation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.85), value: arrowsShown)

                        AnchorSymbolView()
                            .frame(width: 164, height: 205)
                            .opacity(anchorShown ? 1.0 : 0)
                            .animation(.easeOut(duration: 0.7).delay(0.15), value: anchorShown)
                    }
                }

                Spacer().frame(height: 52)

                // Wordmark
                VStack(spacing: 12) {
                    Text("ANCHOR & ARROW")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .tracking(3)
                        .foregroundColor(Color("TextPrimary"))
                        .opacity(titleOpacity)

                    Rectangle()
                        .fill(Color("BrandAnchor").opacity(0.3))
                        .frame(width: 40, height: 1.5)
                        .opacity(titleOpacity)

                    Text("Stand Firm Edition")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .tracking(1.5)
                        .foregroundColor(Color("TextSecondary"))
                        .opacity(subtitleOpacity)
                }

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            anchorShown = true
            arrowsShown = true
            withAnimation(.easeOut(duration: 1.8).delay(0.15)) {
                glowOpacity = 1.0
            }
            withAnimation(.easeIn(duration: 0.6).delay(0.35)) {
                titleOpacity = 1.0
            }
            withAnimation(.easeIn(duration: 0.5).delay(1.0)) {
                subtitleOpacity = 1.0
            }
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @EnvironmentObject var userStore: UserStore
    @State private var selectedTab = 0
    @State private var showDriftLog = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                DashboardView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)

                AnchorView()
                    .tabItem {
                        Label("Anchor", systemImage: "anchor.circle.fill")
                    }
                    .tag(1)

                ArrowView()
                    .tabItem {
                        Label("Arrow", systemImage: "scope")
                    }
                    .tag(2)

                ProgressView()
                    .tabItem {
                        Label("Progress", systemImage: "chart.bar.fill")
                    }
                    .tag(3)

                CirclesView()
                    .tabItem {
                        Label("Circles", systemImage: "person.3.fill")
                    }
                    .tag(4)
            }
            .accentColor(Color("BrandAnchor"))

            // Floating Drift Log Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        showDriftLog = true
                    } label: {
                        ZStack {
                            SwiftUI.Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color("BrandWarning"), Color("BrandDanger")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 52, height: 52)
                                .shadow(color: Color("BrandDanger").opacity(0.4), radius: 8, x: 0, y: 4)

                            Image(systemName: "exclamationmark.shield.fill")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 85) // above tab bar
                    .accessibilityLabel("Log a drift moment")
                }
            }
        }
        .sheet(isPresented: $showDriftLog) {
            DriftLogView()
        }
    }
}
