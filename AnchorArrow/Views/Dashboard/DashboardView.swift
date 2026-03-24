// DashboardView.swift
// Home screen — tree/arrow visual, streak, today's status, badges

import SwiftUI
import FirebaseAuth

struct DashboardView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var storeKitManager: StoreKitManager
    @State private var showJourney = false
    @State private var animateTree = false
    @State private var showPremiumUpsell = false
    @State private var greeting = ""

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                if userStore.isLoading && userStore.appUser == nil {
                    dashboardSkeleton
                } else {
                VStack(spacing: 24) {

                    // Greeting Header
                    headerSection

                    // Central Tree + Arrow Visual
                    TreeArrowProgressView(
                        anchorProgress: anchorProgress,
                        arrowProgress: arrowProgress,
                        streak: userStore.currentStreak,
                        animate: animateTree
                    )
                    .frame(height: 280)
                    .padding(.horizontal, 24)

                    // Today's Status Cards
                    todayStatusSection

                    // Streak + Stats Row
                    streakStatsSection

                    // Recent Badges
                    if !userStore.earnedBadges.isEmpty {
                        recentBadgesSection
                    }

                    // Journey CTA
                    journeyCTASection

                    Spacer(minLength: 100) // tab bar clearance
                }
                .padding(.top, 8)
                }
            }
            .refreshable {
                guard let uid = Auth.auth().currentUser?.uid else { return }
                await userStore.loadUserData(uid: uid)
            }
            .background(Color("BackgroundPrimary").ignoresSafeArea())
            .navigationTitle("Anchor & Arrow")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("BackgroundPrimary"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color("BrandAnchor"))
                            .accessibilityLabel("Profile and Settings")
                    }
                }
            }
        }
        .sheet(isPresented: $showJourney) {
            JourneyView()
        }
        .sheet(isPresented: $showPremiumUpsell) {
            PremiumUpsellView(reason: "Unlock all guided journeys")
        }
        .onAppear {
            updateGreeting()
            withAnimation(.easeOut(duration: 1.2).delay(0.3)) {
                animateTree = true
            }
        }
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(greeting)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color("TextSecondary"))
                    Text(userStore.displayName)
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .foregroundColor(Color("TextPrimary"))
                }
                Spacer()
                // Date chip
                VStack(spacing: 2) {
                    Text(Date().formatted(.dateTime.weekday(.wide)))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color("BrandAnchor"))
                    Text(Date().formatted(.dateTime.day()))
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundColor(Color("TextPrimary"))
                    Text(Date().formatted(.dateTime.month(.abbreviated)))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color("TextSecondary"))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color("CardBackground"))
                .cornerRadius(12)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Today is \(Date().formatted(.dateTime.weekday(.wide).month(.wide).day()))")
            }
        }
        .padding(.horizontal, 24)
    }

    private var todayStatusSection: some View {
        HStack(spacing: 14) {
            TodayStatusCard(
                title: "Anchor",
                subtitle: "Morning",
                isComplete: userStore.isAnchorDoneToday,
                color: "BrandAnchor",
                destination: AnyView(AnchorView())
            ) {
                AnchorSymbolView()
                    .frame(width: 24, height: 30)
            }
            TodayStatusCard(
                title: "Arrow",
                subtitle: "Evening",
                isComplete: userStore.isArrowDoneToday,
                color: "BrandArrow",
                destination: AnyView(ArrowView())
            ) {
                SingleArcheryArrowView(color: Color("BrandArrow"))
                    .frame(width: 26, height: 26)
            }
        }
        .padding(.horizontal, 24)
    }

    private var streakStatsSection: some View {
        let streakColor = userStore.currentStreak >= 7 ? "BrandGold" : "BrandAnchor"
        return HStack(spacing: 14) {
            StatPill(value: "\(userStore.currentStreak)", label: "Day Streak",
                     color: streakColor) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(streakColor))
            }
            StatPill(value: "\(userStore.appUser?.totalAnchorDays ?? 0)", label: "Anchors",
                     color: "BrandAnchor") {
                AnchorSymbolView()
                    .frame(width: 20, height: 25)
            }
            StatPill(value: "\(userStore.appUser?.totalArrowDays ?? 0)", label: "Arrows",
                     color: "BrandArrow") {
                SingleArcheryArrowView(color: Color("BrandArrow"))
                    .frame(width: 20, height: 20)
            }
        }
        .padding(.horizontal, 24)
    }

    private var recentBadgesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Badges")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
                Spacer()
                NavigationLink("See All") {
                    ProgressView()
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color("BrandAnchor"))
                .accessibilityLabel("See all badges")
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(userStore.earnedBadges.prefix(8)) { badge in
                        BadgePill(badge: badge)
                    }
                }
            }
        }
        .padding(.horizontal, 24)
    }

    private var journeyCTASection: some View {
        Button {
            // Always let the user view their active journey; only gate starting NEW journeys
            if userStore.appUser?.journeyActive == true || userStore.isPremium || !userStore.availableJourneys.isEmpty {
                showJourney = true
            } else {
                showPremiumUpsell = true
            }
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    SwiftUI.Circle()
                        .fill(Color("BrandArrow").opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: "map.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color("BrandArrow"))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("\(userStore.currentJourneySeries.displayName) Journey")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color("TextPrimary"))
                    Text(userStore.appUser?.journeyActive == true
                         ? "Day \(userStore.appUser?.journeyDay ?? 0) of 30"
                         : "30-day guided plan — start today")
                        .font(.system(size: 13))
                        .foregroundColor(Color("TextSecondary"))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("TextSecondary"))
            }
            .padding(16)
            .background(Color("CardBackground"))
            .cornerRadius(16)
            .padding(.horizontal, 24)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(userStore.appUser?.journeyActive == true
            ? "\(userStore.currentJourneySeries.displayName) Journey, Day \(userStore.appUser?.journeyDay ?? 0) of 30"
            : "\(userStore.currentJourneySeries.displayName) Journey, 30-day guided plan")
        .accessibilityHint("Double tap to open")
    }

    // MARK: - Skeleton
    private var dashboardSkeleton: some View {
        VStack(spacing: 24) {
            // Header placeholder
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color("CardBackground"))
                        .frame(width: 100, height: 14)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color("CardBackground"))
                        .frame(width: 160, height: 24)
                }
                Spacer()
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("CardBackground"))
                    .frame(width: 52, height: 60)
            }
            .padding(.horizontal, 24)

            // Tree placeholder
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("CardBackground"))
                .frame(height: 280)
                .padding(.horizontal, 24)

            // Status cards
            HStack(spacing: 14) {
                SkeletonCard(height: 130)
                SkeletonCard(height: 130)
            }
            .padding(.horizontal, 24)

            // Stats row
            HStack(spacing: 14) {
                SkeletonCard(height: 80)
                SkeletonCard(height: 80)
                SkeletonCard(height: 80)
            }
            .padding(.horizontal, 24)

            // Journey CTA
            SkeletonCard(height: 80)
                .padding(.horizontal, 24)

            Spacer(minLength: 100)
        }
        .padding(.top, 8)
        .shimmer()
    }

    // MARK: - Helpers
    private var anchorProgress: Double {
        let total = max(1, userStore.appUser?.totalAnchorDays ?? 0)
        return min(1.0, Double(total) / 30.0)  // full growth at 30 days
    }

    private var arrowProgress: Double {
        let total = max(1, userStore.appUser?.totalArrowDays ?? 0)
        return min(1.0, Double(total) / 30.0)
    }

    private func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  greeting = "Good morning,"
        case 12..<17: greeting = "Good afternoon,"
        case 17..<21: greeting = "Good evening,"
        default:      greeting = "Standing firm,"
        }
    }
}

