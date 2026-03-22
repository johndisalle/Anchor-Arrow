// UserModel.swift
// Core user model — Firestore-serializable via Codable

import Foundation
import FirebaseFirestore

// MARK: - AppUser
struct AppUser: Codable, Identifiable {
    @DocumentID var id: String?
    var uid: String
    var email: String
    var displayName: String
    var isPremium: Bool = false
    var premiumExpiry: Date?
    var joinDate: Date
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var totalAnchorDays: Int = 0
    var totalArrowDays: Int = 0
    var badges: [String] = []
    var journeyActive: Bool = false
    var journeyDay: Int = 0
    var journeyStartDate: Date?
    var notificationsEnabled: Bool = true
    var morningReminderHour: Int = 7
    var eveningReminderHour: Int = 20
    var theme: AppTheme = .system
    var lastEntryDate: Date?

    // MARK: - Computed
    var isStreakActive: Bool {
        guard let last = lastEntryDate else { return false }
        return Calendar.current.isDateInYesterday(last) ||
               Calendar.current.isDateInToday(last)
    }

    var memberSince: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: joinDate)
    }
}

// MARK: - AppTheme
enum AppTheme: String, Codable, CaseIterable {
    case system, light, dark

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }

    var displayName: String {
        switch self {
        case .system: return "System Default"
        case .light:  return "Light"
        case .dark:   return "Dark"
        }
    }
}

// SwiftUI import for ColorScheme
import SwiftUI
extension AppTheme {
    var swiftUIColorScheme: SwiftUI.ColorScheme? { colorScheme }
}
