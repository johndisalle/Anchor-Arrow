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

    // Grace day: one free miss per 30-day period
    var graceDayUsedDate: Date?         // when the grace day was burned
    var graceDayPeriodStart: Date?      // start of the current 30-day grace period

    // Multiple journeys
    var journeySeries: String = JourneySeries.standFirm.rawValue
    var completedJourneys: [String] = []  // series rawValues the user finished

    // Custom drift categories (premium)
    var customDriftCategories: [String] = []

    // Blocked users
    var blockedUserIds: [String] = []

    // Terms acceptance (required before accessing UGC/circles)
    var acceptedTerms: Bool = false

    // Moderation
    var isAdmin: Bool = false

    // MARK: - Custom Decoder (handles missing keys for fields added after initial release)
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        _id                  = try c.decode(DocumentID<String>.self, forKey: .id)
        uid                  = try c.decode(String.self, forKey: .uid)
        email                = try c.decode(String.self, forKey: .email)
        displayName          = try c.decode(String.self, forKey: .displayName)
        isPremium            = try c.decodeIfPresent(Bool.self, forKey: .isPremium) ?? false
        premiumExpiry        = try c.decodeIfPresent(Date.self, forKey: .premiumExpiry)
        joinDate             = try c.decode(Date.self, forKey: .joinDate)
        currentStreak        = try c.decodeIfPresent(Int.self, forKey: .currentStreak) ?? 0
        longestStreak        = try c.decodeIfPresent(Int.self, forKey: .longestStreak) ?? 0
        totalAnchorDays      = try c.decodeIfPresent(Int.self, forKey: .totalAnchorDays) ?? 0
        totalArrowDays       = try c.decodeIfPresent(Int.self, forKey: .totalArrowDays) ?? 0
        badges               = try c.decodeIfPresent([String].self, forKey: .badges) ?? []
        journeyActive        = try c.decodeIfPresent(Bool.self, forKey: .journeyActive) ?? false
        journeyDay           = try c.decodeIfPresent(Int.self, forKey: .journeyDay) ?? 0
        journeyStartDate     = try c.decodeIfPresent(Date.self, forKey: .journeyStartDate)
        notificationsEnabled = try c.decodeIfPresent(Bool.self, forKey: .notificationsEnabled) ?? true
        morningReminderHour  = try c.decodeIfPresent(Int.self, forKey: .morningReminderHour) ?? 7
        eveningReminderHour  = try c.decodeIfPresent(Int.self, forKey: .eveningReminderHour) ?? 20
        theme                = try c.decodeIfPresent(AppTheme.self, forKey: .theme) ?? .system
        lastEntryDate        = try c.decodeIfPresent(Date.self, forKey: .lastEntryDate)
        graceDayUsedDate     = try c.decodeIfPresent(Date.self, forKey: .graceDayUsedDate)
        graceDayPeriodStart  = try c.decodeIfPresent(Date.self, forKey: .graceDayPeriodStart)
        journeySeries        = try c.decodeIfPresent(String.self, forKey: .journeySeries) ?? JourneySeries.standFirm.rawValue
        completedJourneys    = try c.decodeIfPresent([String].self, forKey: .completedJourneys) ?? []
        customDriftCategories = try c.decodeIfPresent([String].self, forKey: .customDriftCategories) ?? []
        blockedUserIds       = try c.decodeIfPresent([String].self, forKey: .blockedUserIds) ?? []
        acceptedTerms        = try c.decodeIfPresent(Bool.self, forKey: .acceptedTerms) ?? false
        isAdmin              = try c.decodeIfPresent(Bool.self, forKey: .isAdmin) ?? false
    }

    // Memberwise init for programmatic construction
    init(uid: String, email: String, displayName: String,
         isPremium: Bool = false, premiumExpiry: Date? = nil,
         joinDate: Date, currentStreak: Int = 0, longestStreak: Int = 0,
         totalAnchorDays: Int = 0, totalArrowDays: Int = 0,
         badges: [String] = [], journeyActive: Bool = false, journeyDay: Int = 0,
         journeyStartDate: Date? = nil, notificationsEnabled: Bool = true,
         morningReminderHour: Int = 7, eveningReminderHour: Int = 20,
         theme: AppTheme = .system, lastEntryDate: Date? = nil,
         graceDayUsedDate: Date? = nil, graceDayPeriodStart: Date? = nil,
         journeySeries: String = JourneySeries.standFirm.rawValue,
         completedJourneys: [String] = [],
         customDriftCategories: [String] = [],
         blockedUserIds: [String] = [],
         acceptedTerms: Bool = false,
         isAdmin: Bool = false) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
        self.isPremium = isPremium
        self.premiumExpiry = premiumExpiry
        self.joinDate = joinDate
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.totalAnchorDays = totalAnchorDays
        self.totalArrowDays = totalArrowDays
        self.badges = badges
        self.journeyActive = journeyActive
        self.journeyDay = journeyDay
        self.journeyStartDate = journeyStartDate
        self.notificationsEnabled = notificationsEnabled
        self.morningReminderHour = morningReminderHour
        self.eveningReminderHour = eveningReminderHour
        self.theme = theme
        self.lastEntryDate = lastEntryDate
        self.graceDayUsedDate = graceDayUsedDate
        self.graceDayPeriodStart = graceDayPeriodStart
        self.journeySeries = journeySeries
        self.completedJourneys = completedJourneys
        self.customDriftCategories = customDriftCategories
        self.blockedUserIds = blockedUserIds
        self.acceptedTerms = acceptedTerms
        self.isAdmin = isAdmin
    }

    // MARK: - Computed

    /// Whether a grace day is still available in the current 30-day period
    var hasGraceDayAvailable: Bool {
        guard isPremium else { return false }
        guard let periodStart = graceDayPeriodStart else { return true } // never used
        let daysSincePeriod = Calendar.current.dateComponents([.day], from: periodStart, to: Date()).day ?? 0
        if daysSincePeriod >= 30 { return true } // period expired, new one available
        return graceDayUsedDate == nil
    }

    /// Whether the grace day was already used in the current period
    var graceDayWasUsed: Bool {
        guard let periodStart = graceDayPeriodStart,
              let usedDate = graceDayUsedDate else { return false }
        let daysSincePeriod = Calendar.current.dateComponents([.day], from: periodStart, to: Date()).day ?? 0
        if daysSincePeriod >= 30 { return false } // period reset
        return usedDate >= periodStart
    }

    var isStreakActive: Bool {
        guard let last = lastEntryDate else { return false }
        return Calendar.current.isDateInYesterday(last) ||
               Calendar.current.isDateInToday(last)
    }

    private static let _memberSinceFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f
    }()

    var memberSince: String {
        Self._memberSinceFormatter.string(from: joinDate)
    }
}

