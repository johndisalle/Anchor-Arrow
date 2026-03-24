// ProgressView.swift
// Stats — streak calendar, badge gallery, weekly/monthly summary

import SwiftUI
import FirebaseAuth

struct ProgressView: View {
    @EnvironmentObject var userStore: UserStore
    @State private var selectedMonth = Date()
    @State private var calendarEntries: [String: DailyEntry] = [:]

    private let calendar = Calendar.current
    private let firestoreService = FirestoreService.shared

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                if userStore.isLoading && userStore.appUser == nil {
                    progressSkeleton
                } else {
                VStack(spacing: 24) {

                    // Streak header
                    streakHeroSection

                    // Stats Grid
                    statsGridSection

                    // Journal History (Premium)
                    if userStore.isPremium {
                        journalHistoryLink
                    }

                    // Drift Insights (Premium)
                    if userStore.isPremium {
                        driftInsightsSection
                    }

                    // Streak Calendar
                    calendarSection

                    // Badge Gallery
                    badgeGallerySection

                    // Weekly Accountability Report (Premium)
                    if userStore.isPremium {
                        weeklyAccountabilityReport
                    }

                    // Weekly Summary
                    weeklySummarySection

                    // Drift History
                    if !userStore.driftLogs.isEmpty {
                        driftHistorySection
                    }

                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                }
            }
            .refreshable {
                guard let uid = Auth.auth().currentUser?.uid else { return }
                await userStore.loadUserData(uid: uid)
                loadCalendarEntries()
            }
            .background(Color("BackgroundPrimary").ignoresSafeArea())
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("BackgroundPrimary"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .onAppear { loadCalendarEntries() }
        .onChange(of: selectedMonth) { loadCalendarEntries() }
    }

