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
    @State private var rootsGrown = false
    @State private var arrowLaunched = false
    @State private var textOpacity = 0.0

    var body: some View {
        ZStack {
            Color("BackgroundPrimary").ignoresSafeArea()

            VStack(spacing: 24) {
                // Logo / Icon area
                ZStack {
                    // Root system (anchor)
                    AnchorRootsShape(progress: rootsGrown ? 1.0 : 0.0)
                        .stroke(Color("BrandAnchor"), lineWidth: 2.5)
                        .frame(width: 120, height: 80)
                        .offset(y: 40)
                        .animation(.easeOut(duration: 0.9), value: rootsGrown)

                    // Tree trunk
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color("BrandEarth"))
                        .frame(width: 8, height: rootsGrown ? 60 : 0)
                        .offset(y: -10)
                        .animation(.easeOut(duration: 0.6).delay(0.4), value: rootsGrown)

                    // Arrow (purpose)
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color("BrandArrow"))
                        .offset(x: arrowLaunched ? 24 : 0, y: arrowLaunched ? -48 : -40)
                        .opacity(arrowLaunched ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(1.0), value: arrowLaunched)
                }
                .frame(width: 160, height: 160)

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
            rootsGrown = true
            arrowLaunched = true
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
