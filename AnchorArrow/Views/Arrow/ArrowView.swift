// ArrowView.swift
// Evening Arrow Screen — purpose reflection by biblical role

import SwiftUI

struct ArrowView: View {
    @EnvironmentObject var userStore: UserStore
    @State private var selectedRole: ArrowRole = .servantLeader
    @State private var reflection = ""
    @State private var showCompletionAnimation = false
    @State private var isSubmitting = false
    @FocusState private var reflectionFocused: Bool

    private let prompt = PromptLibrary.arrowPromptForToday()

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

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

                    // Reflection Input
                    reflectionSection

                    // Example prompt
                    exampleSection

                    // Submit
                    if !userStore.isArrowDoneToday {
                        submitButton
                    }

                    Spacer(minLength: 80)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .background(Color("BackgroundPrimary").ignoresSafeArea())
            .navigationTitle("Evening Arrow")
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
            Image(systemName: "book.fill")
                .font(.system(size: 13))
                .foregroundColor(Color("BrandArrow"))
            Text("\"Let all that you do be done in love.\" — 1 Cor 16:14")
                .font(.system(size: 13, weight: .medium, design: .serif))
                .italic()
                .foregroundColor(Color("TextSecondary"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color("CardBackground"))
        .cornerRadius(12)
    }

    private var roleSelectorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Which role did God call you into today?")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color("TextPrimary"))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
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
                .padding(.horizontal, 2)
            }
        }
    }

    private var promptCard: some View {
        let matchingPrompt = PromptLibrary.arrowPrompts.first { $0.role == selectedRole }
            ?? PromptLibrary.arrowPromptForToday()

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: selectedRole.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color("BrandArrow"))
                Text(selectedRole.displayName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("BrandArrow"))
                Spacer()
                Text(matchingPrompt.verseReference)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color("TextSecondary"))
            }

            Text(matchingPrompt.question)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(Color("TextPrimary"))
                .lineSpacing(5)

            Text(selectedRole.description)
                .font(.system(size: 13))
                .foregroundColor(Color("TextSecondary"))
                .lineSpacing(4)
        }
        .padding(20)
        .background(Color("CardBackground"))
        .cornerRadius(20)
        .shadow(color: Color("BrandArrow").opacity(0.08), radius: 12, x: 0, y: 4)
        .animation(.easeInOut(duration: 0.2), value: selectedRole)
    }

    private var reflectionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your Response")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color("TextPrimary"))

            ZStack(alignment: .topLeading) {
                if reflection.isEmpty {
                    Text("What did you do? Be specific — even small acts count.")
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
                    .frame(minHeight: 110)
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
                    .stroke(reflectionFocused ? Color("BrandArrow") : Color("TextSecondary").opacity(0.2), lineWidth: 1.5)
            )

            Text("\(reflection.count) / 500")
                .font(.system(size: 12))
                .foregroundColor(reflection.count >= 500 ? Color("BrandDanger") : Color("TextSecondary"))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    private var exampleSection: some View {
        let matchingPrompt = PromptLibrary.arrowPrompts.first { $0.role == selectedRole }
            ?? PromptLibrary.arrowPromptForToday()

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 13))
                    .foregroundColor(Color("BrandGold"))
                Text("Examples")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("BrandGold"))
            }

            Text(matchingPrompt.example)
                .font(.system(size: 13))
                .foregroundColor(Color("TextSecondary"))
                .lineSpacing(4)
        }
        .padding(14)
        .background(Color("BrandGold").opacity(0.08))
        .cornerRadius(12)
        .animation(.easeInOut(duration: 0.2), value: selectedRole)
    }

    private var submitButton: some View {
        VStack(spacing: 14) {
            // Quick one-tap options
            Text("Or log a quick win:")
                .font(.system(size: 13))
                .foregroundColor(Color("TextSecondary"))

            HStack(spacing: 10) {
                QuickWinButton(label: "Prayed", icon: "hands.sparkles.fill") {
                    reflection = "I stopped and prayed intentionally today."
                    Task { await submit() }
                }
                QuickWinButton(label: "Served", icon: "figure.walk") {
                    reflection = "I chose to serve someone without being asked."
                    Task { await submit() }
                }
                QuickWinButton(label: "Spoke Truth", icon: "text.bubble.fill") {
                    reflection = "I spoke truth in love today when it would have been easier to stay quiet."
                    Task { await submit() }
                }
            }

            // Full submit
            Button {
                Task { await submit() }
            } label: {
                ZStack {
                    if isSubmitting {
                        SwiftUI.ProgressView().tint(.white)
                    } else {
                        HStack {
                            Image(systemName: "arrow.up.right.circle.fill")
                            Text("Loose the Arrow")
                                .font(.system(size: 17, weight: .bold))
                        }
                        .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    reflection.isEmpty
                    ? Color("TextSecondary").opacity(0.3)
                    : Color("BrandArrow")
                )
                .cornerRadius(16)
            }
            .disabled(reflection.isEmpty || isSubmitting)
        }
    }

    // MARK: - Submit Action
    private func submit() async {
        guard !reflection.isEmpty else { return }
        isSubmitting = true
        await userStore.completeArrow(reflection: reflection, role: selectedRole)
        isSubmitting = false
        reflectionFocused = false

        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            showCompletionAnimation = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation { showCompletionAnimation = false }
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
            .background(isSelected ? Color("BrandArrow") : Color("CardBackground"))
            .foregroundColor(isSelected ? .white : Color("TextSecondary"))
            .cornerRadius(20)
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color("TextSecondary").opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - QuickWinButton
struct QuickWinButton: View {
    let label: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(Color("BrandArrow"))
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color("TextSecondary"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color("CardBackground"))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}
