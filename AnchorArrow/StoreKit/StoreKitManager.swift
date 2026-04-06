// StoreKitManager.swift
// StoreKit 2 subscription management

import Foundation
import Combine
import StoreKit
import FirebaseAuth

// MARK: - Subscription Configuration
// ⚠️ IMPORTANT: Update this to match your App Store Connect subscription group ID.
// Find it in App Store Connect → Your App → Subscriptions → Subscription Group → Group ID
enum SubscriptionConfig {
    static let groupID = "anchor-arrow-premium"

    // Product IDs must exactly match what is configured in App Store Connect.
    // App Store Connect → Your App → Subscriptions → Product ID
    static let monthlyID = "com.yourcompany.anchorarrow.premium.monthly"
    static let annualID  = "com.yourcompany.anchorarrow.premium.annual"

    static let allProductIDs = [monthlyID, annualID]
}

// MARK: - StoreKitManager
@MainActor
class StoreKitManager: ObservableObject {
    @Published var hasActiveSubscription = false
    @Published var activeSubscriptionExpiry: Date?

    private var transactionListener: Task<Void, Error>?

    init() {
        transactionListener = listenForTransactions()
        Task { await checkSubscriptionStatus() }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Check Subscription Status
    func checkSubscriptionStatus() async {
        var foundActive = false

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if SubscriptionConfig.allProductIDs.contains(transaction.productID) {
                    if let expiry = transaction.expirationDate, expiry > Date() {
                        foundActive = true
                        activeSubscriptionExpiry = expiry
                        await updatePremiumStatus(expiryDate: expiry)
                        break
                    }
                }
            } catch {
                // Skip unverified transactions
            }
        }

        if !foundActive {
            hasActiveSubscription = false
            await updatePremiumStatus(expiryDate: nil)
        }
    }

    // MARK: - Listen for Transactions
    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    await self.updatePremiumStatus(expiryDate: transaction.expirationDate)
                    await transaction.finish()
                    await self.checkSubscriptionStatus()
                } catch {
                    // Skip unverified transactions
                }
            }
        }
    }

    // MARK: - Update Firebase Premium Flag
    private func updatePremiumStatus(expiryDate: Date?) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let isPremium = expiryDate != nil && expiryDate! > Date()
        try? await FirestoreService.shared.setPremium(uid: uid, isPremium: isPremium, expiry: expiryDate)
        hasActiveSubscription = isPremium
        activeSubscriptionExpiry = expiryDate
    }

    // MARK: - Verify Transaction
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

// MARK: - StoreError
enum StoreError: LocalizedError {
    case failedVerification

    var errorDescription: String? {
        "Transaction verification failed. Please contact support."
    }
}
