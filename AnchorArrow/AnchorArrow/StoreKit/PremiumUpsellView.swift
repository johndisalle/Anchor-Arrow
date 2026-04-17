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
        SubscriptionStoreView(productIDs: SubscriptionConfig.allProductIDs) {
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
                }

                // Feature list
                // Journey hero card
                VStack(spacing: 10) {
                    AAIcon("book.fill", size: 28, color: AATheme.amber)
                    Text("11 Guided Journeys")
                        .font(.system(size: 20, weight: .heavy, design: .serif))
                        .foregroundColor(AATheme.primaryText)
                    Text("330 daily devotionals across Spiritual Warfare, The Father's Heart, The Narrow Road, and more")
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
                    PremiumFeatureRow(icon: "person.3.fill", color: "BrandAnchor", text: "Post, comment & rally brothers in unlimited circles")
                    PremiumFeatureRow(icon: "magnifyingglass", color: "BrandGold", text: "Journal History — search & revisit past reflections")
                    PremiumFeatureRow(icon: "chart.bar.fill", color: "BrandArrow", text: "Drift Insights & Weekly Report — see your patterns")
                    PremiumFeatureRow(icon: "tag.fill", color: "BrandWarning", text: "Custom Drift Categories — track your specific struggles")
                    PremiumFeatureRow(icon: "circle.fill", color: "BrandGold", text: "Grace Day — save your streak once per month")
                }
                .padding(.horizontal, 24)
            }
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