    // MARK: - Streak Hero
    // MARK: - Skeleton
    private var progressSkeleton: some View {
        VStack(spacing: 24) {
            // Streak hero placeholder
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("CardBackground"))
                .frame(height: 160)

            // Stats grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(0..<4, id: \.self) { _ in
                    SkeletonCard(height: 80)
                }
            }

            // Calendar placeholder
            SkeletonCard(height: 260)

            // Badge gallery placeholder
            SkeletonCard(height: 120)

            Spacer(minLength: 100)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .shimmer()
    }

    private var streakHeroSection: some View {
        ZStack {
            LinearGradient(
                colors: [Color("BrandAnchor"), Color("BrandArrow")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .cornerRadius(20)

            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(userStore.currentStreak)")
                        .font(.system(size: 56, weight: .heavy))
                        .foregroundColor(.white)
                    Text("Day Streak")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))

                    if userStore.currentStreak > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                            Text("Longest: \(userStore.appUser?.longestStreak ?? 0) days")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }

                    // Grace day status (premium only)
                    if userStore.isPremium {
                        HStack(spacing: 4) {
                            Image(systemName: userStore.appUser?.hasGraceDayAvailable == true
                                  ? "heart.fill" : "heart.slash")
                                .font(.system(size: 11))
                                .foregroundColor(userStore.appUser?.hasGraceDayAvailable == true
                                                 ? .green : .white.opacity(0.4))
                            Text(userStore.appUser?.hasGraceDayAvailable == true
                                 ? "Grace day available"
                                 : "Grace day used")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
                Spacer()

                // Circular progress
                ZStack {
                    SwiftUI.Circle()
                        .stroke(.white.opacity(0.2), lineWidth: 8)
                        .frame(width: 90, height: 90)
                    SwiftUI.Circle()
                        .trim(from: 0, to: streakProgress)
                        .stroke(.white, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 90, height: 90)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeOut(duration: 1.0), value: streakProgress)

                    VStack(spacing: 0) {
                        Text("\(Int(streakProgress * 100))%")
                            .font(.system(size: 16, weight: .heavy))
                            .foregroundColor(.white)
                        Text("to goal")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .padding(24)
        }
    }

    // MARK: - Stats Grid
    private var statsGridSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            StatsCard(
                title: "Total Anchors",
                value: "\(userStore.appUser?.totalAnchorDays ?? 0)",
                subtitle: "Morning completions",
                icon: "sunrise.circle.fill",
                color: "BrandAnchor"
            )
            StatsCard(
                title: "Total Arrows",
                value: "\(userStore.appUser?.totalArrowDays ?? 0)",
                subtitle: "Evening completions",
                icon: "arrow.up.right.circle.fill",
                color: "BrandArrow"
            )
            StatsCard(
                title: "Drift Logs",
                value: "\(userStore.driftLogs.count)",
                subtitle: "Moments anchored",
                icon: "exclamationmark.shield.fill",
                color: "BrandWarning"
            )
            StatsCard(
                title: "Badges",
                value: "\(userStore.earnedBadges.count)",
                subtitle: "of \(BadgeType.allCases.count) earned",
                icon: "star.fill",
                color: "BrandGold"
            )
        }
    }

    // MARK: - Journal History (Premium)
    private var journalHistoryLink: some View {
        NavigationLink {
            JournalHistoryView()
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("BrandAnchor").opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: "book.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color("BrandAnchor"))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Journal History")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color("TextPrimary"))
                    Text("Browse and search past reflections")
                        .font(.system(size: 12))
                        .foregroundColor(Color("TextSecondary"))
                }

                Spacer()

                HStack(spacing: 4) {
                    Text("PREMIUM")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundColor(Color("BrandGold"))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color("TextSecondary"))
                }
            }
            .padding(16)
            .background(Color("CardBackground"))
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Weekly Accountability Report (Premium)
    private var weeklyAccountabilityReport: some View {
        let weekEntries = lastSevenDays
        let anchors = weekEntries.filter { $0.1?.anchorCompleted ?? false }.count
        let arrows = weekEntries.filter { $0.1?.arrowCompleted ?? false }.count
        let fullDays = weekEntries.filter { $0.1?.bothCompleted ?? false }.count

        // Drift summary for the week
        let weekStart = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let weekDrifts = userStore.driftLogs.filter { $0.timestamp >= weekStart }
        let driftCount = weekDrifts.count

        // Top drift category this week
        var driftCounts: [String: Int] = [:]
        for log in weekDrifts {
            driftCounts[log.displayName, default: 0] += 1
        }
        let topDrift = driftCounts.max(by: { $0.value < $1.value })

        // Most common Arrow role this week
        let arrowEntries = weekEntries.compactMap { $0.1 }.filter { $0.arrowCompleted }
        var roleCounts: [ArrowRole: Int] = [:]
        for entry in arrowEntries { roleCounts[entry.arrowRole, default: 0] += 1 }
        let topRole = roleCounts.max(by: { $0.value < $1.value })

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color("BrandAnchor"))
                Text("Weekly Report")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
                Spacer()
                Text("PREMIUM")
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundColor(Color("BrandGold"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color("BrandGold").opacity(0.15))
                    .cornerRadius(6)
            }

            // Summary sentence
            VStack(alignment: .leading, spacing: 8) {
                Text(weeklySummaryText(anchors: anchors, arrows: arrows, fullDays: fullDays, driftCount: driftCount, topDrift: topDrift, topRole: topRole))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color("TextPrimary"))
                    .lineSpacing(4)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color("BrandAnchor").opacity(0.06))
            .cornerRadius(12)

            // Quick stats row
            HStack(spacing: 0) {
                WeeklyReportStat(value: "\(anchors)/7", label: "Anchors", icon: "sunrise.fill", color: "BrandAnchor")
                Divider().frame(height: 36)
                WeeklyReportStat(value: "\(arrows)/7", label: "Arrows", icon: "arrow.up.right", color: "BrandArrow")
                Divider().frame(height: 36)
                WeeklyReportStat(value: "\(fullDays)/7", label: "Full Days", icon: "checkmark.circle.fill", color: "BrandGold")
                Divider().frame(height: 36)
                WeeklyReportStat(value: "\(driftCount)", label: "Drifts", icon: "exclamationmark.shield.fill", color: "BrandWarning")
            }

            // Encouragement
            if fullDays == 7 {
                HStack(spacing: 8) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color("BrandGold"))
                    Text("Perfect week. Every day anchored and aimed. Stand firm, brother.")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color("BrandGold"))
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color("BrandGold").opacity(0.08))
                .cornerRadius(12)
            } else if fullDays >= 5 {
                HStack(spacing: 8) {
                    Image(systemName: "hand.thumbsup.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color("BrandArrow"))
                    Text("Strong week. \(7 - fullDays) day\(fullDays == 6 ? "" : "s") to sharpen. Keep pressing.")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color("BrandArrow"))
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color("BrandArrow").opacity(0.08))
                .cornerRadius(12)
            } else if fullDays > 0 {
                HStack(spacing: 8) {
                    Image(systemName: "figure.stand")
                        .font(.system(size: 14))
                        .foregroundColor(Color("BrandAnchor"))
                    Text("You showed up \(fullDays) day\(fullDays == 1 ? "" : "s"). That's \(fullDays) more than quitting. Build on it.")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color("BrandAnchor"))
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color("BrandAnchor").opacity(0.08))
                .cornerRadius(12)
            }
        }
        .padding(20)
        .background(Color("CardBackground"))
        .cornerRadius(20)
    }

    private func weeklySummaryText(anchors: Int, arrows: Int, fullDays: Int, driftCount: Int, topDrift: (key: String, value: Int)?, topRole: (key: ArrowRole, value: Int)?) -> String {
        var parts: [String] = []
        parts.append("This week you anchored \(anchors)/7 days and aimed \(arrows)/7 evenings.")

        if driftCount > 0, let top = topDrift {
            if driftCount == 1 {
                parts.append("You logged 1 drift (\(top.key)).")
            } else if top.value == driftCount {
                parts.append("You drifted \(driftCount) times — all \(top.key).")
            } else {
                parts.append("You drifted \(driftCount) times, mostly \(top.key).")
            }
        } else if driftCount == 0 {
            parts.append("Zero drifts logged — clean week.")
        }

        if let role = topRole {
            parts.append("Your Arrow focus was \(role.key.displayName).")
        }

        return parts.joined(separator: " ")
    }

    // MARK: - Drift Insights (Premium)
    private var driftInsightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color("BrandWarning"))
                Text("Drift Insights")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
                Spacer()
                Text("PREMIUM")
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundColor(Color("BrandGold"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color("BrandGold").opacity(0.15))
                    .cornerRadius(6)
            }

            // Empty state
            if userStore.driftLogs.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color("BrandArrow"))
                    Text("No drift data yet. Insights will appear as you log drift moments.")
                        .font(.system(size: 13))
                        .foregroundColor(Color("TextSecondary"))
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color("BrandArrow").opacity(0.06))
                .cornerRadius(12)
            }

            // Top drift categories bar chart
            let topCategories = userStore.topDriftCategoriesThisMonth
            if !topCategories.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Top Categories This Month")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color("TextSecondary"))

                    let maxCount = topCategories.first?.count ?? 1
                    ForEach(topCategories.prefix(5), id: \.tag) { item in
                        HStack(spacing: 10) {
                            Text(item.tag.displayName)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color("TextPrimary"))
                                .frame(width: 90, alignment: .leading)

                            GeometryReader { geo in
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color("BrandWarning").opacity(0.7))
                                    .frame(width: geo.size.width * CGFloat(item.count) / CGFloat(maxCount))
                            }
                            .frame(height: 16)

                            Text("\(item.count)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color("TextSecondary"))
                                .frame(width: 24, alignment: .trailing)
                        }
                    }
                }
            }

            // Weakest day
            if let weakestDay = userStore.weakestDayOfWeek {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color("BrandWarning"))
                    Text("You drift most on \(weakestDay)s")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color("TextPrimary"))
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color("BrandWarning").opacity(0.08))
                .cornerRadius(12)
            }

            // 90-day trend (only show with data)
            if !userStore.driftLogs.isEmpty {
                let trend = userStore.driftTrending
                HStack(spacing: 8) {
                    Image(systemName: trend.icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(trend.color))
                    Text("90-day drift trend: \(trend.label.lowercased())")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color("TextPrimary"))
                }
            }

            // Positive reinforcement — accountability streaks
            let streaks = userStore.accountabilityStreaks
            if let best = streaks.first {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color("BrandArrow"))
                    Text("Accountable on \(best.tag.displayName) for \(best.weeks) weeks")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color("BrandArrow"))
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color("BrandArrow").opacity(0.08))
                .cornerRadius(12)
            }
        }
        .padding(20)
        .background(Color("CardBackground"))
        .cornerRadius(20)
    }

    // MARK: - Calendar
    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Streak Calendar")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
                Spacer()
                // Month navigation
                HStack(spacing: 16) {
                    Button {
                        if let prev = calendar.date(byAdding: .month, value: -1, to: selectedMonth) {
                            selectedMonth = prev
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color("BrandAnchor"))
                    }
                    Text(selectedMonth.formatted(.dateTime.month(.wide).year()))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color("TextPrimary"))
                        .frame(width: 120, alignment: .center)
                    Button {
                        if let next = calendar.date(byAdding: .month, value: 1, to: selectedMonth),
                           next <= Date() {
                            selectedMonth = next
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color("BrandAnchor"))
                    }
                }
            }

            StreakCalendarGrid(
                month: selectedMonth,
                entries: calendarEntries
            )
        }
        .padding(20)
        .background(Color("CardBackground"))
        .cornerRadius(20)
    }

    // MARK: - Badge Gallery
    private var badgeGallerySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Badge Gallery")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color("TextPrimary"))

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 4),
                spacing: 16
            ) {
                ForEach(BadgeType.allCases) { badgeType in
                    let earned = userStore.earnedBadges.contains(badgeType)
                    BadgeGridCell(badgeType: badgeType, isEarned: earned)
                }
            }

            Text("\(userStore.earnedBadges.count) of \(BadgeType.allCases.count) badges earned")
                .font(.system(size: 13))
                .foregroundColor(Color("TextSecondary"))
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(20)
        .background(Color("CardBackground"))
        .cornerRadius(20)
    }

    // MARK: - Weekly Summary
    private var weeklySummarySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("This Week")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color("TextPrimary"))

            let weekEntries = lastSevenDays
            HStack(spacing: 8) {
                ForEach(weekEntries, id: \.0) { (dateStr, entry) in
                    WeekDayDot(
                        dayLetter: dayLetter(from: dateStr),
                        anchorDone: entry?.anchorCompleted ?? false,
                        arrowDone: entry?.arrowCompleted ?? false,
                        isToday: dateStr == Date().entryDateString
                    )
                }
            }

            HStack(spacing: 20) {
                WeekStatLabel(
                    value: weekEntries.filter { $0.1?.anchorCompleted ?? false }.count,
                    of: 7,
                    label: "Anchors",
                    color: "BrandAnchor"
                )
                WeekStatLabel(
                    value: weekEntries.filter { $0.1?.arrowCompleted ?? false }.count,
                    of: 7,
                    label: "Arrows",
                    color: "BrandArrow"
                )
                WeekStatLabel(
                    value: weekEntries.filter { $0.1?.bothCompleted ?? false }.count,
                    of: 7,
                    label: "Full Days",
                    color: "BrandGold"
                )
            }
        }
        .padding(20)
        .background(Color("CardBackground"))
        .cornerRadius(20)
    }

    // MARK: - Drift History
    private var driftHistorySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Drift Timeline")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
                Spacer()
                Text("\(userStore.driftLogs.count) total")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color("TextSecondary"))
            }

            ForEach(userStore.driftLogs.prefix(10)) { log in
                HStack(spacing: 12) {
                    // Timeline dot + line
                    VStack(spacing: 0) {
                        SwiftUI.Circle()
                            .fill(Color("BrandWarning"))
                            .frame(width: 10, height: 10)
                        Rectangle()
                            .fill(Color("BrandWarning").opacity(0.2))
                            .frame(width: 2)
                    }
                    .frame(width: 10)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: log.displayIcon)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color("BrandWarning"))
                            Text(log.displayName)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color("TextPrimary"))
                            Spacer()
                            Text(log.timestamp.timeAgo)
                                .font(.system(size: 11))
                                .foregroundColor(Color("TextSecondary"))
                        }
                        if !log.note.isEmpty {
                            Text(log.note)
                                .font(.system(size: 13))
                                .foregroundColor(Color("TextSecondary"))
                                .lineLimit(2)
                        }
                    }
                }
                .padding(.vertical, 6)
            }

            if userStore.driftLogs.count > 10 {
                Text("\(userStore.driftLogs.count - 10) more entries")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color("TextSecondary"))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(20)
        .background(Color("CardBackground"))
        .cornerRadius(20)
    }

    // MARK: - Helpers
    private var streakProgress: Double {
        let target = Double(kJourneyDays)
        return min(1.0, Double(userStore.currentStreak) / target)
    }

    private var lastSevenDays: [(String, DailyEntry?)] {
        (0..<7).reversed().map { offset -> (String, DailyEntry?) in
            let date = Calendar.current.date(byAdding: .day, value: -offset, to: Date())!
            let dateStr = date.entryDateString
            return (dateStr, userStore.recentEntries.first { $0.dateString == dateStr })
        }
    }

    private func dayLetter(from dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return "?" }
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEEE"
        return dayFormatter.string(from: date)
    }

    private func loadCalendarEntries() {
        // Map recentEntries into a dict for O(1) lookup
        calendarEntries = Dictionary(
            uniqueKeysWithValues: userStore.recentEntries.map { ($0.dateString, $0) }
        )
    }
}

