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
    @State private var heroCardPulsing = false
    @State private var showShareSheet = false
    @State private var shareImage: UIImage?

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                if userStore.isLoading && userStore.appUser == nil {
                    dashboardSkeleton
                } else {
                VStack(spacing: AATheme.paddingLarge) {

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
                    .padding(.horizontal, AATheme.paddingLarge)

                    // Today's Status Cards
                    todayStatusSection

                    // Streak + Stats Row
                    streakStatsSection

                    // Recent Badges
                    if userStore.earnedBadges.isEmpty {
                        badgesEmptyState
                    } else {
                        recentBadgesSection
                    }

                    // Journey CTA
                    journeyCTASection

                    Spacer(minLength: 100) // tab bar clearance
                }
                .padding(.top, AATheme.paddingSmall)
                }
            }
            .refreshable {
                guard let uid = Auth.auth().currentUser?.uid else { return }
                await userStore.loadUserData(uid: uid)
            }
            .aaScreenBackground()
            .navigationTitle("Anchor & Arrow")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AATheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(AATheme.steel)
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
        .sheet(isPresented: $showShareSheet) {
            if let image = shareImage {
                ImageShareSheet(image: image)
            }
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
                        .foregroundColor(AATheme.secondaryText)
                    Text(userStore.displayName)
                        .font(AATheme.headlineFont)
                        .foregroundColor(AATheme.primaryText)
                }
                Spacer()
                // Date chip
                VStack(spacing: 2) {
                    Text(Date().formatted(.dateTime.weekday(.wide)))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AATheme.steel)
                    Text(Date().formatted(.dateTime.day()))
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundColor(AATheme.primaryText)
                    Text(Date().formatted(.dateTime.month(.abbreviated)))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AATheme.secondaryText)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, AATheme.paddingSmall + 2)
                .background(AATheme.cardBackground)
                .cornerRadius(AATheme.cornerRadiusSmall + 2)
                .shadow(color: AATheme.cardShadow, radius: AATheme.cardShadowRadius, x: 0, y: 2)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Today is \(Date().formatted(.dateTime.weekday(.wide).month(.wide).day()))")
            }
        }
        .padding(.horizontal, AATheme.paddingLarge)
    }

    private var heroCardHeadline: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Your Anchor is waiting."
        case 12..<17: return "You haven't anchored today."
        case 17..<24: return "Day's almost over. Anchor up."
        default:      return "It's not too late. Stand firm."
        }
    }

    private var todayStatusSection: some View {
        VStack(spacing: 14) {
            // Hero urgency card
            if !userStore.isAnchorDoneToday && !userStore.isArrowDoneToday {
                // Neither done — Anchor CTA
                NavigationLink(destination: AnchorView()) {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(heroCardHeadline)
                                .font(.system(.title3, design: .serif, weight: .bold))
                                .foregroundColor(.white)
                            Text("Tap to start your morning reflection")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(AATheme.paddingMedium)
                    .background(
                        LinearGradient(colors: [AATheme.steel, AATheme.steelDark], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .cornerRadius(AATheme.cornerRadius)
                    .opacity(heroCardPulsing ? 1.0 : 0.95)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                            heroCardPulsing = true
                        }
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal, AATheme.paddingLarge)
                .accessibilityLabel("Start your Anchor")
                .accessibilityHint("Tap to begin your morning reflection")
            } else if userStore.isAnchorDoneToday && !userStore.isArrowDoneToday {
                // Anchor done, Arrow pending
                NavigationLink(destination: ArrowView()) {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Anchor set. Now loose your Arrow.")
                                .font(.system(.title3, design: .serif, weight: .bold))
                                .foregroundColor(.white)
                            Text("What kingdom action did you take today?")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(AATheme.paddingMedium)
                    .background(
                        LinearGradient(colors: [AATheme.amber, AATheme.amberDark], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .cornerRadius(AATheme.cornerRadius)
                    .opacity(heroCardPulsing ? 1.0 : 0.95)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                            heroCardPulsing = true
                        }
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal, AATheme.paddingLarge)
                .accessibilityLabel("Log your Arrow")
                .accessibilityHint("Tap to record your kingdom action")
            } else if userStore.isAnchorDoneToday && userStore.isArrowDoneToday {
                // Both done — celebration
                HStack(spacing: 12) {
                    AAIcon("checkmark.seal.fill", size: 28, color: AATheme.success)
                    Text("Both done. Well fought, brother.")
                        .font(.system(.title3, design: .serif, weight: .semibold))
                        .foregroundColor(AATheme.primaryText)
                }
                .padding(AATheme.paddingMedium)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AATheme.success.opacity(0.1))
                .cornerRadius(AATheme.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AATheme.cornerRadius)
                        .stroke(AATheme.success, lineWidth: 1.5)
                )
                .padding(.horizontal, AATheme.paddingLarge)
            }

            // Existing status card pair
            HStack(spacing: 14) {
                TodayStatusCard(
                    title: "Anchor",
                    subtitle: "Morning",
                    isComplete: userStore.isAnchorDoneToday,
                    color: AATheme.steel,
                    destination: AnyView(AnchorView())
                ) {
                    AnchorSymbolView()
                        .frame(width: 24, height: 30)
                }
                TodayStatusCard(
                    title: "Arrow",
                    subtitle: "Evening",
                    isComplete: userStore.isArrowDoneToday,
                    color: AATheme.amber,
                    destination: AnyView(ArrowView())
                ) {
                    SingleArcheryArrowView(color: AATheme.amber)
                        .frame(width: 26, height: 26)
                }
            }
            .padding(.horizontal, AATheme.paddingLarge)
        }
    }

    private var streakStatsSection: some View {
        let streakColor = userStore.currentStreak >= 7 ? AATheme.warmGold : AATheme.steel
        return VStack(spacing: 10) {
            HStack(spacing: 14) {
                ZStack(alignment: .topTrailing) {
                    StatPill(value: "\(userStore.currentStreak)", label: "Day Streak",
                             color: streakColor) {
                        AAIcon("flame.fill", size: 16, color: streakColor)
                    }
                    Button {
                        shareImage = generateStreakShareImage()
                        showShareSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AATheme.secondaryText)
                            .padding(6)
                            .background(AATheme.cardBackground)
                            .clipShape(SwiftUI.Circle())
                            .shadow(color: AATheme.cardShadow, radius: 2, x: 0, y: 1)
                    }
                    .offset(x: -4, y: 4)
                    .accessibilityLabel("Share your streak")
                }
                StatPill(value: "\(userStore.appUser?.totalAnchorDays ?? 0)", label: "Anchors",
                         color: AATheme.steel) {
                    AnchorSymbolView()
                        .frame(width: 20, height: 25)
                }
                StatPill(value: "\(userStore.appUser?.totalArrowDays ?? 0)", label: "Arrows",
                         color: AATheme.amber) {
                    SingleArcheryArrowView(color: AATheme.amber)
                        .frame(width: 20, height: 20)
                }
            }
        }
        .padding(.horizontal, AATheme.paddingLarge)
    }

    private var badgesEmptyState: some View {
        HStack(spacing: 12) {
            AAIcon("star.circle", size: 28, color: AATheme.warmGold.opacity(0.5))

            VStack(alignment: .leading, spacing: 3) {
                Text("Badges")
                    .font(AATheme.subheadlineFont)
                    .foregroundColor(AATheme.primaryText)
                Text("Complete your first Anchor and Arrow to earn your first badge.")
                    .font(.system(size: 13))
                    .foregroundColor(AATheme.secondaryText)
            }
        }
        .padding(AATheme.paddingMedium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AATheme.cardBackground)
        .cornerRadius(AATheme.cornerRadius)
        .shadow(color: AATheme.cardShadow, radius: AATheme.cardShadowRadius, x: 0, y: 2)
        .padding(.horizontal, AATheme.paddingLarge)
    }

    private var recentBadgesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Badges")
                    .font(AATheme.subheadlineFont)
                    .foregroundColor(AATheme.primaryText)
                Spacer()
                NavigationLink("See All") {
                    ProgressView()
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AATheme.steel)
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
        .padding(.horizontal, AATheme.paddingLarge)
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
            HStack(spacing: AATheme.paddingMedium) {
                ZStack {
                    SwiftUI.Circle()
                        .fill(AATheme.amber.opacity(0.15))
                        .frame(width: 48, height: 48)
                    AAIcon("map.fill", size: 20, color: AATheme.amber)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("\(userStore.currentJourneySeries.displayName) Journey")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AATheme.primaryText)
                    Text(userStore.appUser?.journeyActive == true
                         ? "Day \(userStore.appUser?.journeyDay ?? 0) of \(kJourneyDays)"
                         : "\(kJourneyDays)-day guided plan — start today")
                        .font(.system(size: 13))
                        .foregroundColor(AATheme.secondaryText)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AATheme.secondaryText)
            }
            .padding(AATheme.paddingMedium)
            .background(AATheme.cardBackground)
            .cornerRadius(AATheme.cornerRadius)
            .shadow(color: AATheme.cardShadow, radius: AATheme.cardShadowRadius, x: 0, y: 2)
            .padding(.horizontal, AATheme.paddingLarge)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(userStore.appUser?.journeyActive == true
            ? "\(userStore.currentJourneySeries.displayName) Journey, Day \(userStore.appUser?.journeyDay ?? 0) of \(kJourneyDays)"
            : "\(userStore.currentJourneySeries.displayName) Journey, \(kJourneyDays)-day guided plan")
        .accessibilityHint("Double tap to open")
    }

    // MARK: - Skeleton
    private var dashboardSkeleton: some View {
        VStack(spacing: AATheme.paddingLarge) {
            // Header placeholder
            HStack {
                VStack(alignment: .leading, spacing: AATheme.paddingSmall) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AATheme.cardBackground)
                        .frame(width: 100, height: 14)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AATheme.cardBackground)
                        .frame(width: 160, height: 24)
                }
                Spacer()
                RoundedRectangle(cornerRadius: AATheme.cornerRadiusSmall + 2)
                    .fill(AATheme.cardBackground)
                    .frame(width: 52, height: 60)
            }
            .padding(.horizontal, AATheme.paddingLarge)

            // Tree placeholder
            RoundedRectangle(cornerRadius: 20)
                .fill(AATheme.cardBackground)
                .frame(height: 280)
                .padding(.horizontal, AATheme.paddingLarge)

            // Status cards
            HStack(spacing: 14) {
                SkeletonCard(height: 130)
                SkeletonCard(height: 130)
            }
            .padding(.horizontal, AATheme.paddingLarge)

            // Stats row
            HStack(spacing: 14) {
                SkeletonCard(height: 80)
                SkeletonCard(height: 80)
                SkeletonCard(height: 80)
            }
            .padding(.horizontal, AATheme.paddingLarge)

            // Journey CTA
            SkeletonCard(height: 80)
                .padding(.horizontal, AATheme.paddingLarge)

            Spacer(minLength: 100)
        }
        .padding(.top, AATheme.paddingSmall)
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

    // MARK: - Streak Share Image
    private func generateStreakShareImage() -> UIImage {
        let size = CGSize(width: 1080, height: 1080)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)

            // Background — warm stone/parchment
            UIColor(red: 0.96, green: 0.94, blue: 0.90, alpha: 1.0).setFill()
            context.fill(rect)

            // Colors
            let steelColor = UIColor(AATheme.steel)
            let secondaryColor = UIColor(red: 0.42, green: 0.44, blue: 0.50, alpha: 1.0)

            // Top: "ANCHOR & ARROW"
            let titleFont = UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle)
                .withDesign(.serif)!
                .withSymbolicTraits(.traitBold)!, size: 42)
            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: steelColor,
                .kern: 4.0
            ]
            let titleString = "ANCHOR & ARROW"
            let titleSize = titleString.size(withAttributes: titleAttrs)
            let titlePoint = CGPoint(x: (size.width - titleSize.width) / 2, y: 160)
            titleString.draw(at: titlePoint, withAttributes: titleAttrs)

            // Decorative line below title
            let lineY = titlePoint.y + titleSize.height + 30
            let lineRect = CGRect(x: size.width / 2 - 60, y: lineY, width: 120, height: 2)
            UIColor(AATheme.amber).setFill()
            UIBezierPath(roundedRect: lineRect, cornerRadius: 1).fill()

            // Center: Large streak number
            let streakValue = "\(userStore.currentStreak)"
            let numberFont = UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle)
                .withDesign(.serif)!
                .withSymbolicTraits(.traitBold)!, size: 120)
            let numberAttrs: [NSAttributedString.Key: Any] = [
                .font: numberFont,
                .foregroundColor: steelColor
            ]
            let numberSize = streakValue.size(withAttributes: numberAttrs)
            let numberPoint = CGPoint(x: (size.width - numberSize.width) / 2, y: 340)
            streakValue.draw(at: numberPoint, withAttributes: numberAttrs)

            // Below number: "DAY STREAK"
            let streakLabelFont = UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title2)
                .withDesign(.serif)!
                .withSymbolicTraits(.traitBold)!, size: 32)
            let streakLabelAttrs: [NSAttributedString.Key: Any] = [
                .font: streakLabelFont,
                .foregroundColor: steelColor,
                .kern: 6.0
            ]
            let streakLabel = "DAY STREAK"
            let streakLabelSize = streakLabel.size(withAttributes: streakLabelAttrs)
            let streakLabelPoint = CGPoint(x: (size.width - streakLabelSize.width) / 2,
                                           y: numberPoint.y + numberSize.height + 16)
            streakLabel.draw(at: streakLabelPoint, withAttributes: streakLabelAttrs)

            // Below that: flame emoji + "days standing firm"
            let mottoFont = UIFont.systemFont(ofSize: 26, weight: .medium)
            let mottoAttrs: [NSAttributedString.Key: Any] = [
                .font: mottoFont,
                .foregroundColor: secondaryColor
            ]
            let motto = "\u{1F525} days standing firm"
            let mottoSize = motto.size(withAttributes: mottoAttrs)
            let mottoPoint = CGPoint(x: (size.width - mottoSize.width) / 2,
                                     y: streakLabelPoint.y + streakLabelSize.height + 40)
            motto.draw(at: mottoPoint, withAttributes: mottoAttrs)

            // Bottom: "1 Corinthians 16:13" in italic serif
            let verseFont = UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
                .withDesign(.serif)!
                .withSymbolicTraits([.traitItalic])!, size: 24)
            let verseAttrs: [NSAttributedString.Key: Any] = [
                .font: verseFont,
                .foregroundColor: secondaryColor
            ]
            let verse = "1 Corinthians 16:13"
            let verseSize = verse.size(withAttributes: verseAttrs)
            let versePoint = CGPoint(x: (size.width - verseSize.width) / 2, y: 840)
            verse.draw(at: versePoint, withAttributes: verseAttrs)
        }
    }
}

