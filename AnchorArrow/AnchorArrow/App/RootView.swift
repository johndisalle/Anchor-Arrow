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
            AATheme.background.ignoresSafeArea()

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
                                colors: [AATheme.steel.opacity(0.11), Color.clear],
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
                        .font(AATheme.titleFont)
                        .tracking(3)
                        .foregroundColor(AATheme.primaryText)
                        .opacity(titleOpacity)

                    Rectangle()
                        .fill(AATheme.steel.opacity(0.3))
                        .frame(width: 40, height: 1.5)
                        .opacity(titleOpacity)

                    Text("Stand Firm Edition")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .tracking(1.5)
                        .foregroundColor(AATheme.secondaryText)
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
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State private var selectedTab = 0
    @State private var showDriftLog = false
    @State private var showNotificationPrompt = false
    @State private var showWelcomeGuide = false
    @State private var showErrorToast = false
    @State private var errorToastMessage = ""
    @State private var errorToastId = UUID()
    @State private var pendingCircleCode: String?

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
                                        colors: [AATheme.warning, AATheme.destructive],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 52, height: 52)
                                .shadow(color: AATheme.destructive.opacity(0.4), radius: 8, x: 0, y: 4)

                            AAIcon("exclamationmark.shield.fill", size: 22, color: .white)
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 95) // above custom tab bar
                    .accessibilityLabel("Log a drift moment")
                }
            }

            // Offline banner
            if !networkMonitor.isConnected {
                VStack {
                    HStack(spacing: AATheme.paddingSmall) {
                        Image(systemName: "wifi.slash")
                            .font(.system(size: 13, weight: .semibold))
                        Text("No internet connection")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, AATheme.paddingSmall)
                    .frame(maxWidth: .infinity)
                    .background(AATheme.secondaryText.opacity(0.85))
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.easeInOut(duration: 0.3), value: networkMonitor.isConnected)
                .zIndex(99)
            }
        }
        .sheet(isPresented: $showDriftLog) {
            DriftLogView()
        }
        .fullScreenCover(isPresented: $showNotificationPrompt) {
            NotificationPromptView(isPresented: $showNotificationPrompt)
                .environmentObject(userStore)
        }
        .fullScreenCover(isPresented: $showWelcomeGuide) {
            WelcomeGuideView(isPresented: $showWelcomeGuide)
        }
        .checkNotificationPermission()
        .onOpenURL { url in
            // Deep link: anchorarrow://join?code=ABC123
            if url.scheme == "anchorarrow", url.host == "join",
               let code = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?.first(where: { $0.name == "code" })?.value {
                selectedTab = 4 // Switch to Circles tab
                pendingCircleCode = code
            }
        }
        .onAppear {
            // Show welcome guide first, then notification prompt
            let guideKey = "hasSeenWelcomeGuide"
            let notifKey = "hasSeenNotificationPrompt"
            if !UserDefaults.standard.bool(forKey: guideKey) {
                UserDefaults.standard.set(true, forKey: guideKey)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    showWelcomeGuide = true
                }
            } else if !UserDefaults.standard.bool(forKey: notifKey) {
                UserDefaults.standard.set(true, forKey: notifKey)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    showNotificationPrompt = true
                }
            }
        }
        // Show notification prompt after welcome guide dismisses
        .onChange(of: showWelcomeGuide) { _, isShowing in
            if !isShowing {
                let notifKey = "hasSeenNotificationPrompt"
                if !UserDefaults.standard.bool(forKey: notifKey) {
                    UserDefaults.standard.set(true, forKey: notifKey)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showNotificationPrompt = true
                    }
                }
            }
        }
        .onChange(of: userStore.errorMessage) { _, newValue in
            if let message = newValue, !message.isEmpty {
                errorToastMessage = message
                showErrorToast = true
                // Rotate ID so identical consecutive messages still trigger animations
                errorToastId = UUID()
                userStore.errorMessage = nil
                let dismissId = errorToastId
                // Auto-dismiss after 4 seconds (only if no newer toast replaced it)
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    if errorToastId == dismissId {
                        showErrorToast = false
                    }
                }
            }
        }
        .safeAreaInset(edge: .top) {
            if showErrorToast {
                HStack(spacing: AATheme.paddingSmall + 2) {
                    AAIcon("exclamationmark.triangle.fill", size: 15, color: .white)
                    Text(errorToastMessage)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(2)
                    Spacer()
                    Button {
                        showErrorToast = false
                    } label: {
                        AAIcon("xmark", size: 12, weight: .bold, color: .white.opacity(0.7))
                    }
                }
                .padding(14)
                .background(AATheme.destructive.cornerRadius(AATheme.cornerRadiusSmall + 2))
                .padding(.horizontal, AATheme.paddingMedium)
                .padding(.top, 4)
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(response: 0.4), value: showErrorToast)
                .id(errorToastId)
            }
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
                                ? AATheme.steel
                                : AATheme.secondaryText
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.top, AATheme.paddingSmall + 2)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(tab.label) tab")
                    .accessibilityHint(selectedTab == tab.tag ? "Currently selected" : "Double tap to switch")
                    .accessibilityAddTraits(selectedTab == tab.tag ? .isSelected : [])
                }
            }
            .padding(.bottom, AATheme.paddingSmall)
        }
        .background(AATheme.cardBackground.ignoresSafeArea(edges: .bottom))
    }

    @ViewBuilder
    private func tabIcon(tag: Int) -> some View {
        let tint = selectedTab == tag ? AATheme.steel : AATheme.secondaryText
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

// MARK: - Skeleton Shimmer
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [.clear, .white.opacity(0.15), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = UIScreen.main.bounds.width
                }
            }
    }
}