// MARK: - StatsCard
struct StatsCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(Color(color))

            Text(value)
                .font(.system(size: 30, weight: .heavy))
                .foregroundColor(Color("TextPrimary"))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(Color("TextSecondary"))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("CardBackground"))
        .cornerRadius(16)
    }
}

// MARK: - StreakCalendarGrid
struct StreakCalendarGrid: View {
    let month: Date
    let entries: [String: DailyEntry]

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
    private let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        VStack(spacing: 6) {
            // Day labels
            HStack {
                ForEach(dayLabels, id: \.self) { label in
                    Text(label)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color("TextSecondary"))
                        .frame(maxWidth: .infinity)
                }
            }

            // Day cells
            LazyVGrid(columns: columns, spacing: 6) {
                // Leading empty cells
                ForEach(0..<firstWeekdayOffset, id: \.self) { _ in
                    Color.clear.frame(height: 32)
                }

                // Day cells
                ForEach(daysInMonth, id: \.self) { day in
                    let dateStr = dateString(for: day)
                    let entry = entries[dateStr]
                    let isToday = dateStr == Date().entryDateString
                    let isFuture = dateStr > Date().entryDateString

                    CalendarDayCell(
                        day: day,
                        anchorDone: entry?.anchorCompleted ?? false,
                        arrowDone: entry?.arrowCompleted ?? false,
                        isToday: isToday,
                        isFuture: isFuture
                    )
                }
            }
        }
    }

    private var firstWeekdayOffset: Int {
        let components = calendar.dateComponents([.year, .month], from: month)
        guard let firstDay = calendar.date(from: components) else { return 0 }
        let weekday = calendar.component(.weekday, from: firstDay)
        return weekday - 1  // Sunday = 1, so offset = 0
    }

    private var daysInMonth: [Int] {
        guard let range = calendar.range(of: .day, in: .month, for: month) else { return [] }
        return Array(range)
    }

    private func dateString(for day: Int) -> String {
        var components = calendar.dateComponents([.year, .month], from: month)
        components.day = day
        guard let date = calendar.date(from: components) else { return "" }
        return date.entryDateString
    }
}

