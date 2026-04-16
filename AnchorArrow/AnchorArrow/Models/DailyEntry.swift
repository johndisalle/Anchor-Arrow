// DailyEntry.swift
// Represents one day's anchor + arrow reflections

import Foundation
import FirebaseFirestore

// MARK: - DailyEntry
struct DailyEntry: Codable, Identifiable {
    @DocumentID var id: String?            // Firestore doc ID = dateString "2024-01-15"
    var date: Date
    var dateString: String                 // "YYYY-MM-DD" for Firestore document ID

    // Anchor (Morning)
    var anchorCompleted: Bool = false
    var anchorPromptId: String = ""
    var anchorReflection: String = ""
    var anchorTags: [AnchorTag] = []
    var anchorCompletedAt: Date?

    // Arrow (Evening)
    var arrowCompleted: Bool = false
    var arrowPromptId: String = ""
    var arrowReflection: String = ""
    var arrowRole: ArrowRole = .servantLeader
    var arrowCompletedAt: Date?

    // MARK: - Static factory
    static func todayEmpty() -> DailyEntry {
        let today = Date()
        return DailyEntry(
            date: today,
            dateString: today.entryDateString
        )
    }

    var bothCompleted: Bool { anchorCompleted && arrowCompleted }
}

// MARK: - AnchorTag (drift/distraction categories)
enum AnchorTag: String, Codable, CaseIterable, Identifiable {
    case temptation   = "temptation"
    case pride        = "pride"
    case selfReliance = "self_reliance"
    case lust         = "lust"
    case anger        = "anger"
    case avoidance    = "avoidance"
    case anxiety      = "anxiety"
    case distraction  = "distraction"
    case doubt        = "doubt"
    case laziness     = "laziness"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .temptation:   return "Temptation"
        case .pride:        return "Pride"
        case .selfReliance: return "Self-Reliance"
        case .lust:         return "Lust"
        case .anger:        return "Anger"
        case .avoidance:    return "Avoidance"
        case .anxiety:      return "Anxiety"
        case .distraction:  return "Distraction"
        case .doubt:        return "Doubt"
        case .laziness:     return "Laziness"
        }
    }

    var icon: String {
        switch self {
        case .temptation:   return "flame.fill"
        case .pride:        return "crown.fill"
        case .selfReliance: return "person.fill"
        case .lust:         return "flame.circle.fill"
        case .anger:        return "bolt.fill"
        case .avoidance:    return "arrow.uturn.backward"
        case .anxiety:      return "waveform.path.ecg"
        case .distraction:  return "iphone"
        case .doubt:        return "questionmark.circle.fill"
        case .laziness:     return "bed.double.fill"
        }
    }

    /// Audio file name for the anchoring prayer
    var audioPrayer: String {
        switch self {
        case .temptation, .lust: return "drift_temptation"
        case .pride:             return "drift_pride"
        case .anger:             return "drift_anger"
        case .avoidance:         return "drift_avoidance"
        default:                 return "drift_anchor"
        }
    }
}

// MARK: - ArrowRole (biblical manhood roles)
enum ArrowRole: String, Codable, CaseIterable, Identifiable {
    case truthTeller      = "truth_teller"
    case prayerWarrior    = "prayer_warrior"
    case providerProtector = "provider_protector"
    case servantLeader    = "servant_leader"
    case discipleMaker    = "disciple_maker"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .truthTeller:       return "Truth-Teller"
        case .prayerWarrior:     return "Prayer Warrior"
        case .providerProtector: return "Provider & Protector"
        case .servantLeader:     return "Servant Leader"
        case .discipleMaker:     return "Disciple Maker"
        }
    }

    var icon: String {
        switch self {
        case .truthTeller:       return "text.bubble.fill"
        case .prayerWarrior:     return "hands.sparkles.fill"
        case .providerProtector: return "shield.fill"
        case .servantLeader:     return "figure.walk"
        case .discipleMaker:     return "person.2.fill"
        }
    }

    var description: String {
        switch self {
        case .truthTeller:
            return "Spoke truth in love — to myself, family, or another man."
        case .prayerWarrior:
            return "Interceded in prayer for someone beyond myself."
        case .providerProtector:
            return "Provided or protected someone in my care today."
        case .servantLeader:
            return "Led by serving — put others' needs before my own."
        case .discipleMaker:
            return "Invested in another man's faith and growth."
        }
    }
}

// MARK: - DriftLog
struct DriftLog: Codable, Identifiable {
    @DocumentID var id: String?
    var timestamp: Date
    var category: AnchorTag
    var customCategory: String?   // non-nil when user picked a custom drift category
    var note: String

    /// Display name — uses custom name if present, otherwise the built-in tag name
    var displayName: String {
        customCategory ?? category.displayName
    }

    /// Icon — custom categories use a generic icon; built-in tags use their own
    var displayIcon: String {
        customCategory != nil ? "tag.fill" : category.icon
    }

    static func new(category: AnchorTag, note: String, customCategory: String? = nil) -> DriftLog {
        DriftLog(timestamp: Date(), category: category, customCategory: customCategory, note: note)
    }
}

// MARK: - Date Extension
extension Date {
    private static let _entryDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    var entryDateString: String {
        Self._entryDateFormatter.string(from: self)
    }

    private static let _displayShortFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    var displayShort: String {
        Self._displayShortFormatter.string(from: self)
    }
}
