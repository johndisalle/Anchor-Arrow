// PremiumUpsellView.swift
// Gentle premium paywall / upsell modal

import SwiftUI
import StoreKit

struct PremiumUpsellView: View {
    let reason: String?
    @EnvironmentObject var storeKitManager: StoreKitManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedProduct: SubscriptionProduct = .annual
    @State private var showWelcome = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {

                    // Header
                    VStack(spacing: 12) {
                        ZStack {
                            SwiftUI.Circle()
                                .fill(AATheme.warmGold.opacity(0.15))
                                .frame(width: 80, height: 80)
                            Image(systemName: "crown.fill")
                                .font(.system(size: 36))
                                .foregroundColor(AATheme.warmGold)
                        }
                        .padding(.top, 8)

                        Text("Anchor & Arrow\nPremium")
                            .font(AATheme.titleFont)
                            .foregroundColor(AATheme.primaryText)
                            .multilineTextAlignment(.center)

                        if let reason {
                            Text("Unlock to: \(reason)")
                                .font(.system(size: 14))
                                .foregroundColor(AATheme.secondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                    }

                    // Feature list
                    VStack(spacing: 12) {
                        PremiumFeatureRow(icon: "heart.fill", color: AATheme.destructive, text: "Kingdom Funded — All profits donated to missions & service")
                        PremiumFeatureRow(icon: "person.3.fill", color: AATheme.steel, text: "Post, comment & rally brothers in unlimited circles")
                        PremiumFeatureRow(icon: "map.fill", color: AATheme.amber, text: "5 additional 30-day journeys (150 devotionals)")
                        PremiumFeatureRow(icon: "book.fill", color: AATheme.steel, text: "Journal History — search & revisit past reflections")
                        PremiumFeatureRow(icon: "chart.bar.fill", color: AATheme.warning, text: "Drift Insights & Weekly Report — see your patterns")
                        PremiumFeatureRow(icon: "tag.fill", color: AATheme.warning, text: "Custom Drift Categories — track your specific struggles")
                        PremiumFeatureRow(icon: "shield.fill", color: AATheme.amber, text: "Grace Day — save your streak once per month")
                    }
                    .padding(.horizontal, AATheme.paddingLarge)

                    // Product selection
                    VStack(spacing: 12) {
                        ForEach(SubscriptionProduct.allCases, id: \.self) { subscription in
                            let product = storeKitManager.product(for: subscription)

                            SubscriptionOptionCard(
                                subscription: subscription,
                                product: product,
                                isSelected: selectedProduct == subscription
                            ) {
                                selectedProduct = subscription
                            }
                        }
                    }
                    .padding(.horizontal, AATheme.paddingLarge)

                    // Purchase button
                    VStack(spacing: 12) {
                        Button {
                            Task {
                                if let product = storeKitManager.product(for: selectedProduct) {
                                    await storeKitManager.purchase(product)
                                    if storeKitManager.hasActiveSubscription {
                                        showWelcome = true
                                    }
                                }
                            }
                        } label: {
                            ZStack {
                                if storeKitManager.isPurchasing {
                                    ProgressView().tint(.white)
                                } else {
                                    VStack(spacing: 2) {
                                        Text("Subscribe Now")
                                            .font(.system(size: 18, weight: .heavy, design: .serif))
                                        Text(priceSubtext)
                                            .font(.system(size: 12))
                                    }
                                    .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 58)
                        }
                        .buttonStyle(AAPremiumButtonStyle())
                        .padding(.horizontal, AATheme.paddingLarge)
                        .disabled(storeKitManager.isPurchasing)

                        if let errorMessage = storeKitManager.purchaseError {
                            Text(errorMessage)
                                .font(.system(size: 13))
                                .foregroundColor(AATheme.destructive)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }

                        Button("Restore Purchases") {
                            Task {
                                await storeKitManager.restorePurchases()
                                if storeKitManager.hasActiveSubscription {
                                    showWelcome = true
                                }
                            }
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AATheme.secondaryText)

                        // Legal
                        VStack(spacing: 4) {
                            Text("Subscription renews automatically. Cancel anytime in App Store settings.")
                                .font(.system(size: 10))
                                .foregroundColor(AATheme.secondaryText.opacity(0.6))
                                .multilineTextAlignment(.center)

                            HStack(spacing: 4) {
                                Link("Terms of Use", destination: URL(string: "https://johndisalle.github.io/Anchor-Arrow/terms-of-use.html")!)
                                Text("&")
                                    .foregroundColor(AATheme.secondaryText.opacity(0.6))
                                Link("Privacy Policy", destination: URL(string: "https://johndisalle.github.io/Anchor-Arrow/privacy-policy.html")!)
                            }
                            .font(.system(size: 10, weight: .medium))
                        }
                        .padding(.horizontal, 32)
                    }

                    Spacer(minLength: 20)
                }
            }
            .aaScreenBackground()
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Maybe Later") { dismiss() }
                        .font(.system(size: 14))
                        .foregroundColor(AATheme.secondaryText)
                }
            }
            .fullScreenCover(isPresented: $showWelcome) {
                dismiss()
            } content: {
                PremiumWelcomeView()
            }
        }
    }

    private var priceSubtext: String {
        switch selectedProduct {
        case .monthly: return "$6.99/month • Cancel anytime"
        case .annual:  return "$59.99/year • That's ~$5/month"
        }
    }
}

// MARK: - PremiumFeatureRow
struct PremiumFeatureRow: View {
    let icon: String
    let color: Color
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 24)

            Text(text)
                .font(.system(size: 15))
                .foregroundColor(AATheme.primaryText)

            Spacer()

            Image(systemName: "checkmark")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(AATheme.success)
        }
    }
}

// MARK: - SubscriptionOptionCard
struct SubscriptionOptionCard: View {
    let subscription: SubscriptionProduct
    let product: Product?
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(subscription.displayName)
                            .font(.system(size: 16, weight: .bold, design: .serif))
                            .foregroundColor(AATheme.primaryText)

                        if let savings = subscription.savingsNote {
                            Text(savings)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(AATheme.amber)
                                .cornerRadius(AATheme.cornerRadiusSmall)
                        }
                    }

                    Text(product?.displayPrice ?? subscription.priceString)
                        .font(.system(size: 14))
                        .foregroundColor(AATheme.secondaryText)
                }

                Spacer()

                ZStack {
                    SwiftUI.Circle()
                        .stroke(isSelected ? AATheme.warmGold : AATheme.secondaryText.opacity(0.3), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        SwiftUI.Circle()
                            .fill(AATheme.warmGold)
                            .frame(width: 14, height: 14)
                    }
                }
            }
            .padding(AATheme.paddingMedium)
            .background(
                isSelected
                ? AATheme.warmGold.opacity(0.08)
                : AATheme.cardBackground
            )
            .cornerRadius(AATheme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AATheme.cornerRadius)
                    .stroke(isSelected ? AATheme.warmGold : Color.clear, lineWidth: 2)
            )
            .shadow(color: AATheme.cardShadow, radius: AATheme.cardShadowRadius, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}
