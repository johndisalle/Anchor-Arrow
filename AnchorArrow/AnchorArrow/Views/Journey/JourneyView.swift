// JourneyView.swift
// 30-day Stand Firm guided journey

import SwiftUI

struct JourneyView: View {
    @EnvironmentObject var userStore: UserStore
    @Environment(\.dismiss) var dismiss
    @State private var journeyDays: [JourneyDay] = []
    @State private var showDayDetail: JourneyDay?
    @State private var showStartConfirm = false
    @State private var isStarting = false
    @State private var selectedSeries: JourneySeries = .standFirm
    @State private var showSeriesPicker = false
    @State private var showAbandonAlert = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: AATheme.paddingLarge) {

                    // Header
                    journeyHeader

                    // Not started yet
                    if !(userStore.appUser?.journeyActive ?? false) {
                        // Series picker for premium users or those who completed a journey
                        if userStore.isPremium || !(userStore.appUser?.completedJourneys ?? []).isEmpty {
                            seriesPickerSection
                        }
                        startJourneyCTA
                    } else {
                        // Progress bar
                        journeyProgressBar

                        // Day list
                        dayListSection
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, AATheme.paddingMedium)
            }
            .aaScreenBackground()
            .navigationTitle(activeSeries.displayName + " Journey")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AATheme.steel)
                }
                if userStore.isPremium && (userStore.appUser?.journeyActive ?? false) {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button(role: .destructive) {
                                showAbandonAlert = true
                            } label: {
                                Label("Abandon Journey", systemImage: "xmark.circle")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 16))
                                .foregroundColor(AATheme.secondaryText)
                        }
                    }
                }
            }
            .alert("Abandon Journey?", isPresented: $showAbandonAlert) {
                Button("Abandon", role: .destructive) {
                    Task {
                        await userStore.abandonJourney()
                        journeyDays = PromptLibrary.journeyDays(for: selectedSeries)
                    }
                }
                Button("Keep Going", role: .cancel) {}
            } message: {
                Text("Your progress on \(activeSeries.displayName) will be lost. You can start any journey again anytime.")
            }
            .sheet(item: $showDayDetail) { day in
                JourneyDayDetailView(day: day) { anchorText, arrowText in
                    Task {
                        await userStore.completeJourneyDay(anchorReflection: anchorText, arrowReflection: arrowText)
                    }
                    showDayDetail = nil
                }
            }
            .confirmationDialog(
                "Start the \(kJourneyDays)-day \(selectedSeries.displayName) Journey?",
                isPresented: $showStartConfirm,
                titleVisibility: .visible
            ) {
                Button("Start Journey") {
                    Task { await startJourney() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Commit to \(kJourneyDays) days of guided Scripture, daily anchoring, and purposeful action. One day at a time.")
            }
            .onAppear {
                let series = userStore.currentJourneySeries
                selectedSeries = series
                journeyDays = PromptLibrary.journeyDays(for: series)
            }
            .fullScreenCover(isPresented: $userStore.showJourneyComplete) {
                JourneyCompletionView(
                    series: userStore.completedJourneySeries ?? .standFirm,
                    onStartNext: { nextSeries in
                        userStore.showJourneyComplete = false
                        Task {
                            await userStore.startJourney(series: nextSeries)
                            selectedSeries = nextSeries
                            journeyDays = PromptLibrary.journeyDays(for: nextSeries)
                        }
                    },
                    onDismiss: {
                        userStore.showJourneyComplete = false
                    }
                )
            }
        }
    }

    // MARK: - Subviews

    private var journeyHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                AAIcon("map.fill", size: 20, color: AATheme.amber)
                Text("30-Day Guided Plan")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AATheme.amber)
            }

            Text(activeSeries == .armorOfGod
                 ? "Four weeks through Ephesians 6 — each piece of God's armor examined, applied, and worn into battle. Each day unlocks the next."
                 : "Four weeks of deep, sequential truth — from watchful rootedness to purposeful love. Each day unlocks the next.")
                .font(.system(size: 15))
                .foregroundColor(AATheme.secondaryText)
                .lineSpacing(4)

            // Week themes
            HStack(spacing: AATheme.paddingSmall) {
                ForEach(weekThemes, id: \.week) { theme in
                    VStack(spacing: 4) {
                        Text("Wk \(theme.week)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(theme.color)
                        Text(theme.title)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(AATheme.secondaryText)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AATheme.paddingSmall + 2)
                    .background(theme.color.opacity(0.1))
                    .cornerRadius(AATheme.cornerRadiusSmall)
                }
            }
        }
        .padding(AATheme.paddingMedium)
        .background(AATheme.cardBackground)
        .cornerRadius(20)
        .shadow(color: AATheme.cardShadow, radius: AATheme.cardShadowRadius, x: 0, y: 2)
    }

    private var startJourneyCTA: some View {
        VStack(spacing: 20) {
            AAIcon("figure.stand.line.dotted.figure.stand", size: 52, weight: .semibold, color: AATheme.amber)

            VStack(spacing: AATheme.paddingSmall) {
                Text("Ready to Commit?")
                    .font(AATheme.headlineFont)
                    .foregroundColor(AATheme.primaryText)

                Text("This journey is free to start. \(kJourneyDays) days, one day at a time. No skipping ahead — each day builds on the last.")
                    .font(.system(size: 15))
                    .foregroundColor(AATheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, AATheme.paddingLarge)
            }

            Button {
                showStartConfirm = true
            } label: {
                ZStack {
                    if isStarting {
                        ProgressView().tint(.white)
                    } else {
                        HStack {
                            Image(systemName: "flag.fill")
                            Text("Begin the Journey")
                                .font(.system(size: 17, weight: .bold))
                        }
                        .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(AATheme.amber)
                .cornerRadius(AATheme.cornerRadius)
            }
            .disabled(isStarting)
            .padding(.horizontal, AATheme.paddingXLarge)
        }
        .padding(.vertical, AATheme.paddingXLarge)
    }

    private var journeyProgressBar: some View {
        let currentDay = userStore.appUser?.journeyDay ?? 0
        let progress = Double(currentDay) / Double(kJourneyDays)

        return VStack(alignment: .leading, spacing: AATheme.paddingSmall + 2) {
            HStack {
                Text("Day \(currentDay) of \(kJourneyDays)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AATheme.primaryText)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AATheme.amber)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(AATheme.cardBackground)
                        .frame(height: 10)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [AATheme.steel, AATheme.amber],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(progress), height: 10)
                        .animation(.easeOut(duration: 0.8), value: progress)
                }
            }
            .frame(height: 10)
        }
        .padding(AATheme.paddingMedium)
        .background(AATheme.cardBackground)
        .cornerRadius(AATheme.cornerRadius)
        .shadow(color: AATheme.cardShadow, radius: AATheme.cardShadowRadius, x: 0, y: 2)
    }

    private var dayListSection: some View {
        let currentDay = userStore.appUser?.journeyDay ?? 0

        return VStack(spacing: 0) {
            // Group by week
            ForEach(1...4, id: \.self) { week in
                let weekDays = journeyDays.filter { $0.week == week }

                VStack(alignment: .leading, spacing: 12) {
                    // Week header
                    HStack {
                        Text("Week \(week)")
                            .font(.system(size: 15, weight: .heavy))
                            .foregroundColor(weekThemes[week - 1].color)
                        Text("— \(weekThemes[week - 1].title)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AATheme.secondaryText)
                    }
                    .padding(.horizontal, 4)
                    .padding(.top, AATheme.paddingMedium)

                    ForEach(weekDays) { day in
                        let isUnlocked = day.id <= currentDay + 1  // can do next day
                        let isCompleted = day.id <= currentDay
                        let isCurrent = day.id == currentDay + 1

                        JourneyDayRow(
                            day: day,
                            isUnlocked: isUnlocked,
                            isCompleted: isCompleted,
                            isCurrent: isCurrent
                        ) {
                            if isUnlocked {
                                showDayDetail = day
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Series Picker
    private var seriesPickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose Your Journey")
                .font(AATheme.subheadlineFont)
                .foregroundColor(AATheme.primaryText)

            ForEach(JourneySeries.allCases) { series in
                let completed = (userStore.appUser?.completedJourneys ?? []).contains(series.rawValue)
                let isAvailable = userStore.isPremium || series == .standFirm

                Button {
                    if isAvailable {
                        selectedSeries = series
                        journeyDays = PromptLibrary.journeyDays(for: series)
                    }
                } label: {
                    HStack(spacing: 14) {
                        AAIcon(series.icon, size: 22, color: selectedSeries == series
                                             ? AATheme.amber : AATheme.secondaryText)
                            .frame(width: 40)

                        VStack(alignment: .leading, spacing: 3) {
                            HStack {
                                Text(series.displayName)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(isAvailable ? AATheme.primaryText : AATheme.secondaryText.opacity(0.5))
                                if completed {
                                    AAIcon("checkmark.circle.fill", size: 13, weight: .semibold, color: .green)
                                }
                                if !isAvailable {
                                    Text("PREMIUM")
                                        .font(.system(size: 9, weight: .heavy))
                                        .foregroundColor(AATheme.warmGold)
                                        .padding(.horizontal, 6).padding(.vertical, 2)
                                        .background(AATheme.warmGold.opacity(0.15))
                                        .cornerRadius(4)
                                }
                            }
                            Text(series.subtitle)
                                .font(.system(size: 12))
                                .foregroundColor(AATheme.secondaryText)
                        }
                        Spacer()

                        if selectedSeries == series {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AATheme.amber)
                        }
                    }
                    .padding(14)
                    .background(selectedSeries == series
                                ? AATheme.amber.opacity(0.07) : AATheme.cardBackground)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(selectedSeries == series
                                    ? AATheme.amber.opacity(0.3) : Color.clear, lineWidth: 1.5)
                    )
                }
                .buttonStyle(.plain)
                .disabled(!isAvailable)
            }
        }
        .padding(AATheme.paddingMedium)
        .background(AATheme.cardBackground)
        .cornerRadius(20)
        .shadow(color: AATheme.cardShadow, radius: AATheme.cardShadowRadius, x: 0, y: 2)
    }

    private var activeSeries: JourneySeries {
        if userStore.appUser?.journeyActive ?? false {
            return userStore.currentJourneySeries
        }
        return selectedSeries
    }

    // MARK: - Actions
    private func startJourney() async {
        isStarting = true
        await userStore.startJourney(series: selectedSeries)
        journeyDays = PromptLibrary.journeyDays(for: selectedSeries)
        isStarting = false
    }

    // MARK: - Week themes
    private var weekThemes: [(week: Int, title: String, color: Color)] {
        switch activeSeries {
        case .armorOfGod:
            return [
                (1, "Truth & Righteousness", AATheme.steel),
                (2, "Gospel & Faith", Color.blue),
                (3, "Salvation & Word", AATheme.amber),
                (4, "Prayer & Stand", Color.red)
            ]
        case .standFirm:
            return [
                (1, "Be Watchful", AATheme.steel),
                (2, "Stand Firm", Color.blue),
                (3, "Act Like Men", AATheme.amber),
                (4, "In Love", Color.red)
            ]
        case .surrenderFirst:
            return [
                (1, "Bow the Knee", AATheme.steel),
                (2, "Die to Self", Color.blue),
                (3, "Receive Your Identity", AATheme.amber),
                (4, "Rise to Serve", Color.red)
            ]
        case .prophetPriestKing:
            return [
                (1, "Prophet", AATheme.steel),
                (2, "Priest", Color.blue),
                (3, "King", AATheme.amber),
                (4, "The Whole Man", Color.red)
            ]
        case .strengthInLove:
            return [
                (1, "Redefine Strength", AATheme.steel),
                (2, "Strength to Serve", Color.blue),
                (3, "Strength to Endure", AATheme.amber),
                (4, "All in Love", Color.red)
            ]
        case .guardTheGates:
            return [
                (1, "Guard Your Heart", AATheme.steel),
                (2, "Guard Your Home", Color.blue),
                (3, "Guard Your Brothers", AATheme.amber),
                (4, "Guard the Mission", Color.red)
            ]
        case .theFathersHeart:
            return [
                (1, "The God Who Runs", AATheme.steel),
                (2, "Fatherhood Lived Out", Color.blue),
                (3, "Healing the Father Wound", AATheme.amber),
                (4, "Fathering the Next Generation", Color.red)
            ]
        case .warriorMindset:
            return [
                (1, "Know Your Enemy", AATheme.steel),
                (2, "The Weapons", Color.blue),
                (3, "The Inner War", AATheme.amber),
                (4, "The Warrior's Mission", Color.red)
            ]
        case .theNarrowRoad:
            return [
                (1, "The Beatitudes", AATheme.steel),
                (2, "Salt, Light & the Law", Color.blue),
                (3, "Trust & Worry", AATheme.amber),
                (4, "Build on the Rock", Color.red)
            ]
        case .rootedAndBuilt:
            return [
                (1, "The Supremacy of Christ", AATheme.steel),
                (2, "The New Wardrobe", Color.blue),
                (3, "Walking Wisely", AATheme.amber),
                (4, "Home & Mission", Color.red)
            ]
        case .forgedInFire:
            return [
                (1, "Into the Furnace", AATheme.steel),
                (2, "Thorns & Grace", Color.blue),
                (3, "Beauty from Ashes", AATheme.amber),
                (4, "Coming Forth as Gold", Color.red)
            ]
        case .theSentLife:
            return [
                (1, "You Are Sent", AATheme.steel),
                (2, "Go to Your Neighbor", Color.blue),
                (3, "Bold & Unhindered", AATheme.amber),
                (4, "Finish the Race", Color.red)
            ]
        }
    }
}

// MARK: - JourneyDayRow
struct JourneyDayRow: View {
    let day: JourneyDay
    let isUnlocked: Bool
    let isCompleted: Bool
    let isCurrent: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Day number / status
                ZStack {
                    SwiftUI.Circle()
                        .fill(circleColor)
                        .frame(width: 40, height: 40)

                    if isCompleted {
                        AAIcon("checkmark", size: 16, weight: .bold, color: .white)
                    } else if !isUnlocked {
                        AAIcon("lock.fill", size: 14, weight: .bold, color: .white.opacity(0.6))
                    } else {
                        Text("\(day.id)")
                            .font(.system(size: 15, weight: .heavy))
                            .foregroundColor(.white)
                    }
                }

                // Content
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text("Day \(day.id)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(isUnlocked ? AATheme.primaryText : AATheme.secondaryText.opacity(0.5))
                        if isCurrent {
                            Text("TODAY")
                                .font(.system(size: 9, weight: .heavy))
                                .foregroundColor(AATheme.amber)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AATheme.amber.opacity(0.15))
                                .cornerRadius(4)
                        }
                    }
                    Text(day.theme)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(isUnlocked ? AATheme.primaryText : AATheme.secondaryText.opacity(0.4))

                    if isUnlocked {
                        Text(day.scripture)
                            .font(.system(size: 12, design: .serif))
                            .foregroundColor(AATheme.secondaryText)
                            .lineLimit(1)
                    }
                }

                Spacer()

                if isUnlocked {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AATheme.secondaryText)
                }
            }
            .padding(14)
            .background(
                isCurrent
                ? AATheme.amber.opacity(0.07)
                : AATheme.cardBackground
            )
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isCurrent ? AATheme.amber.opacity(0.3) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .disabled(!isUnlocked)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Day \(day.id), \(day.theme). \(isCompleted ? "Completed" : isCurrent ? "Today's day" : isUnlocked ? "Available" : "Locked")")
        .accessibilityHint(isUnlocked && !isCompleted ? "Double tap to start this day" : isCompleted ? "Double tap to review" : "Complete previous days to unlock")
    }

    private var circleColor: Color {
        if isCompleted { return .green }
        if isCurrent { return AATheme.amber }
        if isUnlocked { return AATheme.steel }
        return AATheme.secondaryText.opacity(0.25)
    }
}

