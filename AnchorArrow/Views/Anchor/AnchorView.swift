// AnchorView.swift
// Morning Anchor Screen — daily scripture prompt + reflection

import SwiftUI

struct AnchorView: View {
    @EnvironmentObject var userStore: UserStore
    @State private var reflection = ""
    @State private var selectedTags: Set<AnchorTag> = []
    @State private var showCompletionAnimation = false
    @State private var isSubmitting = false
    @FocusState private var reflectionFocused: Bool
    @Environment(\.dismiss) var dismiss

    private let prompt = PromptLibrary.anchorPromptForToday()

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // Already completed banner
                    if userStore.isAnchorDoneToday {
                        CompletedBanner(
                            message: "You anchored this morning. Stand firm today.",
                            color: "BrandAnchor"
                        )
                    }

                    // Scripture Card
                    scriptureCard

                    // Reflection Section
                    reflectionSection

                    // Tag Section
                    tagSection

                    // Prayer Audio
                    prayerSection

                    // Submit Button
                    if !userStore.isAnchorDoneToday {
                        submitButton
                    }

                    Spacer(minLength: 80)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .background(Color("BackgroundPrimary").ignoresSafeArea())
            .navigationTitle("Morning Anchor")
            .navigationBarTitleDisplayMode(.large)
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
                CompletionOverlay(color: "BrandAnchor", message: "Anchored.\nStand firm today.") {
                    withAnimation { showCompletionAnimation = false }
                }
            }
        }
    }

    // MARK: - Scripture Card
    private var scriptureCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label(prompt.theme.displayName, systemImage: "anchor")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color("BrandAnchor"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color("BrandAnchor").opacity(0.12))
                    .cornerRadius(8)
                Spacer()
            }

            Text("\"\(prompt.scripture)\"")
                .font(.system(size: 20, weight: .medium, design: .serif))
                .italic()
                .foregroundColor(Color("TextPrimary"))
                .lineSpacing(6)

            Text("— \(prompt.reference)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color("BrandAnchor"))

            Divider()
                .background(Color("TextSecondary").opacity(0.2))

            Text(prompt.reflectionQuestion)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color("TextPrimary"))
                .lineSpacing(5)
        }
        .padding(20)
        .background(Color("CardBackground"))
        .cornerRadius(20)
        .shadow(color: Color("BrandAnchor").opacity(0.08), radius: 12, x: 0, y: 4)
    }

    // MARK: - Reflection Input
    private var reflectionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your Reflection")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color("TextPrimary"))

            ZStack(alignment: .topLeading) {
                if reflection.isEmpty {
                    Text("Write your honest response here...")
                        .font(.system(size: 15))
                        .foregroundColor(Color("TextSecondary").opacity(0.6))
                        .padding(.top, 14)
                        .padding(.leading, 5)
                }

                TextEditor(text: $reflection)
                    .font(.system(size: 15))
                    .foregroundColor(Color("TextPrimary"))
                    .scrollContentBackground(.hidden)
                    .focused($reflectionFocused)
                    .frame(minHeight: 120)
                    .onChange(of: reflection) { _, newValue in
                        if newValue.count > 500 { reflection = String(newValue.prefix(500)) }
                    }
            }
            .onTapGesture { reflectionFocused = true }
            .padding(14)
            .background(Color("CardBackground"))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(reflectionFocused ? Color("BrandAnchor") : Color("TextSecondary").opacity(0.2), lineWidth: 1.5)
            )

            Text("\(reflection.count) / 500")
                .font(.system(size: 12))
                .foregroundColor(reflection.count >= 500 ? Color("BrandDanger") : Color("TextSecondary"))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    // MARK: - Tag Grid
    private var tagSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Any drift pulling at you today?")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color("TextPrimary"))

            Text("Select all that apply — this is honest, not shameful.")
                .font(.system(size: 13))
                .foregroundColor(Color("TextSecondary"))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(AnchorTag.allCases) { tag in
                    TagChip(
                        tag: tag,
                        isSelected: selectedTags.contains(tag)
                    ) {
                        if selectedTags.contains(tag) {
                            selectedTags.remove(tag)
                        } else {
                            selectedTags.insert(tag)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Prayer Section
    private var prayerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Open in Prayer")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color("TextPrimary"))

            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    Image(systemName: "hands.sparkles")
                        .font(.system(size: 18))
                        .foregroundColor(Color("BrandAnchor"))
                    Text("Morning Anchor Prayer")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color("BrandAnchor"))
                }

                Text("""
                    Lord Jesus, I anchor myself in You this morning.
                    Not in my own strength, my plans, or what the world is offering.
                    You are my rock. You are my truth.
                    Open my eyes to what is pulling me today.
                    I reject the lies. I stand on Your Word.
                    Give me courage to act like the man You've called me to be — watchful, firm, strong in love.
                    Let everything I do today be done for Your glory.
                    Amen.
                    """)
                    .font(.system(size: 15, weight: .regular, design: .serif))
                    .italic()
                    .foregroundColor(Color("TextPrimary"))
                    .lineSpacing(6)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color("BrandAnchor").opacity(0.06))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color("BrandAnchor").opacity(0.2), lineWidth: 1)
            )
        }
    }

    // MARK: - Submit Button
    private var submitButton: some View {
        Button {
            Task { await submit() }
        } label: {
            ZStack {
                if isSubmitting {
                    SwiftUI.ProgressView().tint(.white)
                } else {
                    HStack {
                        Image(systemName: "checkmark.shield.fill")
                        Text("Mark Anchor Complete")
                            .font(.system(size: 17, weight: .bold))
                    }
                    .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(Color("BrandAnchor"))
            .cornerRadius(16)
        }
        .disabled(isSubmitting)
    }

    // MARK: - Submit Action
    private func submit() async {
        isSubmitting = true
        await userStore.completeAnchor(
            reflection: reflection,
            tags: Array(selectedTags)
        )
        isSubmitting = false
        reflectionFocused = false

        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            showCompletionAnimation = true
        }

        // Auto-dismiss overlay after 2.5s
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation { showCompletionAnimation = false }
        }
    }
}

// MARK: - Tag Chip
struct TagChip: View {
    let tag: AnchorTag
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: tag.icon)
                    .font(.system(size: 16, weight: .medium))
                Text(tag.displayName)
                    .font(.system(size: 11, weight: .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isSelected ? Color("BrandWarning").opacity(0.2) : Color("CardBackground"))
            .foregroundColor(isSelected ? Color("BrandWarning") : Color("TextSecondary"))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color("BrandWarning") : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Completed Banner
struct CompletedBanner: View {
    let message: String
    let color: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(Color(color))
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color("TextPrimary"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(color).opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(color).opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Completion Overlay
struct CompletionOverlay: View {
    let color: String
    let message: String
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture(perform: onDismiss)

            VStack(spacing: 20) {
                ZStack {
                    SwiftUI.Circle()
                        .fill(Color(color).opacity(0.2))
                        .frame(width: 100, height: 100)
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 56))
                        .foregroundColor(Color(color))
                }

                Text(message)
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

// MARK: - PromptTheme displayName
extension PromptTheme {
    var displayName: String {
        switch self {
        case .watchful:   return "Be Watchful"
        case .standFirm:  return "Stand Firm"
        case .actLikeMen: return "Act Like Men"
        case .beStrong:   return "Be Strong"
        case .inLove:     return "In Love"
        case .surrender:  return "Surrender"
        case .armor:      return "The Armor"
        }
    }
}
