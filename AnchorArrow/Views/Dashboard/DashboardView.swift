// DashboardView.swift
// Home screen — tree/arrow visual, streak, today's status, badges

import SwiftUI

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
            .background(Color("BackgroundPrimary").ignoresSafeArea())
            .navigationTitle("Anchor & Arrow")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color("BrandAnchor"))
                    }
                }
            }
        }
        .sheet(isPresented: $showJourney) {
            JourneyView()
        }
        .sheet(isPresented: $showPremiumUpsell) {
            PremiumUpsellView(reason: "Start your Stand Firm Journey")
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
            }
        }
        .padding(.horizontal, 24)
    }

    private var todayStatusSection: some View {
        HStack(spacing: 14) {
            TodayStatusCard(
                icon: "anchor",
                title: "Anchor",
                subtitle: "Morning",
                isComplete: userStore.isAnchorDoneToday,
                color: "BrandAnchor",
                destination: AnyView(AnchorView())
            )
            TodayStatusCard(
                icon: "arrow.up.right.circle.fill",
                title: "Arrow",
                subtitle: "Evening",
                isComplete: userStore.isArrowDoneToday,
                color: "BrandArrow",
                destination: AnyView(ArrowView())
            )
        }
        .padding(.horizontal, 24)
    }

    private var streakStatsSection: some View {
        HStack(spacing: 14) {
            StatPill(
                value: "\(userStore.currentStreak)",
                label: "Day Streak",
                icon: "flame.fill",
                color: userStore.currentStreak >= 7 ? "BrandGold" : "BrandAnchor"
            )
            StatPill(
                value: "\(userStore.appUser?.totalAnchorDays ?? 0)",
                label: "Anchors",
                icon: "anchor",
                color: "BrandAnchor"
            )
            StatPill(
                value: "\(userStore.appUser?.totalArrowDays ?? 0)",
                label: "Arrows",
                icon: "arrow.up.right",
                color: "BrandArrow"
            )
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
            if userStore.isPremium || !(userStore.appUser?.journeyActive ?? false) {
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
                    Text("Stand Firm Journey")
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
struct TodayStatusCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let isComplete: Bool
    let color: String
    let destination: AnyView

    var body: some View {
        NavigationLink(destination: destination) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: isComplete ? "checkmark.circle.fill" : icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(isComplete ? .green : Color(color))
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
    }
}

// MARK: - StatPill
struct StatPill: View {
    let value: String
    let label: String
    let icon: String
    let color: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .renderingMode(.template)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(color))
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
    }
}
