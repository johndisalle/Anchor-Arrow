// UserStore.swift
// Central observable state for the logged-in user — drives all views

import SwiftUI
import Combine
import Firebase
import FirebaseAuth
import FirebaseFirestore
import UIKit

@MainActor
class UserStore: ObservableObject {

    @Published var appUser: AppUser?
    @Published var todayEntry: DailyEntry?
    @Published var recentEntries: [DailyEntry] = []
    @Published var driftLogs: [DriftLog] = []
    @Published var hasCompletedOnboarding: Bool = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showJourneyComplete = false
    @Published var completedJourneySeries: JourneySeries?

    /// Theme stored locally for instant switching — no Firestore round-trip needed
    @AppStorage("appTheme") var savedTheme: String = AppTheme.system.rawValue

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

            // Sync theme from server on first load
            if let theme = appUser?.theme {
                savedTheme = theme.rawValue
            }

            // Recalculate streak on app open (catches multi-day absences)
            try await firestoreService.updateStreak(uid: uid)
            appUser = try await firestoreService.fetchUser(uid: uid)

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

    private func haptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    private func notificationHaptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }

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
            let streakResult = try await firestoreService.updateStreak(uid: uid)
            try await firestoreService.evaluateAndAwardBadges(uid: uid, entry: entry)
            todayEntry = entry
            await refreshRecent(uid: uid)
            notificationHaptic(.success)
            if streakResult.graceDayBurned {
                await NotificationManager().sendGraceDayNotification(streakSaved: streakResult.streak)
            }
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
            let streakResult = try await firestoreService.updateStreak(uid: uid)
            try await firestoreService.evaluateAndAwardBadges(uid: uid, entry: entry)
            todayEntry = entry
            await refreshRecent(uid: uid)
            notificationHaptic(.success)
            if streakResult.graceDayBurned {
                await NotificationManager().sendGraceDayNotification(streakSaved: streakResult.streak)
            }
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
            haptic(.medium)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Journey

    func startJourney(series: JourneySeries = .standFirm) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            try await firestoreService.updateJourney(uid: uid, day: 0, startDate: Date(), series: series)
            try await firestoreService.awardBadge(uid: uid, badgeType: .journeyStarted)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func completeJourneyDay(anchorReflection: String, arrowReflection: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        // Save journey reflections as today's entry
        var entry = todayEntry ?? DailyEntry.todayEmpty()
        if !anchorReflection.isEmpty {
            entry.anchorCompleted = true
            entry.anchorReflection = anchorReflection
            entry.anchorCompletedAt = Date()
        }
        if !arrowReflection.isEmpty {
            entry.arrowCompleted = true
            entry.arrowReflection = arrowReflection
            entry.arrowCompletedAt = Date()
        }
        do {
            try await firestoreService.saveEntry(uid: uid, entry: entry)
            todayEntry = entry
            notificationHaptic(.success)
        } catch {
            errorMessage = error.localizedDescription
        }
        await advanceJourneyDay()
    }

    func advanceJourneyDay() async {
        guard let uid = Auth.auth().currentUser?.uid,
              let user = appUser,
              user.journeyActive else { return }
        let nextDay = user.journeyDay + 1
        guard nextDay <= 30 else { return }
        let series = JourneySeries(rawValue: user.journeySeries) ?? .standFirm
        do {
            try await firestoreService.updateJourney(uid: uid, day: nextDay, startDate: nil)
            if nextDay >= 7  { try await firestoreService.awardBadge(uid: uid, badgeType: .journeyWeek1) }
            if nextDay >= 30 {
                try await firestoreService.awardBadge(uid: uid, badgeType: .journeyComplete)
                try await firestoreService.completeJourney(uid: uid, series: series)
                completedJourneySeries = series
                showJourneyComplete = true
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Journey series the user can start (premium gets all, free gets first only)
    var availableJourneys: [JourneySeries] {
        let completed = Set(appUser?.completedJourneys ?? [])
        if isPremium {
            return JourneySeries.allCases
        } else {
            // Free tier: only Stand Firm if not completed
            return completed.contains(JourneySeries.standFirm.rawValue) ? [] : [.standFirm]
        }
    }

    var currentJourneySeries: JourneySeries {
        JourneySeries(rawValue: appUser?.journeySeries ?? "") ?? .standFirm
    }

    // MARK: - Helpers
    var isPremium: Bool { appUser?.isPremium ?? false }
    var currentStreak: Int { appUser?.currentStreak ?? 0 }
    var displayName: String { appUser?.displayName ?? Auth.auth().currentUser?.displayName ?? "Warrior" }
    var colorScheme: SwiftUI.ColorScheme? {
        (AppTheme(rawValue: savedTheme) ?? .system).swiftUIColorScheme
    }

    var isAnchorDoneToday: Bool { todayEntry?.anchorCompleted ?? false }
    var isArrowDoneToday: Bool { todayEntry?.arrowCompleted ?? false }
    var isBothDoneToday: Bool { todayEntry?.bothCompleted ?? false }

    var earnedBadges: [BadgeType] {
        (appUser?.badges ?? []).compactMap { BadgeType(rawValue: $0) }
    }

    // MARK: - Drift Insights (computed from driftLogs)

    /// Top drift categories this month, sorted by count descending
    var topDriftCategoriesThisMonth: [(tag: AnchorTag, count: Int)] {
        let cal = Calendar.current
        let now = Date()
        let monthLogs = driftLogs.filter { cal.isDate($0.timestamp, equalTo: now, toGranularity: .month) }
        var counts: [AnchorTag: Int] = [:]
        for log in monthLogs { counts[log.category, default: 0] += 1 }
        return counts.sorted { $0.value > $1.value }.map { (tag: $0.key, count: $0.value) }
    }

    /// Weakest day of week — the day with the most drifts in the last 90 days
    var weakestDayOfWeek: String? {
        let cutoff = Calendar.current.date(byAdding: .day, value: -90, to: Date()) ?? Date()
        let recentDrifts = driftLogs.filter { $0.timestamp >= cutoff }
        guard !recentDrifts.isEmpty else { return nil }
        var dayCounts: [Int: Int] = [:]
        for log in recentDrifts {
            let weekday = Calendar.current.component(.weekday, from: log.timestamp)
            dayCounts[weekday, default: 0] += 1
        }
        guard let weakest = dayCounts.max(by: { $0.value < $1.value }) else { return nil }
        let dayNames = ["", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        let index = weakest.key
        guard index >= 1, index <= 7 else { return nil }
        return dayNames[index]
    }

    /// 90-day trend: drifts per week, returns recent 12 weeks
    var driftWeeklyTrend: [Int] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        // Build 12 week buckets by actual date ranges (avoids year boundary issues)
        return (0..<12).reversed().map { offset in
            let weekEnd = cal.date(byAdding: .weekOfYear, value: -offset, to: today)!
            let weekStart = cal.date(byAdding: .day, value: -7, to: weekEnd)!
            return driftLogs.filter { $0.timestamp >= weekStart && $0.timestamp < weekEnd }.count
        }
    }

    /// Whether drifts are trending up or down (comparing last 4 weeks to previous 4)
    var driftTrending: DriftTrend {
        let trend = driftWeeklyTrend
        guard trend.count >= 8 else { return .stable }
        let recent4 = trend.suffix(4).reduce(0, +)
        let previous4 = trend.dropLast(4).suffix(4).reduce(0, +)
        if recent4 < previous4 { return .down }
        if recent4 > previous4 { return .up }
        return .stable
    }

    /// Positive reinforcement: tag the user has been clean of for N weeks
    var accountabilityStreaks: [(tag: AnchorTag, weeks: Int)] {
        let cal = Calendar.current
        let now = Date()
        var results: [(AnchorTag, Int)] = []
        for tag in AnchorTag.allCases {
            let lastDrift = driftLogs.first { $0.category == tag }
            if let last = lastDrift {
                let weeks = (cal.dateComponents([.weekOfYear], from: last.timestamp, to: now).weekOfYear ?? 0)
                if weeks >= 2 {
                    results.append((tag, weeks))
                }
            }
        }
        return results.sorted { $0.1 > $1.1 }
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

// MARK: - DriftTrend
enum DriftTrend {
    case up, down, stable

    var label: String {
        switch self {
        case .up:     return "Trending up"
        case .down:   return "Trending down"
        case .stable: return "Stable"
        }
    }

    var icon: String {
        switch self {
        case .up:     return "arrow.up.right"
        case .down:   return "arrow.down.right"
        case .stable: return "minus"
        }
    }

    var color: String {
        switch self {
        case .up:     return "BrandDanger"
        case .down:   return "BrandArrow"
        case .stable: return "TextSecondary"
        }
    }
}
