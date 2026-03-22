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
    @State private var logoShown = false
    @State private var arrowShown = false
    @State private var textOpacity = 0.0

    var body: some View {
        ZStack {
            Color("BackgroundPrimary").ignoresSafeArea()

            VStack(spacing: 36) {
                // Logo mark
                ZStack {
                    // Solid gradient circle — anchor is white on top
                    SwiftUI.Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color("BrandAnchor"), Color("BrandAnchor").opacity(0.75)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                        .shadow(color: Color("BrandAnchor").opacity(0.35), radius: 24, x: 0, y: 10)
                        .scaleEffect(logoShown ? 1.0 : 0.5)
                        .opacity(logoShown ? 1.0 : 0.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: logoShown)

                    // Anchor — white, bold, large and clearly legible
                    Image(systemName: "anchor")
                        .font(.system(size: 68, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(logoShown ? 1.0 : 0.4)
                        .opacity(logoShown ? 1.0 : 0.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.15), value: logoShown)

                    // Arrow — brand orange, shoots out from top-right of circle
                    ZStack {
                        SwiftUI.Circle()
                            .fill(Color("BrandArrow"))
                            .frame(width: 40, height: 40)
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 18, weight: .black))
                            .foregroundColor(.white)
                    }
                    .shadow(color: Color("BrandArrow").opacity(0.5), radius: 8, x: 0, y: 3)
                    .offset(x: arrowShown ? 54 : 20, y: arrowShown ? -54 : -20)
                    .opacity(arrowShown ? 1.0 : 0.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.5), value: arrowShown)
                }
                .frame(width: 180, height: 180)

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
                .animation(.easeIn(duration: 0.6).delay(0.3), value: textOpacity)
            }
        }
        .onAppear {
            logoShown = true
            arrowShown = true
            textOpacity = 1.0
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
                        Label("Arrow", systemImage: "arrow.up.right.circle.fill")
                    }
                    .tag(2)

                SwiftUI.ProgressView()
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
