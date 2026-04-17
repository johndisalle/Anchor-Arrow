// DashboardView.swift
// Home screen — hero illustration, smart CTA, journey CTA

import SwiftUI
import FirebaseAuth

struct DashboardView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var storeKitManager: StoreKitManager
    @State private var showJourney = false
    @State private var animateTree = false
    @State private var showPremiumUpsell = false
    @State private var heroCardPulsing = false
    @State private var showStreakCelebration = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                if userStore.isLoading && userStore.appUser == nil {
                    dashboardSkeleton
                } else {
                VStack(spacing: AATheme.paddingLarge) {

                    // Greeting Header (compact: greeting + date + streak pill + profile)
                    headerSection

                    // Central Tree + Arrow Visual (tappable, reflects today's completion)
                    illustrationSection

                    // Tiny completion legend (only when something is done)
                    completionLegend

                    // New user guidance (first day only)
                    if userStore.recentEntries.isEmpty && userStore.currentStreak == 0 {
                        newUserGuidance
                    }

                    // Smart contextual CTA
                    todayStatusSection

                    // Journey CTA
                    journeyCTASection

                    // Brotherhood CTA
                    brotherhoodCTASection

                    // Streak freeze warning (after 6 PM, nothing done)
                    if showStreakFreezeWarning {
                        streakFreezeCard
                    }

                    // Yesterday's reflection (if exists)
                    if yesterdayEntry != nil {
                        yesterdayReflectionCard
                    }
                }
                .padding(.top, AATheme.paddingSmall)
                .padding(.bottom, 80) // floating drift button clearance
                }
            }
            .refreshable {
                guard let uid = Auth.auth().currentUser?.uid else { return }
                await userStore.loadUserData(uid: uid)
            }
            .aaScreenBackground()
            .toolbar(.hidden, for: .navigationBar)
            .onChange(of: userStore.showStreakMilestone) { _, show in
                if show {
                    showStreakCelebration = true
                    userStore.showStreakMilestone = false
                }
            }
            .fullScreenCover(isPresented: $showStreakCelebration) {
                StreakMilestoneCelebration(
                    streak: userStore.milestoneStreak,
                    showUpgrade: !userStore.isPremium,
                    onUpgrade: {
                        showStreakCelebration = false
                        showPremiumUpsell = true
                    }
                ) {
                    showStreakCelebration = false
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
            withAnimation(.easeOut(duration: 1.2).delay(0.3)) {
                animateTree = true
            }
        }
    }

    // MARK: - Subviews

    private var headerSection: some View {
        HStack(alignment: .center, spacing: AATheme.paddingSmall) {
            VStack(alignment: .leading, spacing: 2) {
                Text(firstName)
                    .font(.system(size: 17, weight: .bold, design: .serif))
                    .foregroundColor(AATheme.primaryText)
                    .lineLimit(1)
                Text(inlineDateString)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AATheme.secondaryText)
                    .lineLimit(1)
                if userStore.currentStreak >= 3 {
                    Text(streakEncouragement)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AATheme.amber)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: AATheme.paddingSmall)

            // Compact streak pill (hidden when streak is 0)
            if userStore.currentStreak > 0 {
                HStack(spacing: 4) {
                    AAIcon("flame.fill", size: 12, weight: .semibold, color: AATheme.amber)
                    Text("\(userStore.currentStreak)")
                        .font(.system(size: 14, weight: .semibold, design: .serif))
                        .foregroundColor(AATheme.primaryText)
                }
                .padding(.horizontal, 10)
                .frame(height: 28)
                .background(AATheme.cardBackground)
                .clipShape(Capsule())
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(userStore.currentStreak) day streak")
            }

            NavigationLink {
                SettingsView()
            } label: {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(AATheme.steel)
                    .accessibilityLabel("Profile and Settings")
            }
        }
        .padding(.horizontal, AATheme.paddingLarge)
        .padding(.top, AATheme.paddingMedium)
    }

    private var firstName: String {
        let name = userStore.displayName
        return name.components(separatedBy: " ").first ?? name
    }

    private var streakEncouragement: String {
        let streak = userStore.currentStreak
        switch streak {
        case 3...6:   return "\(streak) days anchored. Building momentum."
        case 7...13:  return "\(streak)-day streak. You are sharpening iron."
        case 14...29: return "\(streak) days standing firm. Roots run deep."
        case 30...59: return "\(streak) days. A month of faithfulness."
        case 60...99: return "\(streak) days. Unshakeable. Keep going."
        case 100...:  return "\(streak) days. Act like men, be strong."
        default:      return ""
        }
    }

    private static let _dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "EEEE d MMM"
        return df
    }()

    private var inlineDateString: String {
        return Self._dateFormatter.string(from: Date())
    }

    private var illustrationSection: some View {
        NavigationLink(destination: contextualDestination) {
            TreeArrowProgressView(
                anchorProgress: anchorProgress,
                arrowProgress: arrowProgress,
                animate: animateTree,
                anchorCompleted: userStore.isAnchorDoneToday,
                arrowCompleted: userStore.isArrowDoneToday
            )
            .frame(height: 220)
            .padding(.horizontal, AATheme.paddingLarge)
        }
        .buttonStyle(IllustrationPressStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Anchor and Arrow illustration")
        .accessibilityHint("Double tap to continue your day")
    }

    @ViewBuilder
    private var completionLegend: some View {
        if userStore.isAnchorDoneToday || userStore.isArrowDoneToday {
            HStack(spacing: 10) {
                if userStore.isAnchorDoneToday {
                    HStack(spacing: 4) {
                        Text("Anchor")
                            .font(.system(size: 13, weight: .semibold, design: .serif))
                        AAIcon("checkmark", size: 12, weight: .bold, color: AATheme.steel)
                    }
                    .foregroundColor(AATheme.steel)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(AATheme.steel.opacity(0.18))
                    .clipShape(Capsule())
                }
                if userStore.isArrowDoneToday {
                    HStack(spacing: 4) {
                        Text("Arrow")
                            .font(.system(size: 13, weight: .semibold, design: .serif))
                        AAIcon("checkmark", size: 12, weight: .bold, color: AATheme.amber)
                    }
                    .foregroundColor(AATheme.amber)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(AATheme.amber.opacity(0.18))
                    .clipShape(Capsule())
                }
            }
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                userStore.isAnchorDoneToday && userStore.isArrowDoneToday
                ? "Anchor and Arrow complete today"
                : userStore.isAnchorDoneToday ? "Anchor complete today"
                : "Arrow complete today"
            )
        }
    }

    private var contextualDestination: AnyView {
        if !userStore.isAnchorDoneToday {
            return AnyView(AnchorView())
        } else if !userStore.isArrowDoneToday {
            return AnyView(ArrowView())
        } else {
            return AnyView(AnchorView())
        }
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
                // Anchor done, Arrow pending — softened amber variant
                NavigationLink(destination: ArrowView()) {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Anchor set. Now loose your Arrow.")
                                .font(.system(.title3, design: .serif, weight: .bold))
                                .foregroundColor(AATheme.amber)
                            Text("What kingdom action did you take today?")
                                .font(.system(size: 14))
                                .foregroundColor(AATheme.secondaryText)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AATheme.amber)
                    }
                    .padding(AATheme.paddingMedium)
                    .background(AATheme.amber.opacity(0.18))
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
                // Both done — celebration with streak
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        AAIcon("checkmark.seal.fill", size: 28, color: AATheme.success)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Both done. Well fought, brother.")
                                .font(.system(.title3, design: .serif, weight: .semibold))
                                .foregroundColor(AATheme.primaryText)
                            if userStore.currentStreak > 1 {
                                Text("\(userStore.currentStreak)-day streak and counting")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(AATheme.success)
                            }
                        }
                        Spacer()
                    }

                    // Completion timestamps
                    HStack(spacing: AATheme.paddingLarge) {
                        if let anchorTime = userStore.todayEntry?.anchorCompletedAt {
                            Label("Anchored \(anchorTime, style: .time)", systemImage: "anchor")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(AATheme.secondaryText)
                        }
                        if let arrowTime = userStore.todayEntry?.arrowCompletedAt {
                            Label("Arrow \(arrowTime, style: .time)", systemImage: "arrow.up.right")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(AATheme.secondaryText)
                        }
                        Spacer()
                    }
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
        }
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
            // Header placeholder (compact single-row)
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(AATheme.cardBackground)
                    .frame(width: 220, height: 20)
                Spacer()
                SwiftUI.Circle()
                    .fill(AATheme.cardBackground)
                    .frame(width: 30, height: 30)
            }
            .padding(.horizontal, AATheme.paddingLarge)

            // Tree placeholder
            RoundedRectangle(cornerRadius: 20)
                .fill(AATheme.cardBackground)
                .frame(height: 350)
                .padding(.horizontal, AATheme.paddingLarge)

            // Hero CTA placeholder
            SkeletonCard(height: 80)
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

    // MARK: - Brotherhood CTA
    private var brotherhoodCTASection: some View {
        Button {
            // Switch to Circles tab
            NotificationCenter.default.post(name: NSNotification.Name("switchToCircles"), object: nil)
        } label: {
            HStack(spacing: AATheme.paddingMedium) {
                ZStack {
                    SwiftUI.Circle()
                        .fill(AATheme.steel.opacity(0.15))
                        .frame(width: 48, height: 48)
                    AAIcon("person.3.fill", size: 20, color: AATheme.steel)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Your Brotherhood")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AATheme.primaryText)
                    Text("Check in with your brothers")
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
    }

    // MARK: - Streak Freeze Warning
    private var showStreakFreezeWarning: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 18 && !userStore.isAnchorDoneToday && userStore.currentStreak >= 3
    }

    private var streakFreezeCard: some View {
        HStack(spacing: 12) {
            AAIcon("exclamationmark.triangle.fill", size: 22, color: AATheme.warning)
            VStack(alignment: .leading, spacing: 3) {
                Text("Your \(userStore.currentStreak)-day streak is at risk")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AATheme.primaryText)
                Text("Complete your Anchor before midnight")
                    .font(.system(size: 13))
                    .foregroundColor(AATheme.secondaryText)
            }
            Spacer()
        }
        .padding(AATheme.paddingMedium)
        .background(AATheme.warning.opacity(0.1))
        .cornerRadius(AATheme.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AATheme.cornerRadius)
                .stroke(AATheme.warning.opacity(0.4), lineWidth: 1)
        )
        .padding(.horizontal, AATheme.paddingLarge)
    }

    // MARK: - Yesterday's Reflection
    private var yesterdayEntry: DailyEntry? {
        userStore.recentEntries.first { entry in
            Calendar.current.isDateInYesterday(entry.date)
        }
    }

    private var yesterdayReflectionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                AAIcon("clock.arrow.circlepath", size: 14, color: AATheme.secondaryText)
                Text("Yesterday")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AATheme.secondaryText)
            }

            if let entry = yesterdayEntry {
                if !entry.anchorReflection.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            AAIcon("anchor", size: 11, color: AATheme.steel)
                            Text("Anchor")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(AATheme.steel)
                        }
                        Text(entry.anchorReflection)
                            .font(.system(size: 14))
                            .foregroundColor(AATheme.primaryText)
                            .lineLimit(2)
                    }
                }

                if !entry.arrowReflection.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            AAIcon("arrow.up.right", size: 11, color: AATheme.amber)
                            Text("Arrow")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(AATheme.amber)
                        }
                        Text(entry.arrowReflection)
                            .font(.system(size: 14))
                            .foregroundColor(AATheme.primaryText)
                            .lineLimit(2)
                    }
                }
            }
        }
        .padding(AATheme.paddingMedium)
        .background(AATheme.cardBackground)
        .cornerRadius(AATheme.cornerRadius)
        .padding(.horizontal, AATheme.paddingLarge)
    }

    // MARK: - New User Empty State
    private var newUserGuidance: some View {
        VStack(spacing: 14) {
            AAIcon("sunrise.fill", size: 28, color: AATheme.warmGold)
            Text("Your First Day")
                .font(AATheme.subheadlineFont)
                .foregroundColor(AATheme.primaryText)
            Text("Start with your Morning Anchor — read the scripture, reflect, and pray. Then later today, log your Evening Arrow.")
                .font(.system(size: 14))
                .foregroundColor(AATheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(AATheme.paddingLarge)
        .background(AATheme.cardBackground)
        .cornerRadius(AATheme.cornerRadius)
        .padding(.horizontal, AATheme.paddingLarge)
    }
}

// MARK: - IllustrationPressStyle
private struct IllustrationPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Streak Milestone Celebration
struct StreakMilestoneCelebration: View {
    let streak: Int
    var showUpgrade: Bool = false
    var onUpgrade: (() -> Void)? = nil
    let onDismiss: () -> Void
    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0

    private var milestoneMessage: String {
        switch streak {
        case 7:   return "One week standing firm.\nYou are building something real."
        case 14:  return "Two weeks anchored.\nRoots are growing deep."
        case 30:  return "One month of faithfulness.\nThis is what it looks like."
        case 60:  return "Sixty days unshakeable.\nIron sharpens iron."
        case 100: return "One hundred days.\nAct like men. Be strong."
        default:  return "\(streak) days anchored.\nWell done, brother."
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
                .onTapGesture(perform: onDismiss)

            VStack(spacing: 24) {
                ZStack {
                    SwiftUI.Circle()
                        .fill(AATheme.amber.opacity(0.2))
                        .frame(width: 120, height: 120)
                    VStack(spacing: 4) {
                        AAIcon("flame.fill", size: 36, color: AATheme.amber)
                        Text("\(streak)")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(AATheme.amber)
                    }
                }

                Text(milestoneMessage)
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Button(action: onDismiss) {
                    Text("Keep Going")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(AATheme.amber)
                        .cornerRadius(AATheme.cornerRadius)
                }

                if showUpgrade {
                    Button(action: onUpgrade ?? {}) {
                        HStack(spacing: 6) {
                            AAIcon("crown.fill", size: 14, color: AATheme.warmGold)
                            Text("Unlock 11 Journeys")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AATheme.warmGold)
                        }
                    }
                    .padding(.top, 4)
                }
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}