// MARK: - JourneySeries
enum JourneySeries: String, Codable, CaseIterable, Identifiable {
    case standFirm = "stand_firm"
    case armorOfGod = "armor_of_god"
    case surrenderFirst = "surrender_first"
    case prophetPriestKing = "prophet_priest_king"
    case strengthInLove = "strength_in_love"
    case guardTheGates = "guard_the_gates"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .standFirm:         return "Stand Firm"
        case .armorOfGod:        return "Armor of God"
        case .surrenderFirst:    return "Surrender First"
        case .prophetPriestKing: return "Prophet, Priest, King"
        case .strengthInLove:    return "Strength in Love"
        case .guardTheGates:     return "Guard the Gates"
        }
    }

    var subtitle: String {
        switch self {
        case .standFirm:         return "30 Days in 1 Corinthians 16:13"
        case .armorOfGod:        return "30 Days in Ephesians 6"
        case .surrenderFirst:    return "30 Days in Galatians 2:20"
        case .prophetPriestKing: return "30 Days in the Offices of Christ"
        case .strengthInLove:    return "30 Days in 1 Corinthians 16:13-14"
        case .guardTheGates:     return "30 Days in Nehemiah & 1 Peter 5"
        }
    }

    var icon: String {
        switch self {
        case .standFirm:         return "figure.stand.line.dotted.figure.stand"
        case .armorOfGod:        return "shield.lefthalf.filled"
        case .surrenderFirst:    return "arrow.down.to.line"
        case .prophetPriestKing: return "person.3.fill"
        case .strengthInLove:    return "heart.circle.fill"
        case .guardTheGates:     return "eye.fill"
        }
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
