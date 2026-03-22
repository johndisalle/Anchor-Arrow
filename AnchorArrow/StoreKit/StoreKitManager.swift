// StoreKitManager.swift
// StoreKit 2 subscription management

import Foundation
import Combine
import StoreKit
import FirebaseAuth

// MARK: - Product IDs
enum SubscriptionProduct: String, CaseIterable {
    case monthly = "com.ellasid.AnchorArrow.premium.monthly"
    case annual  = "com.ellasid.AnchorArrow.premium.annual"

    var displayName: String {
        switch self {
        case .monthly: return "Monthly"
        case .annual:  return "Annual (Best Value)"
        }
    }

    var priceString: String {
        switch self {
        case .monthly: return "$6.99/month"
        case .annual:  return "$59.99/year"
        }
    }

    var savingsNote: String? {
        switch self {
        case .annual: return "Save 28% vs monthly"
        default: return nil
        }
    }
}

// MARK: - StoreKitManager
@MainActor
class StoreKitManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var isPurchasing = false
    @Published var purchaseError: String?
    @Published var hasActiveSubscription = false
    @Published var activeSubscriptionExpiry: Date?

    private var transactionListener: Task<Void, Error>?

    init() {
        transactionListener = listenForTransactions()
        Task { await loadProducts() }
        Task { await checkSubscriptionStatus() }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Load Products
    func loadProducts() async {
        do {
            let productIds = SubscriptionProduct.allCases.map(\.rawValue)
            products = try await Product.products(for: productIds)
            // Sort: annual first
            products.sort { $0.id.contains("annual") && !$1.id.contains("annual") }
        } catch {
            purchaseError = "Could not load subscription options."
        }
    }

    // MARK: - Purchase
    func purchase(_ product: Product) async {
        isPurchasing = true
        purchaseError = nil

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verificationResult):
                let transaction = try checkVerified(verificationResult)
                await updatePremiumStatus(expiryDate: transaction.expirationDate)
                await transaction.finish()
                hasActiveSubscription = true

            case .pending:
                // Transaction awaiting approval (e.g. Ask to Buy)
                break

            case .userCancelled:
                break

            @unknown default:
                break
            }
        } catch {
            purchaseError = "Purchase failed: \(error.localizedDescription)"
        }

        isPurchasing = false
    }

    // MARK: - Restore Purchases
    func restorePurchases() async {
        isPurchasing = true
        do {
            try await AppStore.sync()
            await checkSubscriptionStatus()
        } catch {
            purchaseError = "Restore failed. Please try again."
        }
        isPurchasing = false
    }

    // MARK: - Check Subscription Status
    func checkSubscriptionStatus() async {
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                let productId = transaction.productID

                if SubscriptionProduct.allCases.map(\.rawValue).contains(productId) {
                    if let expiry = transaction.expirationDate, expiry > Date() {
                        hasActiveSubscription = true
                        activeSubscriptionExpiry = expiry
                        await updatePremiumStatus(expiryDate: expiry)
                        return
                    }
                }
            } catch {}
        }

        // No active subscription found
        hasActiveSubscription = false
        await updatePremiumStatus(expiryDate: nil)
    }

    // MARK: - Listen for Transactions
    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    await self.updatePremiumStatus(expiryDate: transaction.expirationDate)
                    await transaction.finish()
                } catch {}
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

    // MARK: - Product helpers
    func product(for subscription: SubscriptionProduct) -> Product? {
        products.first { $0.id == subscription.rawValue }
    }

    func formattedPrice(for product: Product) -> String {
        product.displayPrice
    }
}

// MARK: - StoreError
enum StoreError: LocalizedError {
    case failedVerification

    var errorDescription: String? {
        "Transaction verification failed. Please contact support."
    }
}
