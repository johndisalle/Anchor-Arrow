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
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
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
                .preferredColorScheme(userStore.colorScheme)
                .onAppear { userStore.storeKitManager = storeKitManager }
        }
    }

    // MARK: - Appearance Configuration
    private func configureAppearance() {
        // Navigation bar appearance
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(named: "BackgroundPrimary")
        navAppearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 18, weight: .bold),
            .foregroundColor: UIColor(named: "TextPrimary") ?? .label
        ]
        navAppearance.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 34, weight: .heavy),
            .foregroundColor: UIColor(named: "TextPrimary") ?? .label
        ]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance

        // Tab bar appearance
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(named: "BackgroundSecondary")
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
}
