// NotificationManager.swift
// Push notification scheduling for morning anchor + evening arrow reminders

import Foundation
import Combine
import UserNotifications
import SwiftUI

// MARK: - NotificationManager
@MainActor
class NotificationManager: ObservableObject {
    @Published var permissionGranted = false

    private let notificationCenter = UNUserNotificationCenter.current()

    init() {
        Task { await checkPermission() }
    }

    // MARK: - Permission
    func requestPermission() async {
        do {
            permissionGranted = try await notificationCenter.requestAuthorization(
                options: [.alert, .sound, .badge]
            )
        } catch {
            permissionGranted = false
        }
    }

    func checkPermission() async {
        let settings = await notificationCenter.notificationSettings()
        permissionGranted = settings.authorizationStatus == .authorized
    }

    // MARK: - Schedule Reminders
    func scheduleReminders(morningHour: Int, eveningHour: Int) async {
        if !permissionGranted {
            await requestPermission()
            guard permissionGranted else { return }
        }

        cancelAll()

        await scheduleMorningAnchor(hour: morningHour)
        await scheduleEveningArrow(hour: eveningHour)
    }

    // MARK: - Morning Anchor (7AM default)
    private func scheduleMorningAnchor(hour: Int) async {
        let content = UNMutableNotificationContent()
        content.title = "Morning Anchor"

        let morningMessages = [
            "\"Be watchful, stand firm in the faith, act like men, be strong.\" — 1 Cor 16:13. Your Anchor is ready.",
            "\"The Lord is my rock, my fortress, and my deliverer.\" — Psalm 18:2. Anchor into Him this morning.",
            "\"Be strong and courageous. Do not be afraid; do not be discouraged.\" — Joshua 1:9. Start your day anchored.",
            "\"Put on the full armor of God, so that you can take your stand.\" — Ephesians 6:11. Time to anchor up.",
            "\"He who began a good work in you will carry it on to completion.\" — Philippians 1:6. Your morning reflection awaits.",
            "\"Watch and pray so that you will not fall into temptation.\" — Matthew 26:41. Anchor before the drift.",
            "\"I can do all things through Christ who strengthens me.\" — Philippians 4:13. Stand firm today, brother."
        ]
        content.body = morningMessages[Calendar.current.component(.weekday, from: Date()) % morningMessages.count]
        content.sound = .default
        content.badge = 1

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: NotificationID.morningAnchor,
            content: content,
            trigger: trigger
        )

        do {
            try await notificationCenter.add(request)
        } catch {
            #if DEBUG
            print("[Notifications] Failed to schedule morning anchor: \(error.localizedDescription)")
            #endif
        }
    }

    // MARK: - Evening Arrow (8PM default)
    private func scheduleEveningArrow(hour: Int) async {
        let content = UNMutableNotificationContent()
        content.title = "Evening Arrow"

        let eveningMessages = [
            "\"Let all that you do be done in love.\" — 1 Cor 16:14. What kingdom action did you take today?",
            "\"Faith without works is dead.\" — James 2:26. Log your Arrow — what did you do for God's kingdom?",
            "\"Well done, good and faithful servant.\" — Matthew 25:21. Reflect on today's purposeful action.",
            "\"Whatever you do, work at it with all your heart, as working for the Lord.\" — Colossians 3:23. Evening Arrow time.",
            "\"Be doers of the word, and not hearers only.\" — James 1:22. One action. Log it before you rest.",
            "\"The harvest is plentiful but the workers are few.\" — Matthew 9:37. How did you advance the kingdom today?",
            "\"Let your light shine before others.\" — Matthew 5:16. Evening reflection — how did your light shine?"
        ]
        content.body = eveningMessages[Calendar.current.component(.weekday, from: Date()) % eveningMessages.count]
        content.sound = .default
        content.badge = 1

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: NotificationID.eveningArrow,
            content: content,
            trigger: trigger
        )

        do {
            try await notificationCenter.add(request)
        } catch {
            #if DEBUG
            print("[Notifications] Failed to schedule evening arrow: \(error.localizedDescription)")
            #endif
        }
    }

    // MARK: - Streak Danger (missed yesterday)
    func scheduleStreakWarning(currentStreak: Int) async {
        guard permissionGranted, currentStreak >= 3 else { return }

        let content = UNMutableNotificationContent()
        content.title = "Don't break the streak"
        content.body = "You're at \(currentStreak) days. Log your Anchor today before midnight."
        content.sound = .default

        // Fire in 2 minutes (used when app detects near-midnight without completion)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 120, repeats: false)
        let request = UNNotificationRequest(
            identifier: NotificationID.streakWarning,
            content: content,
            trigger: trigger
        )

        do {
            try await notificationCenter.add(request)
        } catch {
            #if DEBUG
            print("[Notifications] Failed to schedule streak warning: \(error.localizedDescription)")
            #endif
        }
    }

    // MARK: - Grace Day Used
    func sendGraceDayNotification(streakSaved: Int) async {
        guard permissionGranted else { return }

        let content = UNMutableNotificationContent()
        content.title = "Grace Day Used"
        content.body = "Your grace day saved your \(streakSaved)-day streak. You have none left for 30 days. Stay anchored."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: NotificationID.graceDayUsed,
            content: content,
            trigger: trigger
        )
        do {
            try await notificationCenter.add(request)
        } catch {
            #if DEBUG
            print("[Notifications] Failed to schedule grace day notification: \(error.localizedDescription)")
            #endif
        }
    }

    // MARK: - Weekly Summary (Sunday 7PM)
    func scheduleWeeklySummary(anchors: Int, arrows: Int, drifts: Int, topDrift: String?) async {
        guard permissionGranted else { return }

        let content = UNMutableNotificationContent()
        content.title = "Your Weekly Report"

        var body = "This week: \(anchors)/7 Anchors, \(arrows)/7 Arrows"
        if drifts > 0 {
            body += ", \(drifts) drift\(drifts == 1 ? "" : "s") logged"
        }
        if let drift = topDrift {
            body += ". Top struggle: \(drift)"
        }
        body += ". Keep fighting, brother."

        content.body = body
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.weekday = 1  // Sunday
        dateComponents.hour = 19    // 7 PM
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: NotificationID.weeklySummary,
            content: content,
            trigger: trigger
        )

        do {
            try await notificationCenter.add(request)
        } catch {
            #if DEBUG
            print("[Notifications] Failed to schedule weekly summary: \(error.localizedDescription)")
            #endif
        }
    }

    // MARK: - Cancel
    func cancelAll() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
        Task {
            do {
                try await notificationCenter.setBadgeCount(0)
            } catch {
                #if DEBUG
                print("[Notifications] Failed to reset badge count: \(error.localizedDescription)")
                #endif
            }
        }
    }

    func cancelStreakWarning() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [NotificationID.streakWarning])
    }
}

// MARK: - Notification IDs
enum NotificationID {
    static let morningAnchor = "com.anchorarrow.notification.morning"
    static let eveningArrow  = "com.anchorarrow.notification.evening"
    static let streakWarning = "com.anchorarrow.notification.streak_warning"
    static let graceDayUsed  = "com.anchorarrow.notification.grace_day_used"
    static let weeklySummary = "com.anchorarrow.notification.weekly_summary"
}