// MARK: - JourneyDayDetailView
struct JourneyDayDetailView: View {
    let day: JourneyDay
    let onComplete: (_ anchorReflection: String, _ arrowReflection: String) -> Void

    @State private var anchorReflection = ""
    @State private var arrowReflection = ""
    @State private var showPrayer = false
    @FocusState private var focusedField: JourneyField?
    @Environment(\.dismiss) var dismiss

    enum JourneyField { case anchor, arrow }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: AATheme.paddingLarge) {

                    // Day chip
                    HStack {
                        Label("Day \(day.id) of \(kJourneyDays) — Week \(day.week)", systemImage: "map")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AATheme.amber)
                        Spacer()
                    }

                    // Theme + Scripture
                    VStack(alignment: .leading, spacing: 12) {
                        Text(day.theme)
                            .font(AATheme.headlineFont)
                            .foregroundColor(AATheme.primaryText)

                        Text("\"\(day.scripture)\"")
                            .font(AATheme.scriptureFont)
                            .foregroundColor(AATheme.primaryText)
                            .lineSpacing(5)
                    }
                    .padding(20)
                    .background(AATheme.cardBackground)
                    .cornerRadius(20)
                    .shadow(color: AATheme.cardShadow, radius: AATheme.cardShadowRadius, x: 0, y: 2)

                    // Devotional
                    if !day.devotional.isEmpty {
                        VStack(alignment: .leading, spacing: AATheme.paddingSmall + 2) {
                            Label("Today's Devotional", systemImage: "book.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AATheme.steel)
                            Text(day.devotional)
                                .font(.system(size: 15))
                                .foregroundColor(AATheme.primaryText)
                                .lineSpacing(6)
                        }
                        .padding(20)
                        .background(AATheme.cardBackground)
                        .cornerRadius(20)
                        .shadow(color: AATheme.cardShadow, radius: AATheme.cardShadowRadius, x: 0, y: 2)
                    }

                    // Anchor prompt
                    journeyReflectionField(
                        icon: "shield.lefthalf.filled",
                        title: "Anchor Reflection",
                        color: AATheme.steel,
                        prompt: day.anchorPrompt,
                        text: $anchorReflection,
                        field: .anchor
                    )

                    // Arrow prompt
                    journeyReflectionField(
                        icon: "target",
                        title: "Arrow Reflection",
                        color: AATheme.amber,
                        prompt: day.arrowPrompt,
                        text: $arrowReflection,
                        field: .arrow
                    )

                    // Complete button
                    Button {
                        onComplete(anchorReflection, arrowReflection)
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Complete Day \(day.id)")
                                .font(.system(size: 17, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            (anchorReflection.isEmpty || arrowReflection.isEmpty)
                            ? AATheme.secondaryText.opacity(0.3)
                            : AATheme.amber
                        )
                        .cornerRadius(AATheme.cornerRadius)
                    }
                    .disabled(anchorReflection.isEmpty || arrowReflection.isEmpty)

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, AATheme.paddingMedium)
            }
            .aaScreenBackground()
            .navigationTitle("Day \(day.id)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundColor(AATheme.secondaryText)
                }
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") { focusedField = nil }
                    }
                }
            }
        }
    }

    private func journeyReflectionField(
        icon: String,
        title: String,
        color: Color,
        prompt: String,
        text: Binding<String>,
        field: JourneyField
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                AAIcon(icon, size: 16, color: color)
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AATheme.primaryText)
            }

            Text(prompt)
                .font(.system(size: 15))
                .foregroundColor(AATheme.secondaryText)
                .lineSpacing(4)

            ZStack(alignment: .topLeading) {
                if text.wrappedValue.isEmpty {
                    Text("Write your honest response...")
                        .font(.system(size: 14))
                        .foregroundColor(AATheme.secondaryText.opacity(0.5))
                        .padding(.top, 12)
                        .padding(.leading, 5)
                }
                TextEditor(text: text)
                    .font(.system(size: 14))
                    .foregroundColor(AATheme.primaryText)
                    .scrollContentBackground(.hidden)
                    .focused($focusedField, equals: field)
                    .frame(minHeight: 90)
            }
            .padding(12)
            .background(AATheme.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        focusedField == field ? color : AATheme.secondaryText.opacity(0.2),
                        lineWidth: 1.5
                    )
            )
        }
        .padding(AATheme.paddingMedium)
        .background(AATheme.cardBackground)
        .cornerRadius(AATheme.cornerRadius)
        .shadow(color: AATheme.cardShadow, radius: AATheme.cardShadowRadius, x: 0, y: 2)
    }
}

