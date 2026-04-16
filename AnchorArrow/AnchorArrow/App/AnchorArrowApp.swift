// AnchorArrowApp.swift
// Anchor & Arrow – Stand Firm Edition
// Main entry point

import SwiftUI
import Firebase
import FirebaseAuth
// NOTE: Add FirebaseCrashlytics SPM product in Xcode, then uncomment:
// import FirebaseCrashlytics

// MARK: - AppDelegate (ensures Firebase configures before any @StateObject)
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()

        let settings = FirestoreSettings()
        settings.cacheSettings = PersistentCacheSettings(sizeBytes: NSNumber(value: FirestoreCacheSizeUnlimited))
        Firestore.firestore().settings = settings
        return true
    }
}

@main
struct AnchorArrowApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    // MARK: - State Objects (safe — Firebase is already configured)
    @StateObject private var authManager = AuthManager()
    @StateObject private var userStore = UserStore()
    @StateObject private var storeKitManager = StoreKitManager()
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var networkMonitor = NetworkMonitor()

    init() {
        // Configure global appearance
        configureAppearance()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authManager)
                .environmentObject(userStore)
                .environmentObject(storeKitManager)
                .environmentObject(notificationManager)
                .environmentObject(networkMonitor)
        }
    }

    // MARK: - Appearance Configuration
    private func configureAppearance() {
        // Use dynamic UIColors so UIKit chrome (nav bar etc.) adapts to
        // whatever color scheme is active — light, dark, or system.
        let bgPrimary = UIColor { t in
            t.userInterfaceStyle == .dark
                ? UIColor(red: 42/255,  green: 37/255,  blue: 32/255,  alpha: 1) // #2A2520
                : UIColor(red: 248/255, green: 244/255, blue: 239/255, alpha: 1) // #F8F4EF
        }
        let textPrimary = UIColor { t in
            t.userInterfaceStyle == .dark
                ? UIColor(red: 245/255, green: 240/255, blue: 234/255, alpha: 1) // #F5F0EA
                : UIColor(red:  28/255, green:  25/255, blue:  23/255, alpha: 1) // #1C1917
        }
        let anchorBlue = UIColor { t in
            t.userInterfaceStyle == .dark
                ? UIColor(red:  74/255, green: 144/255, blue: 196/255, alpha: 1) // #4A90C4
                : UIColor(red:  44/255, green:  95/255, blue: 138/255, alpha: 1) // #2C5F8A
        }
        let mutedText = UIColor { t in
            t.userInterfaceStyle == .dark
                ? UIColor(red: 245/255, green: 240/255, blue: 234/255, alpha: 0.4)
                : UIColor(red:  28/255, green:  25/255, blue:  23/255, alpha: 0.4)
        }

        // Navigation bar
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = bgPrimary
        navAppearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 18, weight: .bold),
            .foregroundColor: textPrimary
        ]
        navAppearance.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 34, weight: .heavy),
            .foregroundColor: textPrimary
        ]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance

        // Tab bar (kept for any UIKit tab bars; main tab is now SwiftUI CustomTabBar)
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = bgPrimary

        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = mutedText
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: mutedText]
        itemAppearance.selected.iconColor = anchorBlue
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: anchorBlue]
        tabAppearance.stackedLayoutAppearance = itemAppearance
        tabAppearance.inlineLayoutAppearance = itemAppearance
        tabAppearance.compactInlineLayoutAppearance = itemAppearance

        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
}