// MARK: - TodayStatusCard
struct TodayStatusCard<IncompleteIcon: View>: View {
    let title: String
    let subtitle: String
    let isComplete: Bool
    let color: Color
    let destination: AnyView
    @ViewBuilder let incompleteIcon: () -> IncompleteIcon

    var body: some View {
        NavigationLink(destination: destination) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    if isComplete {
                        AAIcon("checkmark.circle.fill", size: 24, color: AATheme.success)
                    } else {
                        incompleteIcon()
                    }
                    Spacer()
                    if isComplete {
                        Text("Done")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(AATheme.success)
                            .padding(.horizontal, AATheme.paddingSmall)
                            .padding(.vertical, 4)
                            .background(AATheme.success.opacity(0.15))
                            .cornerRadius(AATheme.paddingSmall)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AATheme.subheadlineFont)
                        .foregroundColor(AATheme.primaryText)
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(AATheme.secondaryText)
                }

                HStack {
                    Text(isComplete ? "Completed" : "Tap to begin")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(isComplete ? AATheme.success : color)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(isComplete ? AATheme.success : color)
                }
            }
            .padding(AATheme.paddingMedium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                ZStack {
                    AATheme.cardBackground
                    if isComplete {
                        AATheme.success.opacity(0.05)
                    }
                }
            )
            .cornerRadius(AATheme.cornerRadius)
            .shadow(color: AATheme.cardShadow, radius: AATheme.cardShadowRadius, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: AATheme.cornerRadius)
                    .stroke(isComplete ? AATheme.success.opacity(0.3) : Color.clear, lineWidth: 1.5)
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
    let color: Color
    @ViewBuilder let iconView: () -> Icon

    var body: some View {
        VStack(spacing: 6) {
            iconView()
            Text(value)
                .font(.system(size: 22, weight: .heavy))
                .foregroundColor(AATheme.primaryText)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AATheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(AATheme.cardBackground)
        .cornerRadius(AATheme.cornerRadiusSmall + 4)
        .shadow(color: AATheme.cardShadow, radius: AATheme.cardShadowRadius, x: 0, y: 2)
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
                AAIcon(badge.icon, size: 20, color: badge.color)
            }
            Text(badge.name)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(AATheme.secondaryText)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 60)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Badge: \(badge.name)")
    }
}

// MARK: - ImageShareSheet (UIActivityViewController wrapper for UIImage)
struct ImageShareSheet: UIViewControllerRepresentable {
    let image: UIImage

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