// MARK: - TodayStatusCard
struct TodayStatusCard<IncompleteIcon: View>: View {
    let title: String
    let subtitle: String
    let isComplete: Bool
    let color: String
    let destination: AnyView
    @ViewBuilder let incompleteIcon: () -> IncompleteIcon

    var body: some View {
        NavigationLink(destination: destination) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    if isComplete {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.green)
                    } else {
                        incompleteIcon()
                    }
                    Spacer()
                    if isComplete {
                        Text("Done")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.15))
                            .cornerRadius(8)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Color("TextPrimary"))
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(Color("TextSecondary"))
                }

                HStack {
                    Text(isComplete ? "Completed" : "Tap to begin")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(isComplete ? Color.green : Color(color))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(isComplete ? Color.green : Color(color))
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                ZStack {
                    Color("CardBackground")
                    if isComplete {
                        Color.green.opacity(0.05)
                    }
                }
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isComplete ? Color.green.opacity(0.3) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) \(subtitle), \(isComplete ? "completed" : "not yet completed")")
        .accessibilityHint(isComplete ? "Tap to review" : "Tap to begin your \(title.lowercased())")
    }
}

// MARK: - StatPill
struct StatPill<Icon: View>: View {
    let value: String
    let label: String
    let color: String
    @ViewBuilder let iconView: () -> Icon

    var body: some View {
        VStack(spacing: 6) {
            iconView()
            Text(value)
                .font(.system(size: 22, weight: .heavy))
                .foregroundColor(Color("TextPrimary"))
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color("TextSecondary"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color("CardBackground"))
        .cornerRadius(14)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(value) \(label)")
    }
}

// MARK: - BadgePill
struct BadgePill: View {
    let badge: BadgeType

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                SwiftUI.Circle()
                    .fill(badge.color.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: badge.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(badge.color)
            }
            Text(badge.name)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Color("TextSecondary"))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 60)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Badge: \(badge.name)")
    }
}
