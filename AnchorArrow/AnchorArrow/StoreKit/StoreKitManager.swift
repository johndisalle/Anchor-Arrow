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
    static let groupID = "21994049"

    // Product IDs — must exactly match App Store Connect
    static let monthlyID   = "com.ellasid.anchorarrow.premium.monthly.v2"
    static let annualID    = "com.ellasid.anchorarrow.premium.annual.v2"
    static let lifetimeID  = "com.ellasid.anchorarrow.premium.lifetime"

    static let subscriptionIDs = [monthlyID, annualID]
    static let allProductIDs = [monthlyID, annualID, lifetimeID]
}

// MARK: - StoreKitManager
@MainActor
class StoreKitManager: ObservableObject {
    @Published var hasActiveSubscription = false
    @Published var activeSubscriptionExpiry: Date?
    @Published var productsLoaded: Bool = false
    @Published var productLoadError: String?

    private var transactionListener: Task<Void, Error>?
    private var authStateHandle: AuthStateDidChangeListenerHandle?

    init() {
        print("[StoreKit] init")
        transactionListener = listenForTransactions()
        Task { await checkSubscriptionStatus() }
        Task { await loadProducts() }
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            print("[StoreKit] auth state changed — user: \(user?.uid ?? "nil")")
            guard user != nil else { return }
            Task { [weak self] in
                await self?.checkSubscriptionStatus()
            }
        }
    }

    deinit {
        transactionListener?.cancel()
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // MARK: - Load Products
    func loadProducts() async {
        do {
            let products = try await Product.products(for: SubscriptionConfig.allProductIDs)
            if products.isEmpty {
                productLoadError = "No subscription products returned by App Store."
                productsLoaded = false
                print("[StoreKit] loadProducts: empty result")
            } else {
                productsLoaded = true
                productLoadError = nil
                print("[StoreKit] loadProducts: loaded \(products.count) products — \(products.map(\.id))")
            }
        } catch {
            productLoadError = "Failed to load products: \(error.localizedDescription)"
            productsLoaded = false
            print("[StoreKit] loadProducts error: \(error.localizedDescription)")
        }
    }

    // MARK: - Check Subscription Status
    func checkSubscriptionStatus() async {
        print("[StoreKit] checkSubscriptionStatus start")
        var foundActive = false

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if transaction.productID == SubscriptionConfig.lifetimeID {
                    // Lifetime purchase — never expires
                    foundActive = true
                    activeSubscriptionExpiry = nil
                    await updatePremiumStatus(expiryDate: nil, isLifetime: true)
                    break
                } else if SubscriptionConfig.subscriptionIDs.contains(transaction.productID) {
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
        print("[StoreKit] checkSubscriptionStatus end — active: \(hasActiveSubscription)")
    }

    // MARK: - Listen for Transactions
    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    print("[StoreKit] transaction received — productID: \(transaction.productID)")
                    await self.updatePremiumStatus(expiryDate: transaction.expirationDate)
                    await transaction.finish()
                } catch {
                    // Skip unverified transactions
                }
            }
        }
    }

    // MARK: - Update Firebase Premium Flag
    private func updatePremiumStatus(expiryDate: Date?, isLifetime: Bool = false) async {
        let isPremium = isLifetime || (expiryDate != nil && expiryDate! > Date())
        hasActiveSubscription = isPremium
        activeSubscriptionExpiry = expiryDate
        guard let uid = Auth.auth().currentUser?.uid else {
            print("[StoreKit] updatePremiumStatus: no uid, skipping Firestore write (local state updated)")
            return
        }
        do {
            try await FirestoreService.shared.setPremium(uid: uid, isPremium: isPremium, expiry: expiryDate)
            print("[StoreKit] premium write success — uid: \(uid), isPremium: \(isPremium)")
        } catch {
            print("[StoreKit] premium write failure: \(error.localizedDescription)")
        }
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