struct CalendarDayCell: View {
    let day: Int
    let anchorDone: Bool
    let arrowDone: Bool
    let isToday: Bool
    let isFuture: Bool

    private var bgColor: Color {
        if isFuture { return Color("CardBackground") }
        if anchorDone && arrowDone { return Color("BrandGold").opacity(0.8) }
        if anchorDone { return Color("BrandAnchor").opacity(0.7) }
        if arrowDone  { return Color("BrandArrow").opacity(0.7) }
        return Color("CardBackground")
    }

    private var accessibilityDescription: String {
        if isFuture { return "Day \(day)" }
        if anchorDone && arrowDone { return "Day \(day), anchor and arrow complete" }
        if anchorDone { return "Day \(day), anchor complete" }
        if arrowDone  { return "Day \(day), arrow complete" }
        return "Day \(day), incomplete"
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: 6)
                .fill(bgColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isToday ? Color("BrandAnchor") : Color.clear, lineWidth: 2)
                )

            Text("\(day)")
                .font(.system(size: 12, weight: isToday ? .heavy : .medium))
                .foregroundColor(isFuture ? Color("TextSecondary").opacity(0.3) : .white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Small symbol in corner — gives colorblind users a non-color cue
            if !isFuture && (anchorDone || arrowDone) {
                Image(systemName: anchorDone && arrowDone ? "checkmark"
                                  : anchorDone            ? "sunrise.fill"
                                                          : "arrow.up.right")
                    .font(.system(size: 6, weight: .bold))
                    .foregroundColor(.white.opacity(0.85))
                    .padding(2)
            }
        }
        .frame(height: 32)
        .accessibilityLabel(accessibilityDescription)
    }
}

