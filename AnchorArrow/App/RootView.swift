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
    @State private var textOpacity = 0.0

    var body: some View {
        ZStack {
            Color("BackgroundPrimary").ignoresSafeArea()

            VStack(spacing: 28) {
                // Hero: crossed arrows above ground line, anchor below
                VStack(spacing: 0) {
                    CrossedArrowsView()
                        .frame(width: 150, height: 94)
                        .scaleEffect(arrowsShown ? 1.0 : 0.1)
                        .opacity(arrowsShown ? 1.0 : 0)
                        .animation(.spring(response: 0.7, dampingFraction: 0.65).delay(0.9), value: arrowsShown)

                    Rectangle()
                        .fill(Color("BrandEarth").opacity(0.3))
                        .frame(height: 1.5)
                        .frame(maxWidth: 180)
                        .padding(.vertical, 6)

                    Image(systemName: "anchor")
                        .font(.system(size: 110, weight: .thin))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color("BrandAnchor"), Color("BrandAnchor").opacity(0.55)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .scaleEffect(anchorShown ? 1.0 : 0.05)
                        .opacity(anchorShown ? 1.0 : 0)
                        .animation(.spring(response: 0.9, dampingFraction: 0.62).delay(0.15), value: anchorShown)
                }

                VStack(spacing: 6) {
                    Text("ANCHOR & ARROW")
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .tracking(3)
                        .foregroundColor(Color("TextPrimary"))

                    Text("Stand Firm Edition")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .tracking(1.5)
                        .foregroundColor(Color("TextSecondary"))
                }
                .opacity(textOpacity)
            }
        }
        .onAppear {
            anchorShown = true
            arrowsShown = true
            withAnimation(.easeIn(duration: 0.6).delay(0.3)) {
                textOpacity = 1.0
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
                        Label("Anchor", systemImage: "anchor")
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