extension View {
    func shimmer() -> some View { modifier(ShimmerModifier()) }
}

// MARK: - Skeleton Loading Cards
struct SkeletonCard: View {
    var height: CGFloat = 80

    var body: some View {
        RoundedRectangle(cornerRadius: AATheme.cornerRadius)
            .fill(AATheme.cardBackground)
            .frame(height: height)
            .shimmer()
    }
}

struct SkeletonCirclesList: View {
    var body: some View {
        VStack(spacing: AATheme.paddingMedium) {
            ForEach(0..<3, id: \.self) { _ in
                HStack(spacing: AATheme.paddingMedium) {
                    SwiftUI.Circle()
                        .fill(AATheme.cardBackground)
                        .frame(width: 52, height: 52)
                    VStack(alignment: .leading, spacing: AATheme.paddingSmall) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AATheme.cardBackground)
                            .frame(width: 140, height: 14)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AATheme.cardBackground)
                            .frame(width: 90, height: 10)
                    }
                    Spacer()
                }
                .padding(AATheme.paddingMedium)
                .background(AATheme.cardBackground.opacity(0.5))
                .cornerRadius(AATheme.cornerRadius)
            }
        }
        .shimmer()
        .padding(.horizontal, 20)
        .padding(.top, AATheme.paddingMedium)
    }
}

struct SkeletonPostFeed: View {
    var body: some View {
        VStack(spacing: 12) {
            SkeletonCard(height: 100)
            ForEach(0..<3, id: \.self) { _ in
                VStack(alignment: .leading, spacing: AATheme.paddingSmall + 2) {
                    HStack {
                        RoundedRectangle(cornerRadius: AATheme.paddingSmall)
                            .fill(AATheme.cardBackground)
                            .frame(width: 70, height: 22)
                        Spacer()
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AATheme.cardBackground)
                            .frame(width: 40, height: 10)
                    }
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AATheme.cardBackground)
                        .frame(height: 12)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AATheme.cardBackground)
                        .frame(width: 200, height: 12)
                }
                .padding(14)
                .background(AATheme.cardBackground.opacity(0.5))
                .cornerRadius(AATheme.cornerRadiusSmall + 4)
            }
        }
        .shimmer()
        .padding(.horizontal, 20)
        .padding(.top, AATheme.paddingMedium)
    }
}
