// PremiumUpsellView.swift
// Premium paywall using Apple's SubscriptionStoreView

import SwiftUI
import StoreKit

struct PremiumUpsellView: View {
    let reason: String?
    init(reason: String? = nil) {
        self.reason = reason
        AnalyticsService.log(.premiumUpsellViewed)
    }
    @EnvironmentObject var storeKitManager: StoreKitManager
    @EnvironmentObject var userStore: UserStore
    @Environment(\.dismiss) var dismiss
    @State private var purchaseError: String?
    @State private var showPendingAlert: Bool = false

    var body: some View {
        SubscriptionStoreView(productIDs: SubscriptionConfig.subscriptionIDs) {
            // Custom marketing header
            VStack(spacing: 20) {
                // Icon
                ZStack {
                    SwiftUI.Circle()
                        .fill(Color("BrandGold").opacity(0.15))
                        .frame(width: 80, height: 80)
                    AAIcon("crown.fill", size: 36, weight: .regular, color: Color("BrandGold"))
                }
                .padding(.top, 8)

                // Title
                Text("Anchor & Arrow\nPremium")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(Color("TextPrimary"))
                    .multilineTextAlignment(.center)

                if let reason {
                    Text("Unlock to: \(reason)")
                        .font(.system(size: 14))
                        .foregroundColor(Color("TextSecondary"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                } else {
                    Text("Listen, don't just read.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color("TextSecondary"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                // Feature list
                // Audio hero card — the lead differentiator
                VStack(spacing: 10) {
                    AAIcon("waveform", size: 28, color: AATheme.amber)
                    Text("Voice-Guided Sessions")
                        .font(.system(size: 20, weight: .heavy, design: .serif))
                        .foregroundColor(AATheme.primaryText)
                    Text("Listen to every scripture, reflection, and prayer. In the car. On a walk. Any time your eyes are busy.")
                        .font(.system(size: 14))
                        .foregroundColor(AATheme.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
                .padding(AATheme.paddingMedium)
                .frame(maxWidth: .infinity)
                .background(AATheme.amber.opacity(0.08))
                .cornerRadius(AATheme.cornerRadius)
                .padding(.horizontal, 24)

                VStack(spacing: 12) {
                    PremiumFeatureRow(icon: "heart.fill", color: "BrandDanger", text: "Kingdom Funded — All profits donated to missions & service")
                    PremiumFeatureRow(icon: "book.fill", color: "BrandGold", text: "11 Guided Journeys — 330 devotionals on warfare, fatherhood, the narrow road & more")
                    PremiumFeatureRow(icon: "person.3.fill", color: "BrandAnchor", text: "Post, comment & rally brothers in unlimited circles")
                    PremiumFeatureRow(icon: "magnifyingglass", color: "BrandGold", text: "Journal History — search & revisit past reflections")
                    PremiumFeatureRow(icon: "chart.bar.fill", color: "BrandArrow", text: "Drift Insights & Weekly Report — see your patterns")
                    PremiumFeatureRow(icon: "circle.fill", color: "BrandGold", text: "Grace Day — save your streak once per month")
                }
                .padding(.horizontal, 24)

            }
            .padding(.bottom, 200)  // room for Lifetime overlay + Apple's SubscriptionStoreView buttons
        }
        .overlay(alignment: .bottom) {
            LifetimePurchaseButton()
                .padding(.horizontal, 24)
                .padding(.bottom, 140)  // sit well above Apple's subscription buttons
        }
        .subscriptionStoreButtonLabel(.multiline)
        .storeButton(.visible, for: .restorePurchases)
        .subscriptionStorePolicyDestination(url: URL(string: "https://johndisalle.github.io/Anchor-Arrow/terms-of-use.html")!, for: .termsOfService)
        .subscriptionStorePolicyDestination(url: URL(string: "https://johndisalle.github.io/Anchor-Arrow/privacy-policy.html")!, for: .privacyPolicy)
        .onInAppPurchaseCompletion { _, result in
            switch result {
            case .success(.success(_)):
                Task {
                    await storeKitManager.checkSubscriptionStatus()
                    userStore.appUser?.isPremium = true
                    AnalyticsService.log(.premiumSubscribed)
                    userStore.showPremiumWelcome = true
                    dismiss()
                }
            case .success(.userCancelled):
                break
            case .success(.pending):
                showPendingAlert = true
            case .success(_):
                break
            case .failure(let error):
                purchaseError = error.localizedDescription
            }
        }
        .alert("Purchase Failed", isPresented: Binding(
            get: { purchaseError != nil },
            set: { if !$0 { purchaseError = nil } }
        )) {
            Button("OK", role: .cancel) { purchaseError = nil }
        } message: {
            Text(purchaseError ?? "")
        }
        .alert("Purchase Pending", isPresented: $showPendingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your purchase is awaiting approval. You'll be notified when it's complete.")
        }
        .background(Color("BackgroundPrimary").ignoresSafeArea())
    }
}

// MARK: - PremiumFeatureRow
struct PremiumFeatureRow: View {
    let icon: String
    let color: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            AAIcon(icon, size: 16, color: Color(color))
                .frame(width: 24)

            Text(text)
                .font(.system(size: 15))
                .foregroundColor(Color("TextPrimary"))

            Spacer()

            AAIcon("checkmark", size: 13, weight: .bold, color: .green)
        }
    }
}


// MARK: - Lifetime Purchase Button
struct LifetimePurchaseButton: View {
    @EnvironmentObject var storeKitManager: StoreKitManager
    @EnvironmentObject var userStore: UserStore
    @State private var lifetimeProduct: Product?
    @State private var isPurchasing = false
    @State private var errorMessage: String?

    var body: some View {
        Button {
            if let product = lifetimeProduct {
                Task { await purchaseLifetime(product) }
            }
        } label: {
            VStack(spacing: 4) {
                if let product = lifetimeProduct {
                    Text("Lifetime Access — \(product.displayPrice)")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(AATheme.warmGold)
                    Text("One payment. Forever.")
                        .font(.system(size: 12))
                        .foregroundColor(AATheme.secondaryText)
                } else {
                    Text("Lifetime Access")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(AATheme.warmGold)
                    Text("Loading price...")
                        .font(.system(size: 12))
                        .foregroundColor(AATheme.secondaryText)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AATheme.warmGold.opacity(0.1))
            .cornerRadius(AATheme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AATheme.cornerRadius)
                    .stroke(AATheme.warmGold.opacity(0.3), lineWidth: 1)
            )
        }
        .disabled(isPurchasing || lifetimeProduct == nil)
        .task {
            if let products = try? await Product.products(for: [SubscriptionConfig.lifetimeID]) {
                lifetimeProduct = products.first
            }
        }
    }

    private func purchaseLifetime(_ product: Product) async {
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    await storeKitManager.checkSubscriptionStatus()
                    userStore.appUser?.isPremium = true
                    AnalyticsService.log(.premiumSubscribed, params: ["type": "lifetime"])
                    userStore.showPremiumWelcome = true
                case .unverified:
                    errorMessage = "Purchase could not be verified."
                }
            case .userCancelled:
                break
            case .pending:
                break
            @unknown default:
                break
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
