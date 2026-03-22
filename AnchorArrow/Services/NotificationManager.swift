// NotificationManager.swift
// Push notification scheduling for morning anchor + evening arrow reminders

import Foundation
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
        guard permissionGranted else {
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
            "Time to anchor up. What's pulling at you today?",
            "Stand firm. Your Morning Anchor is ready.",
            "Be watchful. The day begins — anchor first.",
            "\"Stand firm in the faith\" — your morning reflection is waiting.",
            "Before the chaos — anchor yourself in Christ."
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

        try? await notificationCenter.add(request)
    }

    // MARK: - Evening Arrow (8PM default)
    private func scheduleEveningArrow(hour: Int) async {
        let content = UNMutableNotificationContent()
        content.title = "Evening Arrow"

        let eveningMessages = [
            "Day's not done. What kingdom action did you take today?",
            "Log your Arrow. Did you serve, speak truth, or pray today?",
            "Evening reflection: How did you act like a man in love today?",
            "One action for God's kingdom — log it before you sleep.",
            "Arrow time. Reflect and close the day with purpose."
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

        try? await notificationCenter.add(request)
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

        try? await notificationCenter.add(request)
    }

    // MARK: - Cancel
    func cancelAll() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
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
}
