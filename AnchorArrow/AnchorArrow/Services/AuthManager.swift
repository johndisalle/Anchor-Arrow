// AuthManager.swift
// Firebase Authentication — email/password + Apple Sign-In

import SwiftUI
import Combine
import Firebase
import FirebaseAuth
import AuthenticationServices
import CryptoKit

// MARK: - AuthManager
@MainActor
class AuthManager: NSObject, ObservableObject {

    @Published var isAuthenticated = false
    @Published var currentUID: String?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Used for Apple Sign-In nonce
    private var currentNonce: String?
    private var authStateHandler: AuthStateDidChangeListenerHandle?

    override init() {
        super.init()
        setupAuthListener()
    }

    deinit {
        if let handler = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
    }

    // MARK: - Auth State Listener
    private func setupAuthListener() {
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.isAuthenticated = user != nil
                self.currentUID = user?.uid
            }
        }
    }

    // MARK: - Email/Password Sign Up
    func signUp(email: String, password: String, displayName: String) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let result = try await Auth.auth().createUser(withEmail: email, password: password)

        // Update display name
        let changeRequest = result.user.createProfileChangeRequest()
        changeRequest.displayName = displayName
        try await changeRequest.commitChanges()
    }

    // MARK: - Email/Password Sign In
    func signIn(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        try await Auth.auth().signIn(withEmail: email, password: password)
    }

    // MARK: - Apple Sign-In
    func handleAppleSignIn(result: Result<ASAuthorization, Error>) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        switch result {
        case .success(let authorization):
            guard
                let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                let nonce = currentNonce,
                let appleIDToken = appleIDCredential.identityToken,
                let idTokenString = String(data: appleIDToken, encoding: .utf8)
            else {
                throw AuthError.appleSignInFailed
            }

            let credential = OAuthProvider.appleCredential(
                withIDToken: idTokenString,
                rawNonce: nonce,
                fullName: appleIDCredential.fullName
            )

            let authResult = try await Auth.auth().signIn(with: credential)

            // Set display name from Apple if available
            if let fullName = appleIDCredential.fullName,
               let givenName = fullName.givenName {
                let changeRequest = authResult.user.createProfileChangeRequest()
                changeRequest.displayName = givenName
                try await changeRequest.commitChanges()
            }

        case .failure(let error):
            throw error
        }
    }

    // MARK: - Nonce for Apple Sign-In
    func prepareAppleSignIn() throws -> String {
        let nonce = try randomNonceString()
        currentNonce = nonce
        return sha256(nonce)
    }

    // MARK: - Sign Out
    func signOut() throws {
        try Auth.auth().signOut()
    }

    // MARK: - Password Reset
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

    // MARK: - Delete Account
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else { throw AuthError.notSignedIn }
        // Delete all Firestore data first (entries, drift logs, circle memberships, user doc)
        // so no orphaned data remains if the Auth deletion succeeds.
        try await FirestoreService.shared.deleteUserData(uid: user.uid)
        try await user.delete()
    }

    /// Re-authenticate with password then delete (required when session is stale)
    func reauthenticateAndDelete(password: String) async throws {
        guard let user = Auth.auth().currentUser,
              let email = user.email else { throw AuthError.notSignedIn }
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        try await user.reauthenticate(with: credential)
        try await FirestoreService.shared.deleteUserData(uid: user.uid)
        try await user.delete()
    }

    // MARK: - Helpers
    var currentUser: User? { Auth.auth().currentUser }
    var userDisplayName: String { Auth.auth().currentUser?.displayName ?? "Warrior" }
    var userEmail: String { Auth.auth().currentUser?.email ?? "" }

    // MARK: - Error handling
    func friendlyError(_ error: Error) -> String {
        let nsError = error as NSError
        switch nsError.code {
        case AuthErrorCode.wrongPassword.rawValue:
            return "Incorrect password. Try again."
        case AuthErrorCode.invalidEmail.rawValue:
            return "That email address isn't valid."
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return "An account with this email already exists."
        case AuthErrorCode.weakPassword.rawValue:
            return "Password must be at least 6 characters."
        case AuthErrorCode.userNotFound.rawValue:
            return "No account found with that email."
        case AuthErrorCode.networkError.rawValue:
            return "Network error. Check your connection."
        default:
            return error.localizedDescription
        }
    }

    // MARK: - Cryptographic helpers for Apple Sign-In
    private func randomNonceString(length: Int = 32) throws -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            throw AuthError.nonceGenerationFailed
        }
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        return String(nonce)
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - AuthError
enum AuthError: LocalizedError {
    case appleSignInFailed
    case notSignedIn
    case nonceGenerationFailed
    case unknown

    var errorDescription: String? {
        switch self {
        case .appleSignInFailed:      return "Apple Sign-In failed. Please try again."
        case .notSignedIn:            return "You must be signed in to do that."
        case .nonceGenerationFailed:  return "Unable to generate a secure token. Please try again."
        case .unknown:                return "An unexpected error occurred."
        }
    }
}
