// Prompts.swift
// Hardcoded prompt library (expandable to Firestore fetch later)

import Foundation

// MARK: - Prompt Library
struct PromptLibrary {

    // MARK: - Anchor Prompts
    static let anchorPrompts: [AnchorPrompt] = [
        AnchorPrompt(
            id: "anchor_001",
            theme: .watchful,
            scripture: "Be watchful, stand firm in the faith, act like men, be strong.",
            reference: "1 Corinthians 16:13",
            reflectionQuestion: "What cultural lie or distraction is pulling at you today? Name it out loud and reject it in Christ's truth.",
            prayerStart: "Lord, open my eyes to what is pulling me off course today."
        ),
        AnchorPrompt(
            id: "anchor_002",
            theme: .standFirm,
            scripture: "Put on the full armor of God, so that you can take your stand against the devil's schemes.",
            reference: "Ephesians 6:11",
            reflectionQuestion: "Which piece of God's armor do you most need to pick up today — truth, righteousness, faith, salvation, the Word, or prayer?",
            prayerStart: "Father, I suit up in Your armor today. I am not fighting alone."
        ),
        AnchorPrompt(
            id: "anchor_003",
            theme: .surrender,
            scripture: "I have been crucified with Christ. It is no longer I who live, but Christ who lives in me.",
            reference: "Galatians 2:20",
            reflectionQuestion: "What part of your will are you holding back from Christ today? What does full surrender look like right now?",
            prayerStart: "Jesus, I surrender this to You. Not my will but Yours."
        ),
        AnchorPrompt(
            id: "anchor_004",
            theme: .watchful,
            scripture: "Be sober-minded; be watchful. Your adversary the devil prowls around like a roaring lion.",
            reference: "1 Peter 5:8",
            reflectionQuestion: "Where are you most spiritually asleep or numb right now? What would waking up look like today?",
            prayerStart: "God, alert me. Sharpen my spiritual sight today."
        ),
        AnchorPrompt(
            id: "anchor_005",
            theme: .armor,
            scripture: "Finally, be strong in the Lord and in the strength of his might.",
            reference: "Ephesians 6:10",
            reflectionQuestion: "Are you trying to fight in your own strength today? Where do you need to stop striving and start trusting?",
            prayerStart: "Lord, I choose Your strength over my own today."
        ),
        AnchorPrompt(
            id: "anchor_006",
            theme: .standFirm,
            scripture: "No temptation has overtaken you that is not common to man. God is faithful.",
            reference: "1 Corinthians 10:13",
            reflectionQuestion: "What temptation feels uniquely overwhelming right now? How has God already provided a way of escape you haven't taken?",
            prayerStart: "Father, show me the way out. I trust Your faithfulness."
        ),
        AnchorPrompt(
            id: "anchor_007",
            theme: .beStrong,
            scripture: "The LORD is my strength and my song; he has become my salvation.",
            reference: "Exodus 15:2",
            reflectionQuestion: "What are you afraid of today? Bring it before God and declare: 'The Lord is my strength in this.'",
            prayerStart: "Lord, You are my strength. I will not fear."
        ),
        AnchorPrompt(
            id: "anchor_008",
            theme: .watchful,
            scripture: "Do not be conformed to this world, but be transformed by the renewal of your mind.",
            reference: "Romans 12:2",
            reflectionQuestion: "Where has the world's thinking crept into how you see yourself, success, or relationships? What does God's truth say instead?",
            prayerStart: "Renew my mind, God. Let me think Your thoughts today."
        ),
        AnchorPrompt(
            id: "anchor_009",
            theme: .surrender,
            scripture: "Come to me, all who labor and are heavy laden, and I will give you rest.",
            reference: "Matthew 11:28",
            reflectionQuestion: "What weight are you carrying that Jesus is asking you to hand over? What would real rest in Him look like today?",
            prayerStart: "Jesus, I lay this down at Your feet. I take Your yoke instead."
        ),
        AnchorPrompt(
            id: "anchor_010",
            theme: .actLikeMen,
            scripture: "Watch, stand fast in the faith, be brave, be strong.",
            reference: "1 Corinthians 16:13 (NKJV)",
            reflectionQuestion: "Where are you being passive when God is calling you to act — in your home, friendships, work, or community?",
            prayerStart: "God, give me the courage to act, not just intend."
        )
    ]

