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
        .preferredColorScheme((AppTheme(rawValue: userStore.savedTheme) ?? .system).swiftUIColorScheme)
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
                DashboardView().tag(0)
                AnchorView().tag(1)
                ArrowView().tag(2)
                ProgressView().tag(3)
                CirclesView().tag(4)
            }
            .toolbar(.hidden, for: .tabBar)
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 83)
            }

            // Custom Tab Bar (supports Canvas icons)
            CustomTabBar(selectedTab: $selectedTab)

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
                    .padding(.bottom, 95) // above custom tab bar
                    .accessibilityLabel("Log a drift moment")
                }
            }
        }
        .sheet(isPresented: $showDriftLog) {
            DriftLogView()
        }
    }
}

// MARK: - Custom Tab Bar
private struct CustomTabBar: View {
    @Binding var selectedTab: Int

    private let tabs: [(label: String, tag: Int)] = [
        ("Home", 0), ("Anchor", 1), ("Arrow", 2), ("Progress", 3), ("Circles", 4)
    ]

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 0) {
                ForEach(tabs, id: \.tag) { tab in
                    Button {
                        selectedTab = tab.tag
                    } label: {
                        VStack(spacing: 3) {
                            tabIcon(tag: tab.tag)
                                .frame(width: 26, height: 26)
                            Text(tab.label)
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundColor(
                            selectedTab == tab.tag
                                ? Color("BrandAnchor")
                                : Color("TextSecondary")
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.top, 10)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.bottom, 8)
        }
        .background(Color("CardBackground").ignoresSafeArea(edges: .bottom))
    }

    @ViewBuilder
    private func tabIcon(tag: Int) -> some View {
        let tint = selectedTab == tag ? Color("BrandAnchor") : Color("TextSecondary")
        switch tag {
        case 0:
            Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                .font(.system(size: 20))
        case 1:
            AnchorSymbolView(color: tint)
        case 2:
            SingleArcheryArrowView(color: tint)
        case 3:
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 20))
        case 4:
            Image(systemName: "person.3.fill")
                .font(.system(size: 20))
        default:
            EmptyView()
        }
    }
}