// MARK: - WeekDayDot
struct WeekDayDot: View {
    let dayLetter: String
    let anchorDone: Bool
    let arrowDone: Bool
    let isToday: Bool

    var body: some View {
        VStack(spacing: 5) {
            Text(dayLetter)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(isToday ? Color("BrandAnchor") : Color("TextSecondary"))

            ZStack {
                // Background
                SwiftUI.Circle()
                    .fill(anchorDone && arrowDone ? Color("BrandGold")
                          : anchorDone ? Color("BrandAnchor")
                          : arrowDone  ? Color("BrandArrow")
                          : Color("CardBackground"))
                    .frame(width: 30, height: 30)
                    .overlay(
                        SwiftUI.Circle().stroke(isToday ? Color("BrandAnchor") : Color.clear, lineWidth: 2)
                    )

                if anchorDone || arrowDone {
                    if anchorDone && arrowDone {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    } else if anchorDone {
                        Image(systemName: "sunrise.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        CrossedArrowsView(color: .white)
                            .frame(width: 20, height: 13)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - WeekStatLabel
struct WeekStatLabel: View {
    let value: Int
    let of: Int
    let label: String
    let color: String

    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)/\(of)")
                .font(.system(size: 18, weight: .heavy))
                .foregroundColor(Color(color))
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Color("TextSecondary"))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - BadgeGridCell
struct BadgeGridCell: View {
    let badgeType: BadgeType
    let isEarned: Bool

    @State private var showDetail = false

    var body: some View {
        Button {
            showDetail = true
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    SwiftUI.Circle()
                        .fill(isEarned ? badgeType.color.opacity(0.15) : Color("CardBackground"))
                        .frame(width: 52, height: 52)
                    Image(systemName: badgeType.icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(isEarned ? badgeType.color : Color("TextSecondary").opacity(0.3))

                    if !isEarned {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color("TextSecondary").opacity(0.4))
                            .offset(x: 16, y: 16)
                    }
                }

                Text(badgeType.name)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(isEarned ? Color("TextPrimary") : Color("TextSecondary").opacity(0.4))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(height: 28)
            }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showDetail) {
            BadgeDetailSheet(badgeType: badgeType, isEarned: isEarned)
        }
    }
}

// MARK: - Badge Detail Sheet
struct BadgeDetailSheet: View {
    let badgeType: BadgeType
    let isEarned: Bool
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Capsule()
                .fill(Color("TextSecondary").opacity(0.3))
                .frame(width: 36, height: 4)
                .padding(.top, 12)

            ZStack {
                SwiftUI.Circle()
                    .fill(isEarned ? badgeType.color.opacity(0.15) : Color("CardBackground"))
                    .frame(width: 100, height: 100)
                Image(systemName: badgeType.icon)
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundColor(isEarned ? badgeType.color : Color("TextSecondary").opacity(0.3))
            }

            VStack(spacing: 8) {
                Text(badgeType.name)
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundColor(isEarned ? Color("TextPrimary") : Color("TextSecondary"))

                Text(badgeType.description)
                    .font(.system(size: 15))
                    .foregroundColor(Color("TextSecondary"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)

                if !isEarned {
                    Text("Not yet earned")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color("TextSecondary"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color("CardBackground"))
                        .cornerRadius(10)
                        .padding(.top, 4)
                }
            }

            Button("Close") { dismiss() }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color("BrandAnchor"))
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .background(Color("BackgroundPrimary"))
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }
}

// MARK: - WeeklyReportStat
struct WeeklyReportStat: View {
    let value: String
    let label: String
    let icon: String
    let color: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(color))
            Text(value)
                .font(.system(size: 16, weight: .heavy))
                .foregroundColor(Color("TextPrimary"))
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(Color("TextSecondary"))
        }
        .frame(maxWidth: .infinity)
    }
}
