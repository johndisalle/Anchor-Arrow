// AnchorArrowApp.swift
// Anchor & Arrow – Stand Firm Edition
// Main entry point

import SwiftUI
import Firebase
import FirebaseAuth

@main
struct AnchorArrowApp: App {

    // MARK: - State Objects
    @StateObject private var authManager = AuthManager()
    @StateObject private var userStore = UserStore()
    @StateObject private var storeKitManager = StoreKitManager()
    @StateObject private var notificationManager = NotificationManager()

    init() {
        // Configure Firebase
        FirebaseApp.configure()

        // Enable Firestore offline persistence
        let settings = FirestoreSettings()
        settings.cacheSettings = PersistentCacheSettings(sizeBytes: NSNumber(value: FirestoreCacheSizeUnlimited))
        Firestore.firestore().settings = settings

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
                .preferredColorScheme(.light)
        }
    }

    // MARK: - Appearance Configuration
    private func configureAppearance() {
        // Hardcode light-mode colors to avoid UIColor(named:) resolving against
        // the wrong trait collection at init time (before .preferredColorScheme(.light) applies)
        let bgPrimary    = UIColor(red: 248/255, green: 244/255, blue: 239/255, alpha: 1) // #F8F4EF
        let bgSecondary  = UIColor(red: 239/255, green: 236/255, blue: 230/255, alpha: 1) // #EFECE6
        let textPrimary  = UIColor(red:  28/255, green:  25/255, blue:  23/255, alpha: 1) // #1C1917
        let anchorBlue   = UIColor(red:  44/255, green:  95/255, blue: 138/255, alpha: 1) // #2C5F8A
        let mutedText    = UIColor(red:  28/255, green:  25/255, blue:  23/255, alpha: 0.4)

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

        // Tab bar
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = bgSecondary

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
