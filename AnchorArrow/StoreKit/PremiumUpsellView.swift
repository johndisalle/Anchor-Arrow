// PremiumUpsellView.swift
// Gentle premium paywall / upsell modal

import SwiftUI
import StoreKit

struct PremiumUpsellView: View {
    let reason: String?
    @EnvironmentObject var storeKitManager: StoreKitManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedProduct: SubscriptionProduct = .annual

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {

                    // Header
                    VStack(spacing: 12) {
                        ZStack {
                            SwiftUI.Circle()
                                .fill(Color("BrandGold").opacity(0.15))
                                .frame(width: 80, height: 80)
                            Image(systemName: "crown.fill")
                                .font(.system(size: 36))
                                .foregroundColor(Color("BrandGold"))
                        }
                        .padding(.top, 8)

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
                    }

                    // Feature list
                    VStack(spacing: 12) {
                        PremiumFeatureRow(icon: "heart.fill", color: "BrandDanger", text: "Kingdom Funded — All profits donated to missions & service")
                        PremiumFeatureRow(icon: "person.3.fill", color: "BrandAnchor", text: "Unlimited Iron Sharpeners circles")
                        PremiumFeatureRow(icon: "book.fill", color: "BrandArrow", text: "Deeper teaching & theme packs")
                        PremiumFeatureRow(icon: "target", color: "BrandWarning", text: "Custom personal goals")
                        PremiumFeatureRow(icon: "rectangle.slash.fill", color: "TextSecondary", text: "Ad-free experience")
                        PremiumFeatureRow(icon: "mappin.and.ellipse", color: "BrandArrow", text: "Full 30-day Stand Firm Journey")
                    }
                    .padding(.horizontal, 24)

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
                    .padding(.horizontal, 24)

                    // Purchase button
                    VStack(spacing: 12) {
                        Button {
                            Task {
                                if let product = storeKitManager.product(for: selectedProduct) {
                                    await storeKitManager.purchase(product)
                                    if storeKitManager.hasActiveSubscription {
                                        dismiss()
                                    }
                                }
                            }
                        } label: {
                            ZStack {
                                if storeKitManager.isPurchasing {
                                    ProgressView().tint(.white)
                                } else {
                                    VStack(spacing: 2) {
                                        Text("Start Premium")
                                            .font(.system(size: 18, weight: .heavy))
                                        Text(priceSubtext)
                                            .font(.system(size: 12))
                                    }
                                    .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 58)
                            .background(
                                LinearGradient(
                                    colors: [Color("BrandGold"), Color("BrandArrow")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .padding(.horizontal, 24)
                        }
                        .disabled(storeKitManager.isPurchasing)

                        if let errorMessage = storeKitManager.purchaseError {
                            Text(errorMessage)
                                .font(.system(size: 13))
                                .foregroundColor(Color("BrandDanger"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }

                        Button("Restore Purchases") {
                            Task { await storeKitManager.restorePurchases() }
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color("TextSecondary"))

                        // Legal
                        Text("Subscriptions renew automatically. Cancel anytime in App Store settings. Terms & Privacy Policy apply.")
                            .font(.system(size: 10))
                            .foregroundColor(Color("TextSecondary").opacity(0.6))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }

                    Spacer(minLength: 20)
                }
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
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color("TextPrimary"))

                        if let savings = subscription.savingsNote {
                            Text(savings)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color("BrandArrow"))
                                .cornerRadius(8)
                        }
                    }

                    Text(product?.displayPrice ?? subscription.priceString)
                        .font(.system(size: 14))
                        .foregroundColor(Color("TextSecondary"))
                }

                Spacer()

                ZStack {
                    SwiftUI.Circle()
                        .stroke(isSelected ? Color("BrandGold") : Color("TextSecondary").opacity(0.3), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        SwiftUI.Circle()
                            .fill(Color("BrandGold"))
                            .frame(width: 14, height: 14)
                    }
                }
            }
            .padding(16)
            .background(
                isSelected
                ? Color("BrandGold").opacity(0.08)
                : Color("CardBackground")
            )
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color("BrandGold") : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}
