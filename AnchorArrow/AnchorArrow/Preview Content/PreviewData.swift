// PreviewData.swift
// Sample data + preview providers for SwiftUI canvas

import SwiftUI
import Firebase

// MARK: - Preview Environment Setup
extension View {
    func withPreviewEnvironment() -> some View {
        self
            .environmentObject(PreviewData.authManager)
            .environmentObject(PreviewData.userStore)
            .environmentObject(PreviewData.storeKitManager)
            .environmentObject(PreviewData.notificationManager)
            .preferredColorScheme(.dark)
    }
}

// MARK: - Preview Data Factory
enum PreviewData {
    static let authManager: AuthManager = {
        let manager = AuthManager()
        return manager
    }()

    static let userStore: UserStore = {
        let store = UserStore()
        store.appUser = sampleUser
        store.todayEntry = sampleTodayEntry
        store.recentEntries = sampleRecentEntries
        store.driftLogs = sampleDriftLogs
        store.hasCompletedOnboarding = true
        return store
    }()

    static let storeKitManager = StoreKitManager()
    static let notificationManager = NotificationManager()

    // MARK: - Sample User
    static let sampleUser = AppUser(
        uid: "preview_uid_001",
        email: "warrior@example.com",
        displayName: "Joshua",
        isPremium: false,
        joinDate: Calendar.current.date(byAdding: .day, value: -45, to: Date())!,
        currentStreak: 12,
        longestStreak: 18,
        totalAnchorDays: 38,
        totalArrowDays: 31,
        badges: [
            BadgeType.firstDay.rawValue,
            BadgeType.threeDays.rawValue,
            BadgeType.sevenDays.rawValue,
            BadgeType.anchorWarrior.rawValue,
            BadgeType.firstAnchor.rawValue,
            BadgeType.bothComplete.rawValue
        ],
        journeyActive: true,
        journeyDay: 8,
        journeyStartDate: Calendar.current.date(byAdding: .day, value: -8, to: Date()),
        notificationsEnabled: true,
        morningReminderHour: 7,
        eveningReminderHour: 20,
        theme: .system,
        lastEntryDate: Date()
    )

    // MARK: - Sample Today Entry
    static let sampleTodayEntry = DailyEntry(
        date: Date(),
        dateString: Date().entryDateString,
        anchorCompleted: true,
        anchorPromptId: "anchor_001",
        anchorReflection: "I noticed pride pulling at me this morning — thinking my way is best. I reject the lie that I don't need input from others. Christ himself was humble.",
        anchorTags: [.pride, .selfReliance],
        anchorCompletedAt: Calendar.current.date(byAdding: .hour, value: -4, to: Date()),
        arrowCompleted: false
    )

    // MARK: - Sample Recent Entries (last 14 days)
    static let sampleRecentEntries: [DailyEntry] = {
        (0..<14).compactMap { offset -> DailyEntry? in
            let date = Calendar.current.date(byAdding: .day, value: -offset, to: Date())!
            let doAnchor = offset != 3 && offset != 7  // miss a couple days
            let doArrow = offset != 3 && offset != 7 && offset != 10
            guard doAnchor || doArrow else { return nil }

            return DailyEntry(
                date: date,
                dateString: date.entryDateString,
                anchorCompleted: doAnchor,
                anchorPromptId: "anchor_\(offset % 5 + 1)",
                anchorReflection: "Reflection for day -\(offset)",
                anchorTags: offset % 3 == 0 ? [.temptation] : [.pride],
                arrowCompleted: doArrow,
                arrowPromptId: "arrow_\(offset % 4 + 1)",
                arrowReflection: "Arrow reflection for day -\(offset)",
                arrowRole: offset % 2 == 0 ? .servantLeader : .prayerWarrior
            )
        }
    }()

    // MARK: - Sample Drift Logs
    static let sampleDriftLogs: [DriftLog] = [
        DriftLog(
            timestamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!,
            category: .temptation,
            customCategory: nil,
            note: "Scroll spiral on phone, late night."
        ),
        DriftLog(
            timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            category: .pride,
            customCategory: nil,
            note: "Dismissed my wife's suggestion without really listening."
        ),
        DriftLog(
            timestamp: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
            category: .anger,
            customCategory: nil,
            note: "Lost it over something small. Spoke too harshly."
        )
    ]

    // MARK: - Sample Circle
    static let sampleCircle = Circle(
        name: "The Remnant",
        inviteCode: "RMNT42",
        creatorId: "preview_uid_001",
        memberIds: ["preview_uid_001", "user_002", "user_003", "user_004"],
        createdAt: Calendar.current.date(byAdding: .day, value: -20, to: Date())!
    )

    // MARK: - Sample Posts
    static let samplePosts: [CirclePost] = [
        CirclePost(
            circleId: "circle_001",
            authorId: "user_002",
            authorName: "Marcus",
            content: "Anchored through a huge temptation this morning. The prayer audio helped — I literally heard it before things got bad.",
            type: .anchor,
            isAnonymous: false,
            timestamp: Calendar.current.date(byAdding: .hour, value: -3, to: Date())!,
            reactions: ["🔥": 3]
        ),
        CirclePost(
            circleId: "circle_001",
            authorId: "preview_uid_001",
            authorName: "Joshua",
            content: "Served my family tonight without being asked. Small thing — but it felt like obedience.",
            type: .arrow,
            isAnonymous: false,
            timestamp: Calendar.current.date(byAdding: .hour, value: -8, to: Date())!,
            reactions: ["🔥": 2]
        ),
        CirclePost(
            circleId: "circle_001",
            authorId: "user_003",
            authorName: "A brother",
            content: "Struggling with my thought life this week. Drift logging daily — it's working but the battle is real. Pray for me.",
            type: .prayer,
            isAnonymous: true,
            timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            reactions: ["🔥": 5]
        )
    ]

    // MARK: - Sample Journey Days
    static var sampleJourneyDays: [JourneyDay] {
        PromptLibrary.journeyDays().enumerated().map { index, day in
            var d = day
            d.isUnlocked = index <= 8
            d.completedDate = index < 8 ? Calendar.current.date(byAdding: .day, value: index - 8, to: Date()) : nil
            return d
        }
    }
}

// MARK: - Preview Providers

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .withPreviewEnvironment()
    }
}

struct AnchorView_Previews: PreviewProvider {
    static var previews: some View {
        AnchorView()
            .withPreviewEnvironment()
    }
}

struct ArrowView_Previews: PreviewProvider {
    static var previews: some View {
        ArrowView()
            .withPreviewEnvironment()
    }
}

struct DriftLogView_Previews: PreviewProvider {
    static var previews: some View {
        DriftLogView()
            .withPreviewEnvironment()
    }
}



struct OnboardingPage1_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingPage1()
            .background(Color("BackgroundPrimary"))
            .withPreviewEnvironment()
    }
}

struct PremiumUpsellView_Previews: PreviewProvider {
    static var previews: some View {
        PremiumUpsellView(reason: "Access deeper teaching packs")
            .withPreviewEnvironment()
    }
}

struct TreeArrowProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color("BackgroundPrimary")
            TreeArrowProgressView(
                anchorProgress: 0.7,
                arrowProgress: 0.6,
                animate: true,
                anchorCompleted: true,
                arrowCompleted: false
            )
            .frame(height: 300)
        }
    }
}
