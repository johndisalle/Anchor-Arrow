// ReviewManager.swift
// Prompts App Store review at meaningful milestones

import StoreKit
import UIKit

enum ReviewManager {

    private static let lastReviewedVersionKey = "lastReviewedAppVersion"
    private static let lastReviewDateKey = "lastReviewRequestDate"

    /// Request a review if the user hasn't been prompted for this app version
    /// and at least 60 days have passed since the last request.
    static func requestReviewIfAppropriate() {
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let defaults = UserDefaults.standard

        // Don't prompt twice for the same version
        if defaults.string(forKey: lastReviewedVersionKey) == currentVersion {
            return
        }

        // Don't prompt more than once every 60 days
        if let lastDate = defaults.object(forKey: lastReviewDateKey) as? Date,
           Date().timeIntervalSince(lastDate) < 60 * 24 * 3600 {
            return
        }

        // Present the review prompt
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) else { return }

        // Small delay so it doesn't interrupt the current action
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            SKStoreReviewController.requestReview(in: windowScene)
            defaults.set(currentVersion, forKey: lastReviewedVersionKey)
            defaults.set(Date(), forKey: lastReviewDateKey)
        }
    }
}
