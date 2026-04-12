// PremiumUpsellView.swift
// Premium paywall using Apple's SubscriptionStoreView

import SwiftUI
import StoreKit

struct PremiumUpsellView: View {
    let reason: String?
    @EnvironmentObject var storeKitManager: StoreKitManager
    @EnvironmentObject var userStore: UserStore
    @Environment(\.dismiss) var dismiss
    @State private var purchaseError: String?
    @State private var showPendingAlert: Bool = false

    var body: some View {
        NavigationStack {
            SubscriptionStoreView(groupID: SubscriptionConfig.groupID) {
                // Custom marketing header
                VStack(spacing: 20) {
                    // Icon
                    ZStack {
                        SwiftUI.Circle()
                            .fill(Color("BrandGold").opacity(0.15))
                            .frame(width: 80, height: 80)
                        Image(systemName: "crown.fill")
                            .font(.system(size: 36))
                            .foregroundColor(Color("BrandGold"))
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
                    VStack(spacing: 12) {
                        PremiumFeatureRow(icon: "heart.fill", color: "BrandDanger", text: "Kingdom Funded — All profits donated to missions & service")
                        PremiumFeatureRow(icon: "person.3.fill", color: "BrandAnchor", text: "Post, comment & rally brothers in unlimited circles")
                        PremiumFeatureRow(icon: "book.fill", color: "BrandArrow", text: "5 additional 30-day journeys (150 devotionals)")
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
                        // Immediately mark premium in local state so views update
                        userStore.appUser?.isPremium = true
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
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Maybe Later") { dismiss() }
                        .font(.system(size: 14))
                        .foregroundColor(Color("TextSecondary"))
                }
            }
        }
    }
}

// MARK: - PremiumFeatureRow
struct PremiumFeatureRow: View {
    let icon: String
    let color: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(color))
                .frame(width: 24)

            Text(text)
                .font(.system(size: 15))
                .foregroundColor(Color("TextPrimary"))

            Spacer()

            Image(systemName: "checkmark")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.green)
        }
    }
}
