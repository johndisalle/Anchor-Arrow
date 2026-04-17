// AnchorView.swift
// Morning Anchor Screen — daily scripture prompt + reflection

import SwiftUI

struct AnchorView: View {
    @EnvironmentObject var userStore: UserStore
    @State private var reflection = ""
    @State private var selectedTags: Set<AnchorTag> = []
    @State private var showCompletionAnimation = false
    @State private var dismissTask: Task<Void, Never>?
    @State private var isSubmitting = false
    @State private var showVerseShare = false
    @State private var verseShareImage: UIImage?
    @FocusState private var reflectionFocused: Bool
    @Environment(\.dismiss) var dismiss

    private let prompt = PromptLibrary.anchorPromptForToday()

    private var isReflectionEmpty: Bool {
        reflection.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: AATheme.paddingLarge) {

                    // Already completed banner
                    if userStore.isAnchorDoneToday {
                        CompletedBanner(
                            message: "You anchored this morning. Stand firm today.",
                            color: "BrandAnchor"
                        )
                    }

                    // 1. Scripture Card
                    scriptureCard

                    // 2. Your Reflection
                    reflectionSection

                    // 3. Open in Prayer
                    prayerSection

                    // 4. Any drift pulling at you?
                    tagSection

                    // 5. Mark Anchor Complete
                    if !userStore.isAnchorDoneToday {
                        submitButton
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, AATheme.paddingMedium)
                .padding(.bottom, 100)
            }
            .aaScreenBackground()
            .navigationTitle("Morning Anchor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AATheme.background, for: .navigationBar)
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
                CompletionOverlay(color: "BrandAnchor", message: "Anchored.\nStand firm today.") {
                    withAnimation { showCompletionAnimation = false }
                }
            }
        }
        .sheet(isPresented: $showVerseShare) {
            if let image = verseShareImage {
                VerseShareSheet(image: image)
            }
        }
    }

    // MARK: - Verse Share Image
    private func generateVerseShareImage() -> UIImage {
        let size = CGSize(width: 1080, height: 1080)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            // Background
            UIColor(red: 0.96, green: 0.94, blue: 0.90, alpha: 1).setFill()
            ctx.fill(CGRect(origin: .zero, size: size))

            // Top label
            let topAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 32, weight: .bold),
                .foregroundColor: UIColor(AATheme.steel),
                .kern: 4.0
            ]
            let topText = "ANCHOR & ARROW" as NSString
            let topSize = topText.size(withAttributes: topAttrs)
            topText.draw(at: CGPoint(x: (1080 - topSize.width) / 2, y: 80), withAttributes: topAttrs)

            // Divider
            UIColor(AATheme.amber).setFill()
            ctx.fill(CGRect(x: 440, y: 140, width: 200, height: 3))

            // Quote mark
            let quoteAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "Georgia-Bold", size: 80) ?? UIFont.systemFont(ofSize: 80, weight: .bold),
                .foregroundColor: UIColor(AATheme.warmGold).withAlphaComponent(0.5)
            ]
            ("\u{201C}" as NSString).draw(at: CGPoint(x: 80, y: 180), withAttributes: quoteAttrs)

            // Scripture
            let verseStyle = NSMutableParagraphStyle()
            verseStyle.alignment = .center
            verseStyle.lineSpacing = 12
            let verseAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "Georgia-Italic", size: 42) ?? UIFont.italicSystemFont(ofSize: 42),
                .foregroundColor: UIColor(AATheme.darkIron),
                .paragraphStyle: verseStyle
            ]
            let verseText = prompt.scripture as NSString
            let verseRect = CGRect(x: 100, y: 280, width: 880, height: 400)
            verseText.draw(in: verseRect, withAttributes: verseAttrs)

            // Reference
            let refAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "Georgia-Bold", size: 28) ?? UIFont.systemFont(ofSize: 28, weight: .bold),
                .foregroundColor: UIColor(AATheme.steel)
            ]
            let refText = "— \(prompt.reference)" as NSString
            let refSize = refText.size(withAttributes: refAttrs)
            refText.draw(at: CGPoint(x: (1080 - refSize.width) / 2, y: 720), withAttributes: refAttrs)

            // Bottom
            let bottomStyle = NSMutableParagraphStyle()
            bottomStyle.alignment = .center
            let bottomAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .medium),
                .foregroundColor: UIColor(red: 0.42, green: 0.44, blue: 0.50, alpha: 1),
                .paragraphStyle: bottomStyle
            ]
            ("anchorarrow.app" as NSString).draw(in: CGRect(x: 100, y: 960, width: 880, height: 40), withAttributes: bottomAttrs)
        }
    }

    // MARK: - Scripture Card
    private var scriptureCard: some View {
        VStack(alignment: .leading, spacing: AATheme.paddingMedium) {
            HStack {
                Label(prompt.theme.displayName, systemImage: "anchor")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AATheme.steel)
                    .padding(.horizontal, AATheme.cornerRadiusSmall)
                    .padding(.vertical, 5)
                    .background(AATheme.steel.opacity(0.12))
                    .cornerRadius(AATheme.paddingSmall)
                Spacer()
            }

            Text("\"\(prompt.scripture)\"")
                .font(AATheme.scriptureFont)
                .foregroundColor(AATheme.primaryText)
                .lineSpacing(6)

            HStack {
                Text("— \(prompt.reference)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AATheme.steel)
                Spacer()
                Button {
                    verseShareImage = generateVerseShareImage()
                    showVerseShare = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AATheme.steel)
                        .padding(8)
                        .background(AATheme.steel.opacity(0.1))
                        .clipShape(SwiftUI.Circle())
                }
                .buttonStyle(.plain)
            }

            Divider()
                .background(AATheme.secondaryText.opacity(0.2))

            Text(prompt.reflectionQuestion)
                .font(AATheme.subheadlineFont)
                .foregroundColor(AATheme.primaryText)
                .lineSpacing(5)
        }
        .padding(20)
        .background(AATheme.cardBackground)
        .cornerRadius(AATheme.cornerRadius)
        .shadow(color: AATheme.cardShadow, radius: AATheme.cardShadowRadius, x: 0, y: 2)
    }

    // MARK: - Reflection Input
    private var reflectionSection: some View {
        VStack(alignment: .leading, spacing: AATheme.cornerRadiusSmall) {
            Text("Your Reflection")
                .font(AATheme.subheadlineFont)
                .foregroundColor(AATheme.primaryText)

            ZStack(alignment: .topLeading) {
                if reflection.isEmpty {
                    Text("Write your honest response here...")
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
                    .frame(minHeight: 120)
            }
            .padding(14)
            .background(AATheme.cardBackground)
            .cornerRadius(AATheme.cornerRadiusSmall)
            .overlay(
                RoundedRectangle(cornerRadius: AATheme.cornerRadiusSmall)
                    .stroke(reflectionFocused ? AATheme.steel : AATheme.steel.opacity(0.2), lineWidth: 1.5)
            )
        }
    }

    // MARK: - Tag Grid
    private var tagSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Any drift pulling at you today?")
                .font(AATheme.subheadlineFont)
                .foregroundColor(AATheme.primaryText)

            Text("Select all that apply — this is honest, not shameful.")
                .font(.system(size: 13))
                .foregroundColor(AATheme.secondaryText)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: AATheme.cornerRadiusSmall) {
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
            Text("OPEN IN PRAYER")
                .font(.system(size: 14, weight: .semibold))
                .tracking(1.5)
                .foregroundColor(AATheme.secondaryText)

            VStack(alignment: .leading, spacing: AATheme.cornerRadiusSmall) {
                HStack(spacing: 6) {
                    AAIcon("hands.sparkles.fill", size: 14, weight: .semibold, color: AATheme.steel)
                    Text("Pray this out loud")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AATheme.steel)
                }

                Text(PrayerLibrary.morningPrayerForToday())
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

    // MARK: - Submit Button
    private var submitButton: some View {
        VStack(spacing: 8) {
            Button {
                Task { await submit() }
            } label: {
                ZStack {
                    if isSubmitting {
                        ProgressView().tint(.white)
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
                .background(isReflectionEmpty || isSubmitting
                    ? AATheme.steel.opacity(0.4)
                    : AATheme.steel)
                .cornerRadius(AATheme.cornerRadius)
            }
            .disabled(isReflectionEmpty || isSubmitting)
            .accessibilityLabel("Mark Anchor Complete")
            .accessibilityHint(isReflectionEmpty ? "Write a reflection first" : "Double tap to submit your morning anchor")

            if isReflectionEmpty {
                Text("Write your reflection to set your Anchor.")
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
        await userStore.completeAnchor(
            reflection: trimmed,
            tags: Array(selectedTags)
        )
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
            .padding(.vertical, AATheme.cornerRadiusSmall)
            .background(isSelected ? AATheme.warning.opacity(0.2) : AATheme.cardBackground)
            .foregroundColor(isSelected ? AATheme.warning : AATheme.secondaryText)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? AATheme.warning : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(tag.displayName) drift tag")
        .accessibilityHint(isSelected ? "Selected. Double tap to remove." : "Double tap to select.")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - VerseShareSheet
struct VerseShareSheet: UIViewControllerRepresentable {
    let image: UIImage

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [image], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Completed Banner
struct CompletedBanner: View {
    let message: String
    let color: String

    var body: some View {
        HStack(spacing: 12) {
            AAIcon("checkmark.circle.fill", size: 20, weight: .semibold, color: Color(color))
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AATheme.primaryText)
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
                    AAIcon("checkmark.circle.fill", size: 56, weight: .semibold, color: Color(color))
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
