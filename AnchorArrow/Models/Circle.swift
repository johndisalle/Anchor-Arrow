// Circle.swift
// Iron Sharpeners – private accountability groups

import Foundation
import FirebaseFirestore

// MARK: - Circle
struct Circle: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var inviteCode: String
    var creatorId: String
    var memberIds: [String]
    var createdAt: Date
    var isPublic: Bool

    var memberCount: Int { memberIds.count }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        _id        = try c.decode(DocumentID<String>.self, forKey: .id)
        name       = try c.decode(String.self, forKey: .name)
        inviteCode = try c.decode(String.self, forKey: .inviteCode)
        creatorId  = try c.decode(String.self, forKey: .creatorId)
        memberIds  = try c.decode([String].self, forKey: .memberIds)
        createdAt  = try c.decode(Date.self, forKey: .createdAt)
        isPublic   = try c.decodeIfPresent(Bool.self, forKey: .isPublic) ?? false
    }

    init(name: String, inviteCode: String, creatorId: String,
         memberIds: [String], createdAt: Date, isPublic: Bool = false) {
        self.name = name
        self.inviteCode = inviteCode
        self.creatorId = creatorId
        self.memberIds = memberIds
        self.createdAt = createdAt
        self.isPublic = isPublic
    }

    static func new(name: String, creatorId: String, isPublic: Bool = false) -> Circle {
        Circle(
            name: name,
            inviteCode: Circle.generateCode(),
            creatorId: creatorId,
            memberIds: [creatorId],
            createdAt: Date(),
            isPublic: isPublic
        )
    }

    private static func generateCode() -> String {
        let chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<6).map { _ in chars.randomElement() ?? "A" })
    }
}

// MARK: - MemberProfile
/// Lightweight snapshot of a brother's accountability status — read from his user doc.
struct MemberProfile {
    let uid: String
    let displayName: String
    let currentStreak: Int
    let lastEntryDate: Date?

    var isActiveToday: Bool {
        guard let last = lastEntryDate else { return false }
        return Calendar.current.isDateInToday(last)
    }

    var isStreakAlive: Bool {
        guard let last = lastEntryDate else { return false }
        return Calendar.current.isDateInToday(last) || Calendar.current.isDateInYesterday(last)
    }

    /// Days since the brother last logged any entry (0 = today, 1 = yesterday, …)
    var daysSinceActive: Int {
        guard let last = lastEntryDate else { return 999 }
        let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: last),
                                                   to: Calendar.current.startOfDay(for: Date())).day ?? 999
        return max(days, 0)
    }
}

// MARK: - CirclePost
struct CirclePost: Codable, Identifiable {
    @DocumentID var id: String?
    var circleId: String
    var authorId: String
    var authorName: String
    var content: String
    var type: PostType
    var isAnonymous: Bool
    var timestamp: Date
    var reactions: [String: Int] = [:]
    var isAnswered: Bool = false
    var isPinned: Bool = false

    var totalReactions: Int { reactions.values.reduce(0, +) }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        _id         = try c.decode(DocumentID<String>.self, forKey: .id)
        circleId    = try c.decode(String.self, forKey: .circleId)
        authorId    = try c.decode(String.self, forKey: .authorId)
        authorName  = try c.decode(String.self, forKey: .authorName)
        content     = try c.decode(String.self, forKey: .content)
        type        = try c.decode(PostType.self, forKey: .type)
        isAnonymous = try c.decode(Bool.self, forKey: .isAnonymous)
        timestamp   = try c.decode(Date.self, forKey: .timestamp)
        reactions   = try c.decodeIfPresent([String: Int].self, forKey: .reactions) ?? [:]
        isAnswered  = try c.decodeIfPresent(Bool.self, forKey: .isAnswered) ?? false
        isPinned    = try c.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
    }

    init(circleId: String, authorId: String, authorName: String, content: String,
         type: PostType, isAnonymous: Bool, timestamp: Date,
         reactions: [String: Int] = [:], isAnswered: Bool = false, isPinned: Bool = false) {
        self.circleId = circleId
        self.authorId = authorId
        self.authorName = authorName
        self.content = content
        self.type = type
        self.isAnonymous = isAnonymous
        self.timestamp = timestamp
        self.reactions = reactions
        self.isAnswered = isAnswered
        self.isPinned = isPinned
    }
}

// MARK: - CircleComment
struct CircleComment: Codable, Identifiable {
    @DocumentID var id: String?
    var postId: String
    var circleId: String
    var authorId: String
    var authorName: String
    var content: String
    var isAnonymous: Bool
    var timestamp: Date
}

// MARK: - PostType
enum PostType: String, Codable, CaseIterable {
    case anchor  = "anchor"
    case arrow   = "arrow"
    case drift   = "drift"
    case prayer  = "prayer"
    case general = "general"

    var displayName: String {
        switch self {
        case .anchor:  return "Anchored"
        case .arrow:   return "Arrow Loosed"
        case .drift:   return "Drift Moment"
        case .prayer:  return "Prayer Request"
        case .general: return "Share"
        }
    }

    var icon: String {
        switch self {
        case .anchor:  return "anchor"
        case .arrow:   return "arrow.up.right"
        case .drift:   return "exclamationmark.shield"
        case .prayer:  return "hands.sparkles"
        case .general: return "bubble.left"
        }
    }

    var color: String {
        switch self {
        case .anchor:  return "BrandAnchor"
        case .arrow:   return "BrandArrow"
        case .drift:   return "BrandWarning"
        case .prayer:  return "BrandGold"
        case .general: return "TextSecondary"
        }
    }

    /// Contextual nudge shown in the composer when this type is selected
    var postHint: String {
        switch self {
        case .anchor:
            return "Share what's holding you steady. Your anchor keeps the circle grounded."
        case .arrow:
            return "Your wins sharpen your brothers. Don't downplay the mission advancing."
        case .drift:
            return "The lion takes out the isolated. Let your brothers stand with you now."
        case .prayer:
            return "If you don't have men praying for you, build that today. Your circle will carry this."
        case .general:
            return "Your voice matters here. Don't be silent."
        }
    }
}

// MARK: - JourneyTheme
struct JourneyDay: Identifiable, Codable {
    var id: Int           // day number 1-30
    var week: Int         // 1-4
    var theme: String
    var scripture: String
    var devotional: String = ""
    var anchorPrompt: String
    var arrowPrompt: String
    var isUnlocked: Bool
    var completedDate: Date?

    var isCompleted: Bool { completedDate != nil }
}

// MARK: - AnchorPrompt (daily scripture prompts)
struct AnchorPrompt: Identifiable, Codable {
    var id: String
    var theme: PromptTheme
    var scripture: String
    var reference: String
    var reflectionQuestion: String
    var prayerStart: String   // opening line for the prayer
}

enum PromptTheme: String, Codable, CaseIterable {
    case watchful    = "watchful"
    case standFirm   = "stand_firm"
    case actLikeMen  = "act_like_men"
    case beStrong    = "be_strong"
    case inLove      = "in_love"
    case surrender   = "surrender"
    case armor       = "armor"
}

// MARK: - ArrowPrompt
struct ArrowPrompt: Identifiable, Codable {
    var id: String
    var role: ArrowRole
    var question: String
    var example: String     // brief example of what this might look like
    var verseReference: String
}
