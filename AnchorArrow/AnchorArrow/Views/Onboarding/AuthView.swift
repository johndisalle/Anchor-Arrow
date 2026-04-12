// AuthView.swift
// Email/Password + Apple Sign-In screen

import SwiftUI
import AuthenticationServices

struct AuthView: View {
    @Binding var isSignUp: Bool
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userStore: UserStore

    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var agreedToTerms = false
    @FocusState private var focusedField: AuthField?

    enum AuthField { case name, email, password, confirm }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: isSignUp ? "person.badge.plus" : "anchor")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundColor(AATheme.steel)
                        .padding(.top, 60)

                    Text(isSignUp ? "Join the Brotherhood" : "Welcome Back")
                        .font(AATheme.titleFont)
                        .foregroundColor(AATheme.primaryText)

                    Text(isSignUp
                         ? "Create your account to begin standing firm."
                         : "Sign in to continue your journey.")
                        .font(.system(size: 15))
                        .foregroundColor(AATheme.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 40)

                // Fields
                VStack(spacing: 16) {
                    if isSignUp {
                        AuthTextField(
                            icon: "person.fill",
                            placeholder: "Your name",
                            text: $displayName
                        )
                        .focused($focusedField, equals: .name)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .email }
                    }

                    AuthTextField(
                        icon: "envelope.fill",
                        placeholder: "Email address",
                        text: $email,
                        keyboardType: .emailAddress
                    )
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .password }
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                    AuthTextField(
                        icon: "lock.fill",
                        placeholder: "Password",
                        text: $password,
                        isSecure: true
                    )
                    .focused($focusedField, equals: .password)
                    .submitLabel(isSignUp ? .next : .go)
                    .onSubmit {
                        if isSignUp { focusedField = .confirm }
                        else { Task { await submitAuth() } }
                    }

                    if isSignUp {
                        AuthTextField(
                            icon: "lock.shield.fill",
                            placeholder: "Confirm password",
                            text: $confirmPassword,
                            isSecure: true
                        )
                        .focused($focusedField, equals: .confirm)
                        .submitLabel(.go)
                        .onSubmit { Task { await submitAuth() } }
                    }
                }
                .padding(.horizontal, AATheme.paddingLarge)

                // EULA Agreement (sign-up only)
                if isSignUp {
                    VStack(spacing: 8) {
                        HStack(alignment: .top, spacing: 12) {
                            Button {
                                agreedToTerms.toggle()
                            } label: {
                                AAIcon(agreedToTerms ? "checkmark.square.fill" : "square", size: 22, weight: .semibold, color: agreedToTerms ? AATheme.steel : AATheme.secondaryText.opacity(0.5))
                            }
                            .buttonStyle(.plain)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("I agree to the ")
                                    .font(.system(size: 13))
                                    .foregroundColor(AATheme.primaryText)
                                +
                                Text("Terms of Use")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(AATheme.steel)
                                +
                                Text(" and ")
                                    .font(.system(size: 13))
                                    .foregroundColor(AATheme.primaryText)
                                +
                                Text("Privacy Policy")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(AATheme.steel)

                                Text("No tolerance for objectionable content or abusive users.")
                                    .font(.system(size: 11))
                                    .foregroundColor(AATheme.secondaryText)
                            }
                        }

                        HStack(spacing: 12) {
                            Spacer().frame(width: 22)
                            HStack(spacing: 4) {
                                Link("Terms of Use", destination: URL(string: "https://johndisalle.github.io/Anchor-Arrow/terms-of-use.html")!)
                                Text("|").foregroundColor(AATheme.secondaryText.opacity(0.4))
                                Link("Privacy Policy", destination: URL(string: "https://johndisalle.github.io/Anchor-Arrow/privacy-policy.html")!)
                            }
                            .font(.system(size: 12, weight: .medium))
                        }
                    }
                    .padding(.horizontal, AATheme.paddingLarge)
                    .padding(.top, AATheme.paddingMedium)
                }

                // Error
                if showError {
                    Text(errorMessage)
                        .font(.system(size: 14))
                        .foregroundColor(AATheme.destructive)
                        .padding(.horizontal, 32)
                        .padding(.top, 12)
                        .multilineTextAlignment(.center)
                }

                // Primary Button
                Button {
                    Task { await submitAuth() }
                } label: {
                    ZStack {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(isSignUp ? "Create Account" : "Sign In")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                }
                .buttonStyle(AAPrimaryButtonStyle())
                .disabled(isLoading)
                .padding(.top, AATheme.paddingLarge)
                .padding(.horizontal, AATheme.paddingLarge)

                // Divider
                HStack {
                    Rectangle().fill(AATheme.secondaryText.opacity(0.2)).frame(height: 1)
                    Text("or")
                        .font(.system(size: 13))
                        .foregroundColor(AATheme.secondaryText)
                        .padding(.horizontal, 12)
                    Rectangle().fill(AATheme.secondaryText.opacity(0.2)).frame(height: 1)
                }
                .padding(.horizontal, AATheme.paddingLarge)
                .padding(.vertical, 20)

                // Apple Sign-In
                SignInWithAppleButton(
                    isSignUp ? .signUp : .signIn,
                    onRequest: { request in
                        do {
                            let nonce = try authManager.prepareAppleSignIn()
                            request.requestedScopes = [.fullName, .email]
                            request.nonce = nonce
                        } catch {
                            showAuthError(authManager.friendlyError(error))
                        }
                    },
                    onCompletion: { result in
                        Task {
                            do {
                                try await authManager.handleAppleSignIn(result: result)
                                await userStore.loadUserData(uid: authManager.currentUID ?? "")
                                userStore.completeOnboarding()
                            } catch {
                                showAuthError(authManager.friendlyError(error))
                            }
                        }
                    }
                )
                .signInWithAppleButtonStyle(.whiteOutline)
                .frame(height: 54)
                .cornerRadius(AATheme.cornerRadius)
                .padding(.horizontal, AATheme.paddingLarge)

                // Toggle sign in / sign up
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isSignUp.toggle()
                        errorMessage = ""
                        showError = false
                    }
                } label: {
                    Text(isSignUp
                         ? "Already have an account? **Sign In**"
                         : "New here? **Create an account**")
                        .font(.system(size: 15))
                        .foregroundColor(AATheme.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.top, AATheme.paddingLarge)
                        .padding(.horizontal, 32)
                }

                if !isSignUp {
                    Button("Forgot password?") {
                        Task { await resetPassword() }
                    }
                    .font(.system(size: 14))
                    .foregroundColor(AATheme.steel)
                    .padding(.top, 12)
                }

                Spacer().frame(height: 60)
            }
        }
        .aaScreenBackground()
    }

    // MARK: - Actions
    private func submitAuth() async {
        focusedField = nil
        showError = false
        errorMessage = ""

        // Validation
        guard !email.isEmpty, !password.isEmpty else {
            showAuthError("Please fill in all fields."); return
        }
        if isSignUp {
            guard !displayName.isEmpty else {
                showAuthError("Please enter your name."); return
            }
            guard password == confirmPassword else {
                showAuthError("Passwords don't match."); return
            }
            guard password.count >= 6 else {
                showAuthError("Password must be at least 6 characters."); return
            }
            guard agreedToTerms else {
                showAuthError("You must agree to the Terms of Use to create an account."); return
            }
        }

        isLoading = true
        defer { isLoading = false }

        do {
            if isSignUp {
                try await authManager.signUp(email: email, password: password, displayName: displayName)
                guard let uid = authManager.currentUID else { return }
                try await FirestoreService.shared.createUser(uid: uid, email: email, displayName: displayName)
                // Persist EULA acceptance to Firestore
                try await FirestoreService.shared.updateUser(uid: uid, fields: ["acceptedTerms": true])
                await userStore.loadUserData(uid: uid)
                userStore.completeOnboarding()
            } else {
                try await authManager.signIn(email: email, password: password)
                if let uid = authManager.currentUID {
                    await userStore.loadUserData(uid: uid)
                    userStore.completeOnboarding()
                }
            }
        } catch {
            showAuthError(authManager.friendlyError(error))
        }
    }

    private func resetPassword() async {
        guard !email.isEmpty else {
            showAuthError("Enter your email to reset your password."); return
        }
        do {
            try await authManager.resetPassword(email: email)
            showAuthError("Reset email sent! Check your inbox.")
        } catch {
            showAuthError(authManager.friendlyError(error))
        }
    }

    private func showAuthError(_ message: String) {
        errorMessage = message
        showError = true
    }
}

// MARK: - AuthTextField Component
struct AuthTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure = false

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AATheme.secondaryText)
                .frame(width: 20)

            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 16))
                    .foregroundColor(AATheme.primaryText)
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 16))
                    .foregroundColor(AATheme.primaryText)
                    .keyboardType(keyboardType)
            }
        }
        .padding(.horizontal, AATheme.paddingMedium)
        .padding(.vertical, 15)
        .background(AATheme.cardBackground)
        .cornerRadius(AATheme.cornerRadiusSmall)
        .overlay(
            RoundedRectangle(cornerRadius: AATheme.cornerRadiusSmall)
                .stroke(AATheme.secondaryText.opacity(0.2), lineWidth: 1)
        )
    }
}
