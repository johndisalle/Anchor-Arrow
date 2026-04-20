// AnalyticsService.swift
// Lightweight analytics wrapper — logs events to Firebase Analytics
// If FirebaseAnalytics is not in the project, events are logged to console.

import Foundation
import FirebaseAnalytics

// MARK: - Analytics Events
enum AnalyticsEvent: String {
    // Onboarding
    case onboardingStarted = "onboarding_started"
    case onboardingCompleted = "onboarding_completed"
    case signUp = "sign_up"
    case signIn = "sign_in"

    // Daily Habits
    case anchorCompleted = "anchor_completed"
    case arrowCompleted = "arrow_completed"
    case bothCompleted = "both_completed"
    case driftLogged = "drift_logged"

    // Streaks
    case streakMilestone = "streak_milestone"
    case graceDayUsed = "grace_day_used"

    // Journeys
    case journeyStarted = "journey_started"
    case journeyDayCompleted = "journey_day_completed"
    case journeyCompleted = "journey_completed"

    // Circles
    case circleCreated = "circle_created"
    case circleJoined = "circle_joined"
    case circlePostCreated = "circle_post_created"

    // Premium
    case premiumUpsellViewed = "premium_upsell_viewed"
    case premiumSubscribed = "premium_subscribed"

    // Engagement
    case appOpened = "app_opened"
    case verseShared = "verse_shared"
    case notificationEnabled = "notification_enabled"

    // Audio
    case audioStarted = "audio_started"
    case audioCompleted = "audio_completed"
    case audioQueueCompleted = "audio_queue_completed"
}

// MARK: - Analytics Service
struct AnalyticsService {
    static func log(_ event: AnalyticsEvent, params: [String: Any]? = nil) {
        Analytics.logEvent(event.rawValue, parameters: params)
        #if DEBUG
        print("[Analytics] \(event.rawValue) \(params ?? [:])")
        #endif
    }

    static func setUserProperty(_ value: String?, forName name: String) {
        Analytics.setUserProperty(value, forName: name)
    }

    static func setUserId(_ uid: String) {
        Analytics.setUserID(uid)
    }
}