    // MARK: - Arrow Prompts
    static let arrowPrompts: [ArrowPrompt] = [
        ArrowPrompt(
            id: "arrow_001",
            role: .servantLeader,
            question: "What one act of servant leadership did you take today — putting someone else's needs before your own?",
            example: "Did the dishes without being asked. Listened fully to my wife without offering solutions. Let a coworker take credit.",
            verseReference: "Mark 10:45"
        ),
        ArrowPrompt(
            id: "arrow_002",
            role: .truthTeller,
            question: "Did you speak truth in love today — to yourself, your family, or another man?",
            example: "Admitted I was wrong to a friend. Told my son the truth he needed to hear. Didn't laugh at the joke that dishonored women.",
            verseReference: "Ephesians 4:15"
        ),
        ArrowPrompt(
            id: "arrow_003",
            role: .prayerWarrior,
            question: "Who did you intercede for in prayer today — beyond yourself?",
            example: "Prayed specifically for my dad by name. Texted a brother asking how I could pray. Prayed over my home before leaving.",
            verseReference: "1 Timothy 2:1"
        ),
        ArrowPrompt(
            id: "arrow_004",
            role: .providerProtector,
            question: "How did you provide or protect someone in your care today?",
            example: "Worked faithfully to provide for my family. Said 'that's not okay' when someone was treated poorly. Walked my mom to her car.",
            verseReference: "1 Timothy 5:8"
        ),
        ArrowPrompt(
            id: "arrow_005",
            role: .discipleMaker,
            question: "Did you invest in another man's faith or growth today — even in a small way?",
            example: "Sent an encouraging verse to a brother. Mentioned what God has been teaching me. Invited someone to church.",
            verseReference: "2 Timothy 2:2"
        ),
        ArrowPrompt(
            id: "arrow_006",
            role: .servantLeader,
            question: "Where did you choose to lead through service rather than authority today?",
            example: "Volunteered for the task no one wanted. Cleaned up after the event. Let my team take the win.",
            verseReference: "John 13:14"
        ),
        ArrowPrompt(
            id: "arrow_007",
            role: .prayerWarrior,
            question: "What battle did you take to prayer today that you might have normally tried to handle alone?",
            example: "Prayed before a hard conversation. Brought my financial worry to God. Prayed for my enemy.",
            verseReference: "Philippians 4:6"
        )
    ]

    // MARK: - Journey Plan (30 Days)
    static func journeyDays() -> [JourneyDay] {
        let data: [(week: Int, theme: String, scripture: String, anchor: String, arrow: String)] = [
            // Week 1 — Be Watchful
            (1, "Be Watchful", "1 Peter 5:8", "What is distracting me from eternal things today?", "How can I stay alert to God's voice in my environment today?"),
            (1, "Know Your Enemy", "Ephesians 6:12", "What lies am I believing that are not from God?", "How do I engage spiritual warfare through prayer today?"),
            (1, "Sober-Minded", "1 Peter 1:13", "What is clouding my judgment or dulling my spiritual alertness?", "How will I set my hope fully on God's grace today?"),
            (1, "Eyes Open", "Romans 12:2", "Where has the world shaped my thinking more than the Word?", "What truth replaces one lie I've believed?"),
            (1, "Guard Your Heart", "Proverbs 4:23", "What am I feeding my mind and heart through screens?", "What am I putting in today that is true and excellent?"),
            (1, "Alert in Prayer", "Colossians 4:2", "Am I consistent or sporadic in prayer?", "Pray specifically for 3 people by name today."),
            (1, "Week 1 Review", "1 Corinthians 16:13", "What has God revealed about areas of drift this week?", "Share one win with a trusted brother this week."),

            // Week 2 — Stand Firm in Faith
            (2, "Roots Deep", "Colossians 2:7", "Where are my roots in Christ growing? Where are they shallow?", "What truth am I standing on that cannot be shaken?"),
            (2, "The Full Armor", "Ephesians 6:13-17", "Which armor piece am I neglecting? Belt, breastplate, shoes, shield, helmet, sword?", "How do I wield the sword of the Spirit today?"),
            (2, "Faith Over Fear", "Hebrews 11:1", "What fear is competing with my faith right now?", "Take one step of obedience in the area you fear today."),
            (2, "Tested Faith", "James 1:3", "How is God using a current trial to strengthen my faith?", "Respond to today's trial with gratitude, not grumbling."),
            (2, "Anchored in Truth", "John 17:17", "What does God's Word say about my current struggle?", "Memorize one verse that anchors you in truth this week."),
            (2, "Stand Against Drift", "Hebrews 2:1", "What small drifts have accumulated to bring me off course?", "Name one drift and take a concrete step back toward center."),
            (2, "Week 2 Review", "Psalm 46:1-3", "How is God proving Himself an anchor in your storms?", "Encourage another man who is in a storm right now."),

            // Week 3 — Act Like Men / Be Strong
            (3, "Courageous Action", "Joshua 1:9", "Where am I being passive that God is calling me to act?", "Take one courageous action today that costs you something."),
            (3, "Strength in Weakness", "2 Corinthians 12:10", "Where am I striving in my own strength and burning out?", "Confess one weakness to God and trust His strength in it."),
            (3, "Lead Well", "Ephesians 5:25-26", "How am I leading those in my care — through love or control?", "Do one concrete act of servant leadership today at home."),
            (3, "Speak Truth", "Proverbs 27:5", "Am I keeping the peace or building it? What truth needs to be spoken?", "Have one honest conversation you've been avoiding."),
            (3, "Provision", "1 Timothy 5:8", "Am I faithfully stewarding my responsibilities?", "Identify one area of provision (financial, emotional, spiritual) to act on."),
            (3, "Protect the Weak", "Proverbs 31:8-9", "Who in my circle needs advocacy, protection, or defense?", "Speak up for or serve someone who cannot return the favor."),
            (3, "Week 3 Review", "Micah 6:8", "Do justice, love mercy, walk humbly — where am I weakest?", "Serve anonymously — do something good that no one will see."),

            // Week 4 — Let All Be Done in Love
            (4, "Love as Foundation", "1 Corinthians 13:1-3", "What good things am I doing that are driven by ego rather than love?", "Do one thing today purely from love, expecting nothing back."),
            (4, "Sacrificial Love", "John 15:13", "Where is God calling me to lay something down for someone else's good?", "Sacrifice your preference today for someone else's flourishing."),
            (4, "Love Your Neighbor", "Luke 10:36-37", "Who is my neighbor that I've been overlooking?", "Take one concrete act of love toward someone outside my usual circle."),
            (4, "Forgiveness", "Colossians 3:13", "Is there an unresolved offense I'm holding onto that is affecting my freedom?", "Take a step toward forgiveness — write it, pray it, or speak it."),
            (4, "Love in Community", "Hebrews 10:24-25", "Am I truly known by other men? Am I isolating?", "Reach out to one man for real conversation this week."),
            (4, "Love Covers", "1 Peter 4:8", "How do I talk about others when they're not present?", "Speak life about someone you've been criticizing."),
            (4, "Week 4 Review", "1 John 4:19", "We love because He first loved us. How has that truth changed you this month?", "Write a letter (or message) of encouragement to a man who sharpened you."),

            // Days 29-30 — Completion
            (4, "Integration Day", "Romans 8:37-39", "How has God met you in this journey?", "Share your biggest takeaway with your circle or a trusted friend."),
            (4, "Stand Firm — Always", "1 Corinthians 16:13-14", "What is your one-sentence commitment going forward as an anchored, purposeful man?", "Set a new goal. Restart the journey. Sharpen another man.")
        ]

        return data.enumerated().map { index, item in
            JourneyDay(
                id: index + 1,
                week: item.week,
                theme: item.theme,
                scripture: item.scripture,
                anchorPrompt: item.anchor,
                arrowPrompt: item.arrow,
                isUnlocked: index == 0,
                completedDate: nil
            )
        }
    }