// MARK: - Journey Completion Celebration
struct JourneyCompletionView: View {
    let series: JourneySeries
    let onStartNext: (JourneySeries) -> Void
    let onDismiss: () -> Void

    @State private var appeared = false
    @State private var confettiParticles: [ConfettiParticle] = []

    var body: some View {
        ZStack {
            AATheme.background.ignoresSafeArea()

            // Confetti layer
            ForEach(confettiParticles) { particle in
                SwiftUI.Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(appeared ? 0 : 1)
                    .animation(
                        .easeOut(duration: particle.duration).delay(particle.delay),
                        value: appeared
                    )
            }

            VStack(spacing: 28) {
                Spacer()

                // Trophy icon
                ZStack {
                    SwiftUI.Circle()
                        .fill(AATheme.warmGold.opacity(0.15))
                        .frame(width: 120, height: 120)
                        .scaleEffect(appeared ? 1.0 : 0.3)

                    Image(systemName: "trophy.fill")
                        .font(.system(size: 56))
                        .foregroundColor(AATheme.warmGold)
                        .scaleEffect(appeared ? 1.0 : 0.1)
                }
                .animation(.spring(response: 0.6, dampingFraction: 0.5).delay(0.2), value: appeared)

                VStack(spacing: 12) {
                    Text("Journey Complete")
                        .font(AATheme.titleFont)
                        .foregroundColor(AATheme.primaryText)

                    Text("You finished the \(series.displayName) journey.")
                        .font(.system(size: 17))
                        .foregroundColor(AATheme.secondaryText)

                    Text("\(kJourneyDays) days of anchoring in truth, standing firm, and sharpening your faith. That's not nothing — that's war won.")
                        .font(.system(size: 15))
                        .foregroundColor(AATheme.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                        .padding(.horizontal, AATheme.paddingXLarge)
                        .padding(.top, 4)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.4), value: appeared)

                Spacer()

                VStack(spacing: 14) {
                    // Offer next series
                    if let next = nextSeries {
                        Button {
                            onStartNext(next)
                        } label: {
                            HStack {
                                Image(systemName: next.icon)
                                Text("Start \(next.displayName)")
                                    .font(.system(size: 17, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(AATheme.amber)
                            .cornerRadius(AATheme.cornerRadius)
                        }
                    }

                    // Restart same
                    Button {
                        onStartNext(series)
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Restart \(series.displayName)")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(AATheme.steel)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AATheme.steel.opacity(0.1))
                        .cornerRadius(14)
                    }

                    Button("Done") { onDismiss() }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(AATheme.secondaryText)
                        .padding(.top, 4)
                }
                .padding(.horizontal, AATheme.paddingXLarge)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.8), value: appeared)

                Spacer().frame(height: 40)
            }
        }
        .onAppear {
            generateConfetti()
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            withAnimation { appeared = true }
        }
    }

    private var nextSeries: JourneySeries? {
        JourneySeries.allCases.first { $0 != series }
    }

    private func generateConfetti() {
        let colors: [Color] = [
            AATheme.warmGold, AATheme.steel, AATheme.amber,
            .orange, .yellow, .green, .blue
        ]
        let screenWidth = UIScreen.main.bounds.width
        confettiParticles = (0..<60).map { _ in
            ConfettiParticle(
                color: colors.randomElement() ?? AATheme.warmGold,
                size: CGFloat.random(in: 4...10),
                position: CGPoint(
                    x: CGFloat.random(in: 0...screenWidth),
                    y: CGFloat.random(in: -50...UIScreen.main.bounds.height * 0.6)
                ),
                duration: Double.random(in: 2.0...4.0),
                delay: Double.random(in: 0...1.5)
            )
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    let color: Color
    let size: CGFloat
    let position: CGPoint
    let duration: Double
    let delay: Double
}
