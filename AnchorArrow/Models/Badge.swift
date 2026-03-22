// Badge.swift
// Achievement badges earned through consistent use

import SwiftUI

// MARK: - Badge Definition
struct Badge: Identifiable, Codable {
    var id: String          // matches BadgeType.rawValue
    var earnedDate: Date?
    var isEarned: Bool { earnedDate != nil }
}

// MARK: - BadgeType
enum BadgeType: String, CaseIterable, Identifiable {
    // Streak badges
    case firstDay       = "first_day"
    case threeDays      = "three_days"
    case sevenDays      = "seven_days"
    case fourteenDays   = "fourteen_days"
    case thirtyDays     = "thirty_days"
    case sixtyDays      = "sixty_days"
    case oneHundred     = "one_hundred"

    // Completion badges
    case anchorWarrior  = "anchor_warrior"     // 7 anchor completions
    case arrowLoosed    = "arrow_loosed"       // 7 arrow completions
    case bothComplete   = "both_complete"      // first full day
    case ironMan        = "iron_man"           // 30 both-complete days

    // Drift badges (resilience)
    case firstAnchor    = "first_anchor"       // first drift log
    case standFirm      = "stand_firm"         // 5 drift logs anchored
    case unshakeable    = "unshakeable"        // 20 drift logs anchored

    // Journey badges
    case journeyStarted = "journey_started"
    case journeyWeek1   = "journey_week1"
    case journeyComplete = "journey_complete"

    // Role badges
    case truthTeller    = "truth_teller_badge"
    case prayerWarrior  = "prayer_warrior_badge"
    case servant        = "servant_badge"

    var id: String { rawValue }

    var name: String {
        switch self {
        case .firstDay:        return "First Step"
        case .threeDays:       return "Three Days Firm"
        case .sevenDays:       return "Watchful Guardian"
        case .fourteenDays:    return "Two Weeks Standing"
        case .thirtyDays:      return "Month of Strength"
        case .sixtyDays:       return "Two Months Rooted"
        case .oneHundred:      return "Hundred Days Strong"
        case .anchorWarrior:   return "Anchor Warrior"
        case .arrowLoosed:     return "Arrow Loosed"
        case .bothComplete:    return "Fully Engaged"
        case .ironMan:         return "Iron Sharpens Iron"
        case .firstAnchor:     return "Honest Before God"
        case .standFirm:       return "Stand Firm"
        case .unshakeable:     return "Unshakeable"
        case .journeyStarted:  return "Journey Begun"
        case .journeyWeek1:    return "Week One Victor"
        case .journeyComplete: return "Stand Firm Complete"
        case .truthTeller:     return "Truth in Love"
        case .prayerWarrior:   return "Prayer Warrior"
        case .servant:         return "Strong in Love"
        }
    }

    var description: String {
        switch self {
        case .firstDay:        return "Completed your first day"
        case .threeDays:       return "3-day streak — you're building something real"
        case .sevenDays:       return "7-day streak — Be watchful, stand firm"
        case .fourteenDays:    return "14-day streak — roots are growing deep"
        case .thirtyDays:      return "30-day streak — a month of faithful pursuit"
        case .sixtyDays:       return "60-day streak — two months of standing firm"
        case .oneHundred:      return "100 days — Act like men, be strong"
        case .anchorWarrior:   return "Completed the Morning Anchor 7 times"
        case .arrowLoosed:     return "Completed the Evening Arrow 7 times"
        case .bothComplete:    return "First full day of Anchor + Arrow"
        case .ironMan:         return "30 days of complete Anchor + Arrow"
        case .firstAnchor:     return "Logged your first drift moment — honesty is strength"
        case .standFirm:       return "Anchored through 5 drift moments"
        case .unshakeable:     return "Anchored through 20 drift moments"
        case .journeyStarted:  return "Started the Stand Firm Journey"
        case .journeyWeek1:    return "Completed Week 1 of the Journey"
        case .journeyComplete: return "Completed the full Stand Firm Journey"
        case .truthTeller:     return "Served as Truth-Teller 10 times"
        case .prayerWarrior:   return "Served as Prayer Warrior 10 times"
        case .servant:         return "Served as Servant Leader 10 times"
        }
    }

    var icon: String {
        switch self {
        case .firstDay:        return "star.fill"
        case .threeDays:       return "flame.fill"
        case .sevenDays:       return "shield.fill"
        case .fourteenDays:    return "leaf.fill"
        case .thirtyDays:      return "crown.fill"
        case .sixtyDays:       return "tree.fill"
        case .oneHundred:      return "trophy.fill"
        case .anchorWarrior:   return "anchor"
        case .arrowLoosed:     return "arrow.up.right.circle.fill"
        case .bothComplete:    return "checkmark.seal.fill"
        case .ironMan:         return "dumbbell.fill"
        case .firstAnchor:     return "eye.fill"
        case .standFirm:       return "figure.stand"
        case .unshakeable:     return "mountain.2.fill"
        case .journeyStarted:  return "map.fill"
        case .journeyWeek1:    return "flag.fill"
        case .journeyComplete: return "medal.fill"
        case .truthTeller:     return "text.bubble.fill"
        case .prayerWarrior:   return "hands.sparkles.fill"
        case .servant:         return "heart.fill"
        }
    }

    var color: Color {
        switch self {
        case .firstDay:        return .yellow
        case .threeDays:       return .orange
        case .sevenDays:       return .blue
        case .fourteenDays:    return .green
        case .thirtyDays:      return Color("BrandGold")
        case .sixtyDays:       return Color("BrandEarth")
        case .oneHundred:      return Color("BrandAnchor")
        case .anchorWarrior:   return Color("BrandAnchor")
        case .arrowLoosed:     return Color("BrandArrow")
        case .bothComplete:    return .mint
        case .ironMan:         return .indigo
        case .firstAnchor:     return .purple
        case .standFirm:       return .blue
        case .unshakeable:     return .cyan
        case .journeyStarted:  return Color("BrandArrow")
        case .journeyWeek1:    return .green
        case .journeyComplete: return Color("BrandGold")
        case .truthTeller:     return .teal
        case .prayerWarrior:   return .indigo
        case .servant:         return .red
        }
    }
}

// MARK: - Badge Evaluation
extension BadgeType {
    /// Check if this badge should be earned given current user stats
    func shouldEarn(user: AppUser, entry: DailyEntry? = nil, driftCount: Int = 0) -> Bool {
        switch self {
        case .firstDay:        return user.totalAnchorDays >= 1 || user.totalArrowDays >= 1
        case .threeDays:       return user.currentStreak >= 3
        case .sevenDays:       return user.currentStreak >= 7
        case .fourteenDays:    return user.currentStreak >= 14
        case .thirtyDays:      return user.currentStreak >= 30
        case .sixtyDays:       return user.currentStreak >= 60
        case .oneHundred:      return user.currentStreak >= 100
        case .anchorWarrior:   return user.totalAnchorDays >= 7
        case .arrowLoosed:     return user.totalArrowDays >= 7
        case .bothComplete:    return entry?.bothCompleted == true
        case .ironMan:         return user.totalAnchorDays >= 30 && user.totalArrowDays >= 30
        case .firstAnchor:     return driftCount >= 1
        case .standFirm:       return driftCount >= 5
        case .unshakeable:     return driftCount >= 20
        case .journeyStarted:  return user.journeyActive
        case .journeyWeek1:    return user.journeyDay >= 7
        case .journeyComplete: return user.journeyDay >= 30
        case .truthTeller, .prayerWarrior, .servant: return false // tracked separately
        }
    }
}
