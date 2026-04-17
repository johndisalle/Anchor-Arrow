// DriftLogView.swift
// Drift Log — one-tap category, note, instant anchoring prayer

import SwiftUI
import UIKit

struct DriftLogView: View {
    @EnvironmentObject var userStore: UserStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedCategory: AnchorTag?
    @State private var selectedCustomCategory: String?
    @State private var note = ""
    @State private var showSuccess = false
    @State private var isLogging = false
    @State private var showAddCustom = false
    @State private var newCustomName = ""
    @FocusState private var noteFocused: Bool

    private var hasSelection: Bool {
        selectedCategory != nil || selectedCustomCategory != nil
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: AATheme.paddingLarge) {

                    // Header card
                    headerSection

                    // Category Grid
                    categorySection

                    // Custom categories (Premium)
                    if userStore.isPremium {
                        customCategorySection
                    }

                    // Note Field
                    if hasSelection {
                        noteSection
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    // Quick anchor prayer
                    if let category = selectedCategory, selectedCustomCategory == nil {
                        anchorPrayerSection(for: category)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    // Log button
                    if hasSelection {
                        logButton
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selectedCategory)
                .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selectedCustomCategory)
            }
            .aaScreenBackground()
            .navigationTitle("Drift Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(AATheme.background, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AATheme.secondaryText)
                }
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") { noteFocused = false }
                    }
                }
            }
        }
        .overlay {
            if showSuccess {
                DriftSuccessOverlay {
                    withAnimation { showSuccess = false }
                    Task {
                        try? await Task.sleep(nanoseconds: 300_000_000)
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Subviews

    private var headerSection: some View {
        HStack(spacing: 12) {
            AAIcon("exclamationmark.shield.fill", size: 24, weight: .semibold, color: AATheme.warning)
            VStack(alignment: .leading, spacing: 2) {
                Text("Drift Detected")
                    .font(AATheme.headlineFont)
                    .foregroundColor(AATheme.primaryText)
                Text("Name it. Anchor back fast.")
                    .font(.system(size: 13))
                    .foregroundColor(AATheme.secondaryText)
            }
            Spacer(minLength: 0)
        }
        .padding(AATheme.paddingMedium)
        .background(AATheme.warning.opacity(0.08))
        .cornerRadius(AATheme.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AATheme.cornerRadius)
                .stroke(AATheme.warning.opacity(0.25), lineWidth: 1)
        )
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("What pulled at you?")
                    .font(AATheme.subheadlineFont)
                    .foregroundColor(AATheme.primaryText)
                Spacer()
                if selectedCategory == nil {
                    Text("Select one to continue")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AATheme.warning.opacity(0.8))
                }
            }

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 12
            ) {
                ForEach(AnchorTag.allCases) { tag in
                    DriftCategoryButton(
                        tag: tag,
                        isSelected: selectedCategory == tag && selectedCustomCategory == nil
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            if selectedCategory == tag && selectedCustomCategory == nil {
                                selectedCategory = nil
                            } else {
                                selectedCategory = tag
                                selectedCustomCategory = nil
                            }
                        }
                    }
                }
            }
        }
    }

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: AATheme.cornerRadiusSmall) {
            Text("Brief note (optional)")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AATheme.primaryText)

            ZStack(alignment: .topLeading) {
                if note.isEmpty {
                    Text("What triggered it? What's the context?")
                        .font(.system(size: 14))
                        .foregroundColor(AATheme.secondaryText.opacity(0.6))
                        .padding(.top, 12)
                        .padding(.leading, 5)
                }
                TextEditor(text: $note)
                    .font(.system(size: 14))
                    .foregroundColor(AATheme.primaryText)
                    .scrollContentBackground(.hidden)
                    .focused($noteFocused)
                    .frame(minHeight: 80, maxHeight: 120)
            }
            .padding(12)
            .background(AATheme.cardBackground)
            .cornerRadius(AATheme.cornerRadiusSmall)
            .overlay(
                RoundedRectangle(cornerRadius: AATheme.cornerRadiusSmall)
                    .stroke(noteFocused ? AATheme.warning : AATheme.steel.opacity(0.2), lineWidth: 1.5)
            )
        }
    }

    private func anchorPrayerSection(for category: AnchorTag) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Anchor Prayer")
                .font(AATheme.subheadlineFont)
                .foregroundColor(AATheme.primaryText)

            VStack(alignment: .leading, spacing: AATheme.paddingSmall) {
                Label("Pray this out loud", systemImage: "mouth.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AATheme.steel)

                Text(driftPrayerText(for: category))
                    .font(AATheme.scriptureFont)
                    .foregroundColor(AATheme.primaryText)
                    .lineSpacing(5)
            }
            .padding(14)
            .background(AATheme.steel.opacity(0.06))
            .cornerRadius(12)
            .shadow(color: AATheme.cardShadow, radius: AATheme.cardShadowRadius, x: 0, y: 2)
        }
    }

    private var logButton: some View {
        Button {
            Task { await logDrift() }
        } label: {
            ZStack {
                if isLogging {
                    ProgressView().tint(.white)
                } else {
                    HStack {
                        Image(systemName: "exclamationmark.shield.fill")
                        Text("Log & Anchor Back")
                            .font(.system(size: 17, weight: .bold))
                    }
                    .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(AATheme.warning)
            .cornerRadius(AATheme.cornerRadius)
        }
        .disabled(isLogging)
    }

    // MARK: - Custom Categories (Premium)
    private var customCategorySection: some View {
        let customs = userStore.appUser?.customDriftCategories ?? []
        return Group {
            if !customs.isEmpty || true {  // always show for premium
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("My Categories")
                            .font(AATheme.subheadlineFont)
                            .foregroundColor(AATheme.primaryText)
                        Spacer()
                        Text("PREMIUM")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundColor(AATheme.warmGold)
                            .padding(.horizontal, AATheme.paddingSmall)
                            .padding(.vertical, 3)
                            .background(AATheme.warmGold.opacity(0.15))
                            .cornerRadius(6)
                    }

                    FlowLayout(spacing: AATheme.paddingSmall) {
                        ForEach(customs, id: \.self) { name in
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    if selectedCustomCategory == name {
                                        selectedCustomCategory = nil
                                    } else {
                                        selectedCustomCategory = name
                                        selectedCategory = .distraction // fallback tag for storage
                                    }
                                }
                            } label: {
                                HStack(spacing: 5) {
                                    Image(systemName: "tag.fill")
                                        .font(.system(size: 11))
                                    Text(name)
                                        .font(.system(size: 13, weight: .semibold))
                                }
                                .foregroundColor(selectedCustomCategory == name ? .white : AATheme.secondaryText)
                                .padding(.horizontal, 12)
                                .padding(.vertical, AATheme.paddingSmall)
                                .background(selectedCustomCategory == name ? AATheme.warning : AATheme.cardBackground)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(selectedCustomCategory == name ? AATheme.warning : AATheme.secondaryText.opacity(0.2), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button(role: .destructive) {
                                    Task { await userStore.removeCustomDriftCategory(name) }
                                } label: {
                                    Label("Remove", systemImage: "trash")
                                }
                            }
                        }

                        // Add button
                        Button {
                            showAddCustom = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "plus")
                                    .font(.system(size: 11, weight: .bold))
                                Text("Add")
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .foregroundColor(AATheme.steel)
                            .padding(.horizontal, 12)
                            .padding(.vertical, AATheme.paddingSmall)
                            .background(AATheme.steel.opacity(0.1))
                            .cornerRadius(20)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .alert("Add Drift Category", isPresented: $showAddCustom) {
                    TextField("e.g. Social Media", text: $newCustomName)
                    Button("Add") {
                        Task {
                            await userStore.addCustomDriftCategory(newCustomName)
                            newCustomName = ""
                        }
                    }
                    Button("Cancel", role: .cancel) { newCustomName = "" }
                } message: {
                    Text("Name a specific struggle to track. You can remove it anytime.")
                }
            }
        }
    }

    // MARK: - Actions
    private func logDrift() async {
        let category = selectedCategory ?? .distraction
        guard hasSelection else { return }
        isLogging = true
        await userStore.logDrift(category: category, note: note, customCategory: selectedCustomCategory)
        isLogging = false

        UINotificationFeedbackGenerator().notificationOccurred(.warning)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            showSuccess = true
        }
    }

    // MARK: - Prayer text per category
    private func driftPrayerText(for tag: AnchorTag) -> String {
        return DriftPrayerLibrary.prayer(for: tag)
    }

}

