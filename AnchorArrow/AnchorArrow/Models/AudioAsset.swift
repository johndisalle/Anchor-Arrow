// AudioAsset.swift
// A playable audio asset. Every scripture, prompt, prayer, and devotional
// has a stable ID that maps 1:1 to a file in Firebase Storage.
//
// Storage path scheme (keep flat and predictable — NEVER change an ID
// after launch or cached files break):
//
//   audio/anchor/prompts/anchor_001.mp3
//   audio/anchor/scripture/anchor_001.mp3
//   audio/anchor/prayers/morning_001.mp3
//   audio/arrow/prompts/arrow_001_warrior.mp3
//   audio/arrow/prayers/evening_001.mp3
//   audio/journey/stand_firm/day_01_devotional.mp3
//   audio/journey/stand_firm/day_01_anchor.mp3
//   audio/journey/stand_firm/day_01_arrow.mp3

import Foundation

struct AudioAsset: Identifiable, Hashable {
    let id: String          // stable across app versions
    let kind: Kind
    let title: String       // shown in the player bar: "Anchor Scripture"
    let subtitle: String?   // shown smaller: "1 Corinthians 16:13"
    let storagePath: String // "audio/anchor/prompts/anchor_001.mp3"
    let estimatedDurationSec: Int  // from generation step; used for UI placeholder

    enum Kind: String, Codable {
        case anchorScripture
        case anchorPrompt
        case morningPrayer
        case arrowScripture
        case arrowPrompt
        case eveningPrayer
        case journeyDevotional
        case journeyAnchor
        case journeyArrow
    }
}

// MARK: - ID helpers
// These are the ONLY source of truth for path construction. If you change
// them, update the generator script to match.
extension AudioAsset {

    static func anchorScripture(promptId: String, reference: String) -> AudioAsset {
        AudioAsset(
            id: "anchor_scripture_\(promptId)",
            kind: .anchorScripture,
            title: "Today's Scripture",
            subtitle: reference,
            storagePath: "audio/anchor/scripture/\(promptId).mp3",
            estimatedDurationSec: 20
        )
    }

    static func anchorPrompt(promptId: String) -> AudioAsset {
        AudioAsset(
            id: "anchor_prompt_\(promptId)",
            kind: .anchorPrompt,
            title: "Reflection",
            subtitle: nil,
            storagePath: "audio/anchor/prompts/\(promptId).mp3",
            estimatedDurationSec: 30
        )
    }

    static func arrowScripture(promptId: String, reference: String) -> AudioAsset {
        AudioAsset(
            id: "arrow_scripture_\(promptId)",
            kind: .arrowScripture,
            title: "Today's Scripture",
            subtitle: reference,
            storagePath: "audio/arrow/scripture/\(promptId).mp3",
            estimatedDurationSec: 20
        )
    }

    static func arrowPrompt(promptId: String) -> AudioAsset {
        AudioAsset(
            id: "arrow_prompt_\(promptId)",
            kind: .arrowPrompt,
            title: "Reflection",
            subtitle: nil,
            storagePath: "audio/arrow/prompts/\(promptId).mp3",
            estimatedDurationSec: 30
        )
    }

    static func morningPrayer(index: Int) -> AudioAsset {
        let padded = String(format: "%03d", index + 1)
        return AudioAsset(
            id: "morning_prayer_\(padded)",
            kind: .morningPrayer,
            title: "Morning Prayer",
            subtitle: nil,
            storagePath: "audio/anchor/prayers/morning_\(padded).mp3",
            estimatedDurationSec: 60
        )
    }

    static func eveningPrayer(index: Int) -> AudioAsset {
        let padded = String(format: "%03d", index + 1)
        return AudioAsset(
            id: "evening_prayer_\(padded)",
            kind: .eveningPrayer,
            title: "Evening Prayer",
            subtitle: nil,
            storagePath: "audio/arrow/prayers/evening_\(padded).mp3",
            estimatedDurationSec: 60
        )
    }

    static func journeyDevotional(series: String, day: Int) -> AudioAsset {
        let padded = String(format: "%02d", day)
        return AudioAsset(
            id: "journey_\(series)_day\(padded)_devotional",
            kind: .journeyDevotional,
            title: "Day \(day) Devotional",
            subtitle: nil,
            storagePath: "audio/journey/\(series)/day_\(padded)_devotional.mp3",
            estimatedDurationSec: 180
        )
    }

    static func journeyAnchor(series: String, day: Int) -> AudioAsset {
        let padded = String(format: "%02d", day)
        return AudioAsset(
            id: "journey_\(series)_day\(padded)_anchor",
            kind: .journeyAnchor,
            title: "Day \(day) Anchor Reflection",
            subtitle: nil,
            storagePath: "audio/journey/\(series)/day_\(padded)_anchor.mp3",
            estimatedDurationSec: 30
        )
    }

    static func journeyArrow(series: String, day: Int) -> AudioAsset {
        let padded = String(format: "%02d", day)
        return AudioAsset(
            id: "journey_\(series)_day\(padded)_arrow",
            kind: .journeyArrow,
            title: "Day \(day) Arrow Reflection",
            subtitle: nil,
            storagePath: "audio/journey/\(series)/day_\(padded)_arrow.mp3",
            estimatedDurationSec: 30
        )
    }
}
