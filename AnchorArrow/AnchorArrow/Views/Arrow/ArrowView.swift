// ArrowView.swift
// Evening Arrow Screen — purpose reflection by biblical role

import SwiftUI

struct ArrowView: View {
    @EnvironmentObject var userStore: UserStore
    @State private var selectedRole: ArrowRole = .servantLeader
    @State private var reflection = ""
    @State private var showCompletionAnimation = false
    @State private var dismissTask: Task<Void, Never>?
    @State private var isSubmitting = false
    @FocusState private var reflectionFocused: Bool

    private let prompt = PromptLibrary.arrowPromptForToday()

    private var isReflectionEmpty: Bool {
        reflection.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: AATheme.paddingLarge) {

                    // Completed banner
                    if userStore.isArrowDoneToday {
                        CompletedBanner(
                            message: "Arrow loosed. You advanced the kingdom today.",
                            color: "BrandArrow"
                        )
                    }

                    // Scripture reminder
                    scriptureChip

                    // Role Selector
                    roleSelectorSection

                    // Role-specific prompt
                    promptCard

                    // Quick Responses (pre-fill, role-specific)
                    quickResponseSection
                        .animation(.easeInOut(duration: 0.2), value: selectedRole)

                    // Reflection Input
                    reflectionSection

                    // Examples (collapsible)
                    examplesDisclosure

                    // Close in Prayer
                    eveningPrayerSection

                    // Submit
                    if !userStore.isArrowDoneToday {
                        submitButton
                    }

                    Spacer(minLength: 80)
                }
                .padding(.horizontal, 20)
                .padding(.top, AATheme.paddingMedium)
            }
            .background(
                LinearGradient(
                    colors: [AATheme.steel.opacity(0.08), AATheme.background, AATheme.background],
                    startPoint: .top,
                    endPoint: .bottom
                ).ignoresSafeArea()
            )
            .navigationTitle(Calendar.current.component(.hour, from: Date()) >= 15 ? "Evening Arrow" : "Loose Your Arrow")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") { reflectionFocused = false }
                    }
                }
            }
        }
        .overlay {
            if showCompletionAnimation {
                CompletionOverlay(color: "BrandArrow", message: "Arrow Loosed.\nWell done, brother.") {
                    withAnimation { showCompletionAnimation = false }
                }
            }
        }
        .onAppear {
            // Default role selection from prompt library
            selectedRole = prompt.role
        }
    }

    // MARK: - Subviews

    private var scriptureChip: some View {
        HStack {
            AAIcon("book.fill", size: 13, weight: .semibold, color: AATheme.amber)
            Text("\"\(prompt.question.prefix(60))...\" — \(prompt.verseReference)")
                .font(AATheme.scriptureFont)
                .foregroundColor(AATheme.secondaryText)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AATheme.cardBackground)
        .cornerRadius(12)
        .shadow(color: AATheme.cardShadow, radius: AATheme.cardShadowRadius, x: 0, y: 2)
    }

    private var roleSelectorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Which role did God call you into today?")
                .font(AATheme.subheadlineFont)
                .foregroundColor(AATheme.primaryText)

            FlowLayout(spacing: AATheme.cornerRadiusSmall) {
                ForEach(ArrowRole.allCases) { role in
                    RoleChip(
                        role: role,
                        isSelected: selectedRole == role
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedRole = role
                        }
                    }
                }
            }
        }
    }

    private var promptCard: some View {
        // Rotate through all prompts matching the selected role, indexed by day
        let rolePrompts = PromptLibrary.allArrowPrompts.filter { $0.role == selectedRole }
        let dayOfYear = max(1, Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1)
        let matchingPrompt = rolePrompts.isEmpty
            ? PromptLibrary.arrowPromptForToday()
            : rolePrompts[(dayOfYear - 1) % rolePrompts.count]

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                AAIcon(selectedRole.icon, size: 18, color: AATheme.amber)
                Text(selectedRole.displayName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AATheme.amber)
                Spacer()
                Text(matchingPrompt.verseReference)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AATheme.secondaryText)
            }

            Text(matchingPrompt.question)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(AATheme.primaryText)
                .lineSpacing(5)

            Text(selectedRole.description)
                .font(.system(size: 13))
                .foregroundColor(AATheme.secondaryText)
                .lineSpacing(4)
        }
        .padding(20)
        .background(AATheme.cardBackground)
        .cornerRadius(AATheme.cornerRadius)
        .shadow(color: AATheme.cardShadow, radius: AATheme.cardShadowRadius, x: 0, y: 2)
        .animation(.easeInOut(duration: 0.2), value: selectedRole)
    }

    private var quickResponses: [String] {
        switch selectedRole {
        case .servantLeader:
            return ["Served my family without being asked", "Led a meeting with humility", "Put someone else's needs first", "Helped a neighbor or coworker"]
        case .truthTeller:
            return ["Spoke truth to a friend in love", "Had a hard conversation I'd been avoiding", "Shared my faith with someone", "Called out something that needed to be said"]
        case .prayerWarrior:
            return ["Prayed for my wife/family", "Interceded for a brother", "Spent time in focused prayer", "Prayed for someone who doesn't know Christ"]
        case .providerProtector:
            return ["Provided for my family's needs", "Protected someone vulnerable", "Made a sacrifice for my household", "Stood up for what's right"]
        case .discipleMaker:
            return ["Mentored a younger man", "Shared a verse with someone", "Invested time in someone's growth", "Invited someone to church or study"]
        }
    }

    private var quickResponseSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick Response")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AATheme.secondaryText)

            FlowLayout(spacing: 8) {
                ForEach(quickResponses, id: \.self) { response in
                    Button {
                        reflection = response
                    } label: {
                        Text(response)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(reflection == response ? .white : AATheme.primaryText)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(reflection == response ? AATheme.amber : AATheme.amber.opacity(0.1))
                            .cornerRadius(20)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var reflectionSection: some View {
        VStack(alignment: .leading, spacing: AATheme.cornerRadiusSmall) {
            Text("Your Response")
                .font(AATheme.subheadlineFont)
                .foregroundColor(AATheme.primaryText)

            ZStack(alignment: .topLeading) {
                if reflection.isEmpty {
                    Text("What did you do? Be specific — even small acts count.")
                        .font(.system(size: 15))
                        .foregroundColor(AATheme.secondaryText.opacity(0.6))
                        .padding(.top, 14)
                        .padding(.leading, 5)
                }
                TextEditor(text: $reflection)
                    .font(.system(size: 15))
                    .foregroundColor(AATheme.primaryText)
                    .scrollContentBackground(.hidden)
                    .focused($reflectionFocused)
                    .frame(minHeight: 110)
            }
            .padding(14)
            .background(AATheme.cardBackground)
            .cornerRadius(AATheme.cornerRadiusSmall)
            .overlay(
                RoundedRectangle(cornerRadius: AATheme.cornerRadiusSmall)
                    .stroke(reflectionFocused ? AATheme.amber : AATheme.steel.opacity(0.2), lineWidth: 1.5)
            )
        }
    }

    private var examplesDisclosure: some View {
        let matchingPrompt = PromptLibrary.arrowPrompts.first { $0.role == selectedRole }
            ?? PromptLibrary.arrowPromptForToday()

        return DisclosureGroup {
            Text(matchingPrompt.example)
                .font(.system(size: 13))
                .foregroundColor(AATheme.secondaryText)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 10)
        } label: {
            HStack(spacing: 8) {
                AAIcon("lightbulb.fill", size: 13, weight: .semibold, color: AATheme.amber)
                Text("Need ideas?")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AATheme.amber)
            }
        }
        .tint(AATheme.amber)
        .padding(14)
        .background(AATheme.cardBackground)
        .cornerRadius(12)
        .animation(.easeInOut(duration: 0.2), value: selectedRole)
    }

    private var eveningPrayerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CLOSE IN PRAYER")
                .font(.system(size: 14, weight: .semibold))
                .tracking(1.5)
                .foregroundColor(AATheme.secondaryText)

            VStack(alignment: .leading, spacing: AATheme.cornerRadiusSmall) {
                HStack(spacing: 6) {
                    AAIcon("hands.sparkles.fill", size: 14, weight: .semibold, color: AATheme.amber)
                    Text("Pray this out loud")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AATheme.amber)
                }

                Text(PrayerLibrary.eveningPrayerForToday())
                    .font(AATheme.scriptureFont)
                    .foregroundColor(AATheme.primaryText)
                    .lineSpacing(6)
            }
            .padding(AATheme.paddingMedium)
            .background(AATheme.cardBackground)
            .cornerRadius(AATheme.cornerRadius)
            .shadow(color: AATheme.cardShadow, radius: AATheme.cardShadowRadius, x: 0, y: 2)
        }
    }

    private var submitButton: some View {
        VStack(spacing: 8) {
            Button {
                Task { await submit() }
            } label: {
                ZStack {
                    if isSubmitting {
                        ProgressView().tint(.white)
                    } else {
                        HStack(spacing: AATheme.cornerRadiusSmall) {
                            CrossedArrowsView(color: .white)
                                .frame(width: 28, height: 18)
                            Text("Loose the Arrow")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    isReflectionEmpty || isSubmitting
                    ? AATheme.secondaryText.opacity(0.3)
                    : AATheme.amber
                )
                .cornerRadius(AATheme.cornerRadius)
            }
            .disabled(isReflectionEmpty || isSubmitting)
            .accessibilityLabel("Loose the Arrow")
            .accessibilityHint(isReflectionEmpty ? "Write a reflection first" : "Double tap to submit your evening arrow")

            if isReflectionEmpty {
                Text("Write at least one sentence to loose your Arrow.")
                    .font(.system(size: 12))
                    .foregroundColor(AATheme.secondaryText)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isReflectionEmpty)
    }

    // MARK: - Submit Action
    private func submit() async {
        let trimmed = reflection.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        isSubmitting = true
        await userStore.completeArrow(reflection: trimmed, role: selectedRole)
        isSubmitting = false
        reflectionFocused = false

        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            showCompletionAnimation = true
        }
        dismissTask?.cancel()
        dismissTask = Task {
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                withAnimation { showCompletionAnimation = false }
            }
        }
    }
}

// MARK: - RoleChip
struct RoleChip: View {
    let role: ArrowRole
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: role.icon)
                    .font(.system(size: 13, weight: .semibold))
                Text(role.displayName)
                    .font(.system(size: 13, weight: .semibold))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(isSelected ? AATheme.amber.opacity(0.18) : AATheme.cardBackground)
            .foregroundColor(isSelected ? AATheme.amber : AATheme.secondaryText)
            .cornerRadius(20)
            .overlay(
                Capsule()
                    .stroke(
                        isSelected ? AATheme.amber : AATheme.secondaryText.opacity(0.2),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(role.displayName) role")
        .accessibilityHint(isSelected ? "Currently selected" : "Double tap to select")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