// MARK: - DriftCategoryButton
struct DriftCategoryButton: View {
    let tag: AnchorTag
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    SwiftUI.Circle()
                        .fill(isSelected ? AATheme.warning.opacity(0.2) : AATheme.cardBackground)
                        .frame(width: 56, height: 56)
                    AAIcon(
                        tag.icon,
                        size: 28,
                        weight: .semibold,
                        color: isSelected ? AATheme.warning : AATheme.primaryText
                    )
                }
                Text(tag.displayName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(isSelected ? AATheme.warning : AATheme.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? AATheme.warning.opacity(0.08) : AATheme.cardBackground)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? AATheme.warning : Color.clear, lineWidth: 2)
            )
            .shadow(color: AATheme.cardShadow, radius: AATheme.cardShadowRadius, x: 0, y: 2)
            .scaleEffect(isSelected ? 0.96 : 1.0)
            .animation(.spring(response: 0.2), value: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(tag.displayName) drift category")
        .accessibilityHint(isSelected ? "Currently selected. Double tap to deselect." : "Double tap to select.")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Drift Success Overlay
struct DriftSuccessOverlay: View {
    let onDismiss: () -> Void
    @State private var appeared = false
    @State private var dismissTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()

            VStack(spacing: 20) {
                AnchorSymbolView(color: AATheme.steel)
                    .frame(width: 64, height: 80)
                    .scaleEffect(appeared ? 1.0 : 0.3)

                Text("Anchored.")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)

                Text("You named it. You brought it to God.\nThat's strength, brother.")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)

                Button(action: onDismiss) {
                    Text("Stand Firm")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 160, height: 46)
                        .background(AATheme.steel)
                        .cornerRadius(23)
                }
                .padding(.top, AATheme.paddingSmall)
            }
            .opacity(appeared ? 1.0 : 0.0)
            .scaleEffect(appeared ? 1.0 : 0.8)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) {
                appeared = true
            }
            dismissTask = Task {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                guard !Task.isCancelled else { return }
                await MainActor.run { onDismiss() }
            }
        }
        .onDisappear { dismissTask?.cancel() }
    }
}
