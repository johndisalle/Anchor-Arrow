// DriftPrayerLibrary.swift
// Multiple prayers per drift category — rotates so users get variety

import Foundation

struct DriftPrayerLibrary {

    /// Returns a drift prayer for the given category, rotating by day
    static func prayer(for tag: AnchorTag) -> String {
        let prayers = prayersByCategory[tag] ?? defaultPrayers
        let dayOfYear = max(1, Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1)
        return prayers[(dayOfYear - 1) % prayers.count]
    }

    private static let defaultPrayers = [
        "Lord Jesus, anchor me firm right now. I reject this lie. I stand on Your truth. Fill me with Your Spirit. Amen.",
        "Father, I bring this to You. Not to my own willpower, not to distraction, but to You. Take it. Replace it with Your peace. Amen.",
        "God, I name what is pulling at me. I refuse to let it win. You are stronger. You are greater. You are my anchor. Amen.",
        "Lord, I choose You over this drift. Right now. Not later. Now. Meet me here. Anchor me back. Amen.",
    ]

    static let prayersByCategory: [AnchorTag: [String]] = [
        .temptation: [
            "Lord Jesus, anchor me firm right now. I reject this temptation. It has no power over me because I belong to You. Fill me with Your Spirit. Let me walk in Your freedom. Amen.",
            "Father, the pull is real but You are stronger. I choose You over this. Right now. Not in five minutes. Now. Close every door that leads away from You. Amen.",
            "God, I am being tempted and I am telling You about it instead of giving in. That is the first victory. Now give me the second: strength to walk away. Amen.",
            "Lord, You were tempted in every way and did not sin. Live through me right now. I cannot resist this alone but I am not alone. You are here. Amen.",
        ],
        .pride: [
            "Father, forgive me for exalting myself. Humble me now. You are God, I am not. Let me decrease and You increase in every part of my life. Amen.",
            "Lord, my pride tells me I do not need help. That is the biggest lie of all. I need You desperately. I need my brothers. Tear down my self-sufficiency. Amen.",
            "God, I confess that I have been making this about me. My reputation, my comfort, my control. It is all Yours. I am just a steward. Forgive my arrogance. Amen.",
            "Jesus, You washed feet. You served. You humbled Yourself to death. Who am I to exalt myself? Lower me, Lord. All the way down. Amen.",
        ],
        .anger: [
            "God, I bring this anger to You. Let me be slow to anger and slow to speak. Guard my tongue. Protect those around me from my flesh. Give me Your peace. Amen.",
            "Lord, I feel the fire rising. Before I speak, before I act, I pause. I bring this to You. You are the only safe place for my anger. Take it before it takes something from me. Amen.",
            "Father, my anger is not righteous right now. It is selfish. It wants control, revenge, validation. Replace it with Your peace. Let me respond, not react. Amen.",
            "Jesus, You flipped tables but You never lost control. Give me the kind of anger that fights for what is right and restrains what is wrong. Master my temper. Amen.",
        ],
        .selfReliance: [
            "Lord, I repent of trusting in my own strength. Without You I can do nothing. I surrender this to You right now. Be my strength. Amen.",
            "Father, I have been trying to handle this myself again. Control is my drug. I lay it down. You are the one in charge, not me. Amen.",
            "God, self-reliance feels safe but it is the most dangerous place I can be. Alone is where the enemy wants me. I choose dependence on You. Amen.",
            "Lord, I am not the captain of my life. You are. I step down from the wheel and let You steer. Where You lead, I follow. Amen.",
        ],
        .lust: [
            "Lord Jesus, anchor me firm right now. I reject this temptation. My body is a temple of the Holy Spirit. I will not defile what You have made holy. Amen.",
            "Father, this pull is strong but You are stronger. I turn my eyes to You. I flee this, not in shame but in obedience. You are better than what this offers. Amen.",
            "God, I bring this into the light right now. Darkness loses power when it is exposed. I confess this pull and I choose purity. Not perfection but pursuit. Amen.",
            "Lord, guard my eyes, my mind, and my heart. What enters through my eyes shapes my soul. I choose to look at what honors You today. Amen.",
        ],
        .avoidance: [
            "Jesus, give me the courage to face what I am running from. I choose obedience over comfort. You equip what You call. Let me take the next step. Amen.",
            "Lord, I have been avoiding this because it scares me. But fear is not from You. Give me the courage to step into what I have been stepping around. Amen.",
            "Father, procrastination is just fear in slow motion. I face this today. Not tomorrow. Not next week. Today. With You beside me. Amen.",
            "God, I have been hiding from this responsibility. I own it now. You do not call the equipped, You equip the called. Send me. Amen.",
        ],
        .anxiety: [
            "Father, I cast this anxiety on You because You care for me. You hold tomorrow. You are not surprised. Let Your peace guard my heart and mind in Christ Jesus. Amen.",
            "Lord, my mind is racing and my chest is tight. But You are the God of peace. Slow me down. Breathe through me. I am safe in Your hands. Amen.",
            "God, I choose to believe that You are in control even when everything feels out of control. My feelings are loud but Your truth is louder. Amen.",
            "Jesus, You told me not to worry about tomorrow. Tomorrow has enough trouble of its own. Help me stay in today. Right here. With You. Amen.",
        ],
        .distraction: [
            "Lord, I have been scrolling when I should have been praying. I put the phone down. I look up. You have my attention now. Amen.",
            "Father, the noise is deafening. Everyone wants a piece of my attention. But You deserve it first. I silence the distractions and tune in to You. Amen.",
            "God, I have been busy but not productive. Active but not purposeful. Redirect my energy to what matters. Cut the noise. Sharpen my focus. Amen.",
            "Lord, I confess that I have been numbing myself with distractions. Not because I am bored but because I am avoiding You. I stop running. Here I am. Amen.",
        ],
        .doubt: [
            "Lord, I believe. Help my unbelief. Your Word is true whether I feel it or not. Anchor me in truth, not feelings. I stand on Your faithfulness. Amen.",
            "Father, doubt is knocking and I am answering the door. Slam it shut. Remind me of every time You came through. Your track record is perfect. Amen.",
            "God, I do not need to understand everything to trust You. Faith is stepping forward when I cannot see the ground. I step forward now. Amen.",
            "Lord, my doubts feel louder than Your promises today. Silence them with Your presence. You are real. You are here. You have not abandoned me. Amen.",
        ],
        .laziness: [
            "Lord, I confess spiritual laziness. I have been coasting when You have called me to climb. Stir my spirit. Ignite my purpose. I refuse to waste today. Amen.",
            "Father, the sluggard craves and gets nothing. I do not want to be that man. Give me discipline. Give me fire. Make me diligent in the things that matter. Amen.",
            "God, laziness is not rest. Rest is holy. Laziness is rebellion. I choose holy rest and purposeful action today. No more coasting. Amen.",
            "Lord, You worked six days and rested one. You are not idle and neither should I be. Put a fire under me today. In Jesus' name, Amen.",
        ],
    ]
}
