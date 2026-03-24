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

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

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
                .padding(.top, 16)
            }
            .background(Color("BackgroundPrimary").ignoresSafeArea())
            .navigationTitle(activeSeries.displayName + " Journey")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Color("BrandAnchor"))
                }
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
                "Start the 30-day \(selectedSeries.displayName) Journey?",
                isPresented: $showStartConfirm,
                titleVisibility: .visible
            ) {
                Button("Start Journey") {
                    Task { await startJourney() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Commit to 30 days of guided Scripture, daily anchoring, and purposeful action. One day at a time.")
            }
            .onAppear {
                let series = userStore.currentJourneySeries
                selectedSeries = series
                journeyDays = PromptLibrary.journeyDays(for: series)
            }
        }
    }

    // MARK: - Subviews

    private var journeyHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "map.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color("BrandArrow"))
                Text("30-Day Guided Plan")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("BrandArrow"))
            }

            Text(activeSeries == .armorOfGod
                 ? "Four weeks through Ephesians 6 — each piece of God's armor examined, applied, and worn into battle. Each day unlocks the next."
                 : "Four weeks of deep, sequential truth — from watchful rootedness to purposeful love. Each day unlocks the next.")
                .font(.system(size: 15))
                .foregroundColor(Color("TextSecondary"))
                .lineSpacing(4)

            // Week themes
            HStack(spacing: 8) {
                ForEach(weekThemes, id: \.week) { theme in
                    VStack(spacing: 4) {
                        Text("Wk \(theme.week)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(theme.color)
                        Text(theme.title)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(Color("TextSecondary"))
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(theme.color.opacity(0.1))
                    .cornerRadius(10)
                }
            }
        }
        .padding(16)
        .background(Color("CardBackground"))
        .cornerRadius(20)
    }

    private var startJourneyCTA: some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.stand.line.dotted.figure.stand")
                .font(.system(size: 52))
                .foregroundColor(Color("BrandArrow"))

            VStack(spacing: 8) {
                Text("Ready to Commit?")
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(Color("TextPrimary"))

                Text("This journey is free to start. 30 days, one day at a time. No skipping ahead — each day builds on the last.")
                    .font(.system(size: 15))
                    .foregroundColor(Color("TextSecondary"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)
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
                .background(Color("BrandArrow"))
                .cornerRadius(16)
            }
            .disabled(isStarting)
            .padding(.horizontal, 32)
        }
        .padding(.vertical, 32)
    }

    private var journeyProgressBar: some View {
        let currentDay = userStore.appUser?.journeyDay ?? 0
        let progress = Double(currentDay) / 30.0

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Day \(currentDay) of 30")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("BrandArrow"))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color("CardBackground"))
                        .frame(height: 10)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [Color("BrandAnchor"), Color("BrandArrow")],
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
        .padding(16)
        .background(Color("CardBackground"))
        .cornerRadius(16)
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
                            .foregroundColor(Color("TextSecondary"))
                    }
                    .padding(.horizontal, 4)
                    .padding(.top, 16)

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
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color("TextPrimary"))

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
                        Image(systemName: series.icon)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(selectedSeries == series
                                             ? Color("BrandArrow") : Color("TextSecondary"))
                            .frame(width: 40)

                        VStack(alignment: .leading, spacing: 3) {
                            HStack {
                                Text(series.displayName)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(isAvailable ? Color("TextPrimary") : Color("TextSecondary").opacity(0.5))
                                if completed {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 13))
                                        .foregroundColor(.green)
                                }
                                if !isAvailable {
                                    Text("PREMIUM")
                                        .font(.system(size: 9, weight: .heavy))
                                        .foregroundColor(Color("BrandGold"))
                                        .padding(.horizontal, 6).padding(.vertical, 2)
                                        .background(Color("BrandGold").opacity(0.15))
                                        .cornerRadius(4)
                                }
                            }
                            Text(series.subtitle)
                                .font(.system(size: 12))
                                .foregroundColor(Color("TextSecondary"))
                        }
                        Spacer()

                        if selectedSeries == series {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color("BrandArrow"))
                        }
                    }
                    .padding(14)
                    .background(selectedSeries == series
                                ? Color("BrandArrow").opacity(0.07) : Color("CardBackground"))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(selectedSeries == series
                                    ? Color("BrandArrow").opacity(0.3) : Color.clear, lineWidth: 1.5)
                    )
                }
                .buttonStyle(.plain)
                .disabled(!isAvailable)
            }
        }
        .padding(16)
        .background(Color("CardBackground"))
        .cornerRadius(20)
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
                (1, "Truth & Righteousness", Color("BrandAnchor")),
                (2, "Gospel & Faith", Color.blue),
                (3, "Salvation & Word", Color("BrandArrow")),
                (4, "Prayer & Stand", Color.red)
            ]
        case .standFirm:
            return [
                (1, "Be Watchful", Color("BrandAnchor")),
                (2, "Stand Firm", Color.blue),
                (3, "Act Like Men", Color("BrandArrow")),
                (4, "In Love", Color.red)
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
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    } else if !isUnlocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
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
                            .foregroundColor(isUnlocked ? Color("TextPrimary") : Color("TextSecondary").opacity(0.5))
                        if isCurrent {
                            Text("TODAY")
                                .font(.system(size: 9, weight: .heavy))
                                .foregroundColor(Color("BrandArrow"))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color("BrandArrow").opacity(0.15))
                                .cornerRadius(4)
                        }
                    }
                    Text(day.theme)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(isUnlocked ? Color("TextPrimary") : Color("TextSecondary").opacity(0.4))

                    if isUnlocked {
                        Text(day.scripture)
                            .font(.system(size: 12))
                            .foregroundColor(Color("TextSecondary"))
                            .lineLimit(1)
                    }
                }

                Spacer()

                if isUnlocked {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color("TextSecondary"))
                }
            }
            .padding(14)
            .background(
                isCurrent
                ? Color("BrandArrow").opacity(0.07)
                : Color("CardBackground")
            )
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isCurrent ? Color("BrandArrow").opacity(0.3) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .disabled(!isUnlocked)
    }

    private var circleColor: Color {
        if isCompleted { return .green }
        if isCurrent { return Color("BrandArrow") }
        if isUnlocked { return Color("BrandAnchor") }
        return Color("TextSecondary").opacity(0.25)
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
                VStack(spacing: 24) {

                    // Day chip
                    HStack {
                        Label("Day \(day.id) of 30 — Week \(day.week)", systemImage: "map")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color("BrandArrow"))
                        Spacer()
                    }

                    // Theme + Scripture
                    VStack(alignment: .leading, spacing: 12) {
                        Text(day.theme)
                            .font(.system(size: 24, weight: .heavy, design: .rounded))
                            .foregroundColor(Color("TextPrimary"))

                        Text("\"\(day.scripture)\"")
                            .font(.system(size: 17, weight: .medium, design: .serif))
                            .italic()
                            .foregroundColor(Color("TextPrimary"))
                            .lineSpacing(5)
                    }
                    .padding(20)
                    .background(Color("CardBackground"))
                    .cornerRadius(20)

                    // Devotional
                    if !day.devotional.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Today's Devotional", systemImage: "book.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color("BrandAnchor"))
                            Text(day.devotional)
                                .font(.system(size: 15))
                                .foregroundColor(Color("TextPrimary"))
                                .lineSpacing(6)
                        }
                        .padding(20)
                        .background(Color("CardBackground"))
                        .cornerRadius(20)
                    }

                    // Anchor prompt
                    journeyReflectionField(
                        icon: "anchor",
                        title: "Anchor Reflection",
                        color: "BrandAnchor",
                        prompt: day.anchorPrompt,
                        text: $anchorReflection,
                        field: .anchor
                    )

                    // Arrow prompt
                    journeyReflectionField(
                        icon: "arrow.up.right.circle.fill",
                        title: "Arrow Reflection",
                        color: "BrandArrow",
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
                            ? Color("TextSecondary").opacity(0.3)
                            : Color("BrandArrow")
                        )
                        .cornerRadius(16)
                    }
                    .disabled(anchorReflection.isEmpty || arrowReflection.isEmpty)

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .background(Color("BackgroundPrimary").ignoresSafeArea())
            .navigationTitle("Day \(day.id)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundColor(Color("TextSecondary"))
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
        color: String,
        prompt: String,
        text: Binding<String>,
        field: JourneyField
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(color))
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
            }

            Text(prompt)
                .font(.system(size: 15))
                .foregroundColor(Color("TextSecondary"))
                .lineSpacing(4)

            ZStack(alignment: .topLeading) {
                if text.wrappedValue.isEmpty {
                    Text("Write your honest response...")
                        .font(.system(size: 14))
                        .foregroundColor(Color("TextSecondary").opacity(0.5))
                        .padding(.top, 12)
                        .padding(.leading, 5)
                }
                TextEditor(text: text)
                    .font(.system(size: 14))
                    .foregroundColor(Color("TextPrimary"))
                    .scrollContentBackground(.hidden)
                    .focused($focusedField, equals: field)
                    .frame(minHeight: 90)
            }
            .padding(12)
            .background(Color("CardBackground"))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        focusedField == field ? Color(color) : Color("TextSecondary").opacity(0.2),
                        lineWidth: 1.5
                    )
            )
        }
        .padding(16)
        .background(Color("CardBackground"))
        .cornerRadius(16)
    }
}
