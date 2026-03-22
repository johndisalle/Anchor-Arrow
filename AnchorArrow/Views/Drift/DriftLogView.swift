// DriftLogView.swift
// Drift Log — one-tap category, note, instant anchoring prayer

import SwiftUI

struct DriftLogView: View {
    @EnvironmentObject var userStore: UserStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedCategory: AnchorTag?
    @State private var note = ""
    @State private var showPrayerPlayer = false
    @State private var showSuccess = false
    @State private var isLogging = false
    @FocusState private var noteFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // Header card
                    headerSection

                    // Category Grid
                    categorySection

                    // Note Field
                    if selectedCategory != nil {
                        noteSection
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    // Quick anchor prayer
                    if let category = selectedCategory {
                        anchorPrayerSection(for: category)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    // Log button
                    if selectedCategory != nil {
                        logButton
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selectedCategory)
            }
            .background(Color("BackgroundPrimary").ignoresSafeArea())
            .navigationTitle("Drift Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color("TextSecondary"))
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { dismiss() }
                }
            }
        }
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.shield.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color("BrandWarning"))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Drift Detected")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color("TextPrimary"))
                    Text("Name it. Anchor back fast.")
                        .font(.system(size: 13))
                        .foregroundColor(Color("TextSecondary"))
                }
            }

            Text("Honesty is strength, not weakness. Naming what's pulling at you is the first step to standing firm.")
                .font(.system(size: 14))
                .foregroundColor(Color("TextSecondary"))
                .lineSpacing(4)
        }
        .padding(16)
        .background(Color("BrandWarning").opacity(0.08))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color("BrandWarning").opacity(0.25), lineWidth: 1)
        )
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What pulled at you?")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color("TextPrimary"))

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                spacing: 12
            ) {
                ForEach(AnchorTag.allCases) { tag in
                    DriftCategoryButton(
                        tag: tag,
                        isSelected: selectedCategory == tag
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedCategory = selectedCategory == tag ? nil : tag
                        }
                    }
                }
            }
        }
    }

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Brief note (optional)")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color("TextPrimary"))

            ZStack(alignment: .topLeading) {
                if note.isEmpty {
                    Text("What triggered it? What's the context?")
                        .font(.system(size: 14))
                        .foregroundColor(Color("TextSecondary").opacity(0.6))
                        .padding(.top, 12)
                        .padding(.leading, 5)
                }
                TextEditor(text: $note)
                    .font(.system(size: 14))
                    .foregroundColor(Color("TextPrimary"))
                    .scrollContentBackground(.hidden)
                    .focused($noteFocused)
                    .frame(minHeight: 80, maxHeight: 120)
            }
            .padding(12)
            .background(Color("CardBackground"))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(noteFocused ? Color("BrandWarning") : Color("TextSecondary").opacity(0.2), lineWidth: 1.5)
            )
        }
    }

    private func anchorPrayerSection(for category: AnchorTag) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Anchor Prayer")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color("TextPrimary"))

            Button {
                noteFocused = false
                showPrayerPlayer = true
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        SwiftUI.Circle()
                            .fill(Color("BrandAnchor").opacity(0.15))
                            .frame(width: 44, height: 44)
                        Image(systemName: "play.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color("BrandAnchor"))
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Play Anchoring Prayer")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color("TextPrimary"))
                        Text("~20 sec • Direct • Grounding")
                            .font(.system(size: 12))
                            .foregroundColor(Color("TextSecondary"))
                    }
                    Spacer()
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color("BrandAnchor").opacity(0.5))
                }
                .padding(14)
                .background(Color("CardBackground"))
                .cornerRadius(14)
            }
            .buttonStyle(.plain)

            // Text prayer (fallback, always visible)
            VStack(alignment: .leading, spacing: 8) {
                Text("Or read aloud:")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color("TextSecondary"))

                Text(driftPrayerText(for: category))
                    .font(.system(size: 14, weight: .medium, design: .serif))
                    .italic()
                    .foregroundColor(Color("TextPrimary"))
                    .lineSpacing(5)
            }
            .padding(14)
            .background(Color("BrandAnchor").opacity(0.06))
            .cornerRadius(12)
        }
        .sheet(isPresented: $showPrayerPlayer) {
            PrayerAudioPlayerView(
                title: "Anchoring Prayer",
                fileName: category.audioPrayer,
                prayerText: driftPrayerText(for: category)
            )
        }
    }

    private var logButton: some View {
        Button {
            Task { await logDrift() }
        } label: {
            ZStack {
                if isLogging {
                    SwiftUI.ProgressView().tint(.white)
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
            .background(Color("BrandWarning"))
            .cornerRadius(16)
        }
        .disabled(isLogging)
    }

    // MARK: - Actions
    private func logDrift() async {
        guard let category = selectedCategory else { return }
        isLogging = true
        await userStore.logDrift(category: category, note: note)
        isLogging = false

        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            showSuccess = true
        }
    }

    // MARK: - Prayer text per category
    private func driftPrayerText(for tag: AnchorTag) -> String {
        switch tag {
        case .temptation, .lust:
            return "Lord Jesus, anchor me firm right now. I reject this temptation. It has no power over me because I belong to You. Fill me with Your Spirit. Let me walk in Your freedom. Amen."
        case .pride:
            return "Father, forgive me for exalting myself. Humble me now. You are God, I am not. Let me decrease and You increase in every part of my life. Amen."
        case .anger:
            return "God, I bring this anger to You. Let me be slow to anger and slow to speak. Guard my tongue. Protect those around me from my flesh. Give me Your peace. Amen."
        case .selfReliance:
            return "Lord, I repent of trusting in my own strength. Without You I can do nothing. I surrender this to You right now. Be my strength. Amen."
        case .avoidance:
            return "Jesus, give me the courage to face what I am running from. I choose obedience over comfort. You equip what You call. Let me take the next step. Amen."
        case .anxiety:
            return "Father, I cast this anxiety on You because You care for me. You hold tomorrow. You are not surprised. Let Your peace guard my heart and mind in Christ Jesus. Amen."
        case .doubt:
            return "Lord, I believe. Help my unbelief. Your Word is true whether I feel it or not. Anchor me in truth, not feelings. I stand on Your faithfulness. Amen."
        default:
            return "Lord Jesus, anchor me firm right now. I reject this lie. I stand on Your truth. Fill me with Your Spirit. Amen."
        }
    }
}

// MARK: - DriftCategoryButton
struct DriftCategoryButton: View {
    let tag: AnchorTag
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    SwiftUI.Circle()
                        .fill(isSelected ? Color("BrandWarning").opacity(0.2) : Color("CardBackground"))
                        .frame(width: 46, height: 46)
                    Image(systemName: tag.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(isSelected ? Color("BrandWarning") : Color("TextSecondary"))
                }
                Text(tag.displayName)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isSelected ? Color("BrandWarning") : Color("TextSecondary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color("BrandWarning").opacity(0.08) : Color("CardBackground"))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color("BrandWarning") : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isSelected ? 0.96 : 1.0)
            .animation(.spring(response: 0.2), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Drift Success Overlay
struct DriftSuccessOverlay: View {
    let onDismiss: () -> Void
    @State private var appeared = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "anchor.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(Color("BrandAnchor"))
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
                        .background(Color("BrandAnchor"))
                        .cornerRadius(23)
                }
                .padding(.top, 8)
            }
            .opacity(appeared ? 1.0 : 0.0)
            .scaleEffect(appeared ? 1.0 : 0.8)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) {
                appeared = true
            }
            // Auto-dismiss after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: onDismiss)
        }
    }
}