    // MARK: - Today's Prompt
    static func anchorPromptForToday() -> AnchorPrompt {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        let index = dayOfYear % anchorPrompts.count
        return anchorPrompts[index]
    }

    static func arrowPromptForToday() -> ArrowPrompt {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        let index = dayOfYear % arrowPrompts.count
        return arrowPrompts[index]
    }

    // MARK: - Circle Daily Prompts
    static let circlePrompts: [String] = [
        "What's one thing God is teaching you this week that you haven't told anyone yet?",
        "Where did you feel the strongest pull toward drift in the last 24 hours?",
        "Name one person outside this circle you're actively praying for by name.",
        "What's one area where you need your brothers to hold you accountable right now?",
        "What does being an anchored man look like in your specific role this week?",
        "Share a win — no matter how small. What did you do right today?",
        "What lie are you fighting most right now? What is the truth that counters it?",
        "How are you leading in your home, workplace, or community this week?",
        "What would change if you fully surrendered this one thing to God today?",
        "Who in your life needs to hear the gospel, and what's holding you back?",
        "What does your prayer life actually look like right now — honest answer?",
        "Where have you felt God's presence most powerfully in the last week?",
        "What temptation came at you hardest this week, and how did you respond?",
        "Are you running toward God or just avoiding going further from Him right now?",
        "What would 'being strong and courageous' look like in your life today?",
        "How are you serving the people God has put in your immediate circle of influence?",
        "What part of your identity in Christ do you struggle to actually believe on hard days?",
        "Where are you most tempted to fake it — to present a version of yourself that isn't real?",
        "What sacrifice is God asking you to make right now that you've been resisting?",
        "If your brothers could only pray one thing for you today, what would it be?",
        "What does iron sharpening iron actually look like in your life right now?",
        "Where are you growing? Name something specific, not general.",
        "What conversation have you been avoiding that God keeps bringing back to your mind?",
        "How did you provide or protect someone in your care this week?",
        "What piece of God's armor do you most need to pick up today?",
        "Where is your faith being tested right now, and how are you responding?",
        "What habit or pattern in your life needs to die for the man God is calling you to become?",
        "Who sharpened you recently? Name them and what they said.",
        "What are you grateful for that you haven't actually thanked God for yet?",
        "What's one thing you'd do differently this week if you were fully walking in the Spirit?"
    ]

    static func circlePromptForToday() -> String {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        let index = dayOfYear % circlePrompts.count
        return circlePrompts[index]
    }
}
