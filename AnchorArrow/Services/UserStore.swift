// UserStore.swift
// Central observable state for the logged-in user — drives all views

import SwiftUI
import Combine
import Firebase
import FirebaseAuth
import FirebaseFirestore

@MainActor
class UserStore: ObservableObject {

    @Published var appUser: AppUser?
    @Published var todayEntry: DailyEntry?
    @Published var recentEntries: [DailyEntry] = []
    @Published var driftLogs: [DriftLog] = []
    @Published var hasCompletedOnboarding: Bool = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var userListener: ListenerRegistration?
    private var authListener: AuthStateDidChangeListenerHandle?
    private let firestoreService = FirestoreService.shared
    private let defaults = UserDefaults.standard

    init() {
        // Check onboarding completion from UserDefaults
        hasCompletedOnboarding = defaults.bool(forKey: "onboardingComplete")

        // Listen for auth changes
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor [weak self] in
                if let user {
                    await self?.loadUserData(uid: user.uid)
                } else {
                    self?.clearData()
                }
            }
        }
    }

    // MARK: - Load User Data
    func loadUserData(uid: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            appUser = try await firestoreService.fetchUser(uid: uid)
            todayEntry = try await firestoreService.fetchTodayEntry(uid: uid)
            recentEntries = try await firestoreService.fetchRecentEntries(uid: uid, limit: 60)
            driftLogs = try await firestoreService.fetchDriftLogs(uid: uid)

            // Set up real-time user listener
            setupUserListener(uid: uid)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Real-time listener
    private func setupUserListener(uid: String) {
        userListener?.remove()
        userListener = firestoreService.listenToUser(uid: uid) { [weak self] result in
            Task { @MainActor [weak self] in
                switch result {
                case .success(let user):
                    self?.appUser = user
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    // MARK: - Onboarding
    func completeOnboarding() {
        hasCompletedOnboarding = true
        defaults.set(true, forKey: "onboardingComplete")
    }

    // MARK: - Today's Entry Actions

    func completeAnchor(reflection: String, tags: [AnchorTag]) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        var entry = todayEntry ?? DailyEntry.todayEmpty()
        entry.anchorCompleted = true
        entry.anchorReflection = reflection
        entry.anchorTags = tags
        entry.anchorCompletedAt = Date()
        entry.anchorPromptId = PromptLibrary.anchorPromptForToday().id

        do {
            try await firestoreService.saveEntry(uid: uid, entry: entry)
            try await firestoreService.updateStreak(uid: uid)
            try await firestoreService.evaluateAndAwardBadges(uid: uid, entry: entry)
            todayEntry = entry
            await refreshRecent(uid: uid)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func completeArrow(reflection: String, role: ArrowRole) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        var entry = todayEntry ?? DailyEntry.todayEmpty()
        entry.arrowCompleted = true
        entry.arrowReflection = reflection
        entry.arrowRole = role
        entry.arrowCompletedAt = Date()
        entry.arrowPromptId = PromptLibrary.arrowPromptForToday().id

        do {
            try await firestoreService.saveEntry(uid: uid, entry: entry)
            try await firestoreService.updateStreak(uid: uid)
            try await firestoreService.evaluateAndAwardBadges(uid: uid, entry: entry)
            todayEntry = entry
            await refreshRecent(uid: uid)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func logDrift(category: AnchorTag, note: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let log = DriftLog.new(category: category, note: note)
        do {
            try await firestoreService.saveDriftLog(uid: uid, log: log)
            driftLogs.insert(log, at: 0)
            try await firestoreService.evaluateAndAwardBadges(uid: uid)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Journey

    func startJourney() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            try await firestoreService.updateJourney(uid: uid, day: 0, startDate: Date())
            try await firestoreService.awardBadge(uid: uid, badgeType: .journeyStarted)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func advanceJourneyDay() async {
        guard let uid = Auth.auth().currentUser?.uid,
              let user = appUser else { return }
        let nextDay = user.journeyDay + 1
        do {
            try await firestoreService.updateJourney(uid: uid, day: nextDay, startDate: nil)
            if nextDay >= 7  { try await firestoreService.awardBadge(uid: uid, badgeType: .journeyWeek1) }
            if nextDay >= 30 { try await firestoreService.awardBadge(uid: uid, badgeType: .journeyComplete) }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Helpers
    var isPremium: Bool { appUser?.isPremium ?? false }
    var currentStreak: Int { appUser?.currentStreak ?? 0 }
    var displayName: String { appUser?.displayName ?? Auth.auth().currentUser?.displayName ?? "Warrior" }
    var colorScheme: ColorScheme? { appUser?.theme.swiftUIColorScheme }

    var isAnchorDoneToday: Bool { todayEntry?.anchorCompleted ?? false }
    var isArrowDoneToday: Bool { todayEntry?.arrowCompleted ?? false }
    var isBothDoneToday: Bool { todayEntry?.bothCompleted ?? false }

    var earnedBadges: [BadgeType] {
        (appUser?.badges ?? []).compactMap { BadgeType(rawValue: $0) }
    }

    private func refreshRecent(uid: String) async {
        recentEntries = (try? await firestoreService.fetchRecentEntries(uid: uid, limit: 60)) ?? []
    }

    private func clearData() {
        appUser = nil
        todayEntry = nil
        recentEntries = []
        driftLogs = []
        userListener?.remove()
        userListener = nil
    }
}
