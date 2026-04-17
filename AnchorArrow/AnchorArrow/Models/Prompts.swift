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
    static func journeyDays(for series: JourneySeries = .standFirm) -> [JourneyDay] {
        switch series {
        case .standFirm:        return standFirmJourneyDays()
        case .armorOfGod:       return armorOfGodJourneyDays()
        case .surrenderFirst:   return surrenderFirstJourneyDays()
        case .prophetPriestKing: return prophetPriestKingJourneyDays()
        case .strengthInLove:    return strengthInLoveJourneyDays()
        case .guardTheGates:     return guardTheGatesJourneyDays()
        case .theFathersHeart:   return JourneyLibrary.theFathersHeartDays()
        case .warriorMindset:    return JourneyLibrary.warriorMindsetDays()
        case .theNarrowRoad:     return JourneyLibrary.theNarrowRoadDays()
        case .rootedAndBuilt:    return JourneyLibrary.rootedAndBuiltDays()
        case .forgedInFire:      return JourneyLibrary.forgedInFireDays()
        case .theSentLife:       return JourneyLibrary.theSentLifeDays()
        }
    }

    private static func standFirmJourneyDays() -> [JourneyDay] {
        struct DayData {
            let week: Int
            let theme: String
            let scripture: String
            let devotional: String
            let anchor: String
            let arrow: String
        }

        let data: [DayData] = [

            // MARK: Week 1 — Be Watchful

            DayData(week: 1, theme: "Be Watchful", scripture: "1 Peter 5:8",
                devotional: "The enemy doesn't announce himself. He prowls — quietly, strategically, looking for the man who's distracted, comfortable, or half-asleep. Peter wrote this to men under real pressure — losing jobs, families, reputations for their faith — and his warning was: stay alert. The word \"sober-minded\" in Greek means clear-headed, undrugged. There are a thousand things in today's world designed to keep you just comfortable enough to stop paying attention. Screens. Busyness. Comfort. Success. None of them are wrong in themselves, but they can lull you into spiritual sleep. The man who stands firm is the man who stays awake. Not paranoid — anchored. Not anxious — alert.",
                anchor: "What is distracting me from eternal things today? Name it honestly.",
                arrow: "How can I stay alert to God's voice in my environment today?"),

            DayData(week: 1, theme: "Know Your Enemy", scripture: "Ephesians 6:12",
                devotional: "Most men are fighting the wrong battle. We wrestle against flesh and blood — the boss, the culture, the spouse, the coworker. But Paul says the real fight is against principalities and powers, the rulers of darkness. There's a war going on behind what you can see. That argument that keeps coming up? There may be something underneath it. That persistent thought telling you you're not enough, you're a failure, God's given up on you? That's not neutral. You don't fight a spiritual battle with physical weapons. The most dangerous man in the room isn't the one with the loudest voice — it's the one who knows who his real enemy is, and fights on his knees before he fights on his feet.",
                anchor: "What lies am I believing right now that are not from God?",
                arrow: "How will I engage the spiritual battle through prayer today instead of reacting in the flesh?"),

            DayData(week: 1, theme: "Sober-Minded", scripture: "1 Peter 1:13",
                devotional: "\"Gird up the loins of your mind.\" In the first century you literally pulled your robe up and tucked it into your belt to move fast. Peter says: do that with your mind. Get it ready for action. There's a fog that settles over men when they haven't been in the Word, haven't prayed, haven't been accountable. They start thinking like the world because they've been marinating in it. Clarity of mind is a spiritual discipline. What goes in shapes what you think. What you think shapes what you do. What you do shapes who you become. Set your hope today — not on the news, the market, or your career — fully on the grace coming to you in Christ.",
                anchor: "What is clouding my judgment or dulling my spiritual alertness right now?",
                arrow: "How will I set my hope fully on God's grace rather than circumstances today?"),

            DayData(week: 1, theme: "Eyes Open", scripture: "Romans 12:2",
                devotional: "Conformity doesn't come through dramatic decisions. It creeps in through a thousand small compromises — the content you watch, the conversations you accept, the assumptions you never question. \"Do not be conformed\" is present passive tense in Greek — it means stop being shaped by the mold that's continuously pressing against you. The world doesn't ask permission to shape you. It just does it quietly, daily. The counter isn't trying harder — it's transformation at the level of your mind. When you renew your mind with truth, you stop responding the way the world trained you to and start responding the way a son of God would.",
                anchor: "Where has the world shaped my thinking more than the Word this week?",
                arrow: "What one truth from Scripture will I use to replace a lie I've been believing?"),

            DayData(week: 1, theme: "Guard Your Heart", scripture: "Proverbs 4:23",
                devotional: "\"Above all else\" — Solomon is saying: of everything you could protect, make this the top priority. Because everything you are flows from your heart. Your leadership, your love, your integrity, your decisions — they all trace back to what you're allowing to take up residence inside you. In Solomon's day, the city gates were the strategic defense point. What comes through the gates determines the safety of everything inside. You are a gatekeeper. You decide what gets access to you — what you read, watch, and listen to, what conversations you have, what voices you give authority to. Not everything that wants in is good for you. Guard accordingly.",
                anchor: "What am I feeding my mind and heart through screens and media? Is it making me more or less like Christ?",
                arrow: "What will I intentionally put in today that is true, honorable, and excellent?"),

            DayData(week: 1, theme: "Alert in Prayer", scripture: "Colossians 4:2",
                devotional: "Paul wrote \"continue earnestly in prayer, being watchful in it.\" The word \"earnestly\" means to persist with intensity, to be strong toward something. Most men don't struggle with believing in prayer. They struggle with actually doing it consistently. We talk about prayer, believe in prayer, but live practically prayerless lives and wonder why we feel distant from God. Watchfulness and prayer are linked here on purpose — a man who isn't praying is a man who isn't paying attention to what's really happening. Prayer isn't for God's information — He already has it all. Prayer is how you stay calibrated. It's how you keep your heart pointed at the right target.",
                anchor: "Is my prayer life consistent or sporadic right now? What would it look like to pray with real earnestness today?",
                arrow: "Pray specifically for three people by name today. Write their names down before you start."),

            DayData(week: 1, theme: "Week 1 Review", scripture: "1 Corinthians 16:13",
                devotional: "Stand firm in the faith. Be brave. Be strong. Do everything in love. One verse — four commands. Paul wrote this to a church fighting internally, tolerating sin, confused about doctrine, and forgetting what mattered. Sound familiar? The Christian life is not a steady upward slope — it's a series of moments where you choose to re-anchor. Week 1 was about watchfulness — being alert to what's pulling at you. A man who can accurately assess where he is spiritually is a man who can actually grow. Don't perform this review for God — He already knows. Do it for yourself. Then find one brother and tell him what God revealed.",
                anchor: "Where did I drift this week? Where did I stay awake? What did God reveal about my areas of spiritual vulnerability?",
                arrow: "Share one honest win or one honest failure from this week with a trusted brother today."),

            // MARK: Week 2 — Stand Firm in Faith

            DayData(week: 2, theme: "Roots Deep", scripture: "Colossians 2:7",
                devotional: "A tree with deep roots doesn't just survive the storm — it barely moves while everything around it is torn loose. Paul uses the image of being rooted, built up, and established — agricultural, construction, and legal terms all at once. Deeply rooted. Actively built up. Firmly established. The Christian faith isn't meant to be something you drift in and out of based on how you feel. It's meant to be the ground you stand on so firmly that when the inevitable storms come — and they will come — you don't blow over. The question isn't whether your faith will be tested. The question is how deep your roots go before the test arrives.",
                anchor: "Where are my roots in Christ genuinely growing? Where are they still shallow?",
                arrow: "What specific truth about God am I choosing to stand on today that cannot be shaken by circumstances?"),

            DayData(week: 2, theme: "The Full Armor", scripture: "Ephesians 6:13-17",
                devotional: "Every piece of armor Paul names is defensive — except one. The sword of the Spirit, the Word of God, is the only offensive weapon. You can't absorb attacks indefinitely. At some point you fight back with truth. But notice what comes before the sword: the belt of truth — integrity, living what you say you believe. The breastplate of righteousness — right living that protects your heart. The shoes of the gospel — readiness, knowing what you stand on. The shield of faith — extinguishing every flaming lie. The helmet of salvation — protecting how you think about yourself and your future. Which piece are you currently missing? The vulnerable man is almost always the one who's left something off — not through dramatic sin, but through quiet, steady neglect.",
                anchor: "Which piece of the armor am I most neglecting right now — truth, righteousness, gospel-readiness, faith, my security in salvation, or the Word?",
                arrow: "How will I wield the sword of the Spirit — the Word — against one specific lie or temptation today?"),

            DayData(week: 2, theme: "Faith Over Fear", scripture: "Hebrews 11:1",
                devotional: "Faith is not the absence of uncertainty. It's the confidence to move forward when you can't see the full path. The Hebrews 11 hall of faith is full of men and women who acted before they had proof. Noah built a boat before it rained. Abraham left before he knew where he was going. They didn't have all the answers — what they had was a God they trusted enough to move. Fear says: wait for certainty. Faith says: move with what you know. Most men aren't paralyzed by dramatic fears. They're paralyzed by manageable ones — the fear of looking foolish, failing as a husband or father, not being enough. Faith doesn't say those fears aren't real. It says: I trust God more than I trust my fear.",
                anchor: "What fear is actively competing with my faith right now? Name it specifically.",
                arrow: "What one step of obedience will I take today in the area where fear has been keeping me passive?"),

            DayData(week: 2, theme: "Tested Faith", scripture: "James 1:3",
                devotional: "James doesn't say if your faith is tested — he says when. The testing of your faith produces steadfastness. The word for \"testing\" here is the same used for assaying metal — it's the process that reveals what's real. You don't know what your faith is made of until it's under pressure. A man who has only believed in comfortable circumstances doesn't yet know how deep his roots go. But a man who has gone through the furnace and come out still believing — that man has something. Not because he was tougher, but because God was faithful. The trial you're in right now is not God abandoning you. It may be exactly the process through which He is building what cannot be built any other way.",
                anchor: "How is God using a current trial or difficulty to strengthen my faith? What is He building in me through it?",
                arrow: "How will I respond to today's difficulty with gratitude instead of grumbling — even if it's just one small choice?"),

            DayData(week: 2, theme: "Anchored in Truth", scripture: "John 17:17",
                devotional: "In the hours before His crucifixion, with everything bearing down on Him, Jesus prays for His men. And what He prays is this: sanctify them in the truth; Your Word is truth. Not through feelings. Not through experiences. Through truth. We live in a world that says truth is personal and subjective. But Jesus says God's Word is truth — not one perspective among many. When your feelings lie to you (and they will), when circumstances look hopeless (and they will), what do you stand on? The anchored man has an answer ready: not what I feel, but what God says. Find a verse this week that speaks directly to your current struggle and memorize it. Don't just read it — anchor to it.",
                anchor: "What does God's Word actually say about my current struggle, fear, or temptation? Have I looked?",
                arrow: "Choose one verse that speaks to where you are right now. Write it on something. Carry it with you today."),

            DayData(week: 2, theme: "Stand Against Drift", scripture: "Hebrews 2:1",
                devotional: "\"We must pay much closer attention to what we have heard, lest we drift away from it.\" Drift is the quiet enemy. It doesn't require a decision. You don't decide to drift — you drift when you stop deciding. The current is always moving. Culture, comfort, busyness, distraction — they all pull. You have to actively paddle to stay on course. The word \"drift\" here was used for a ring slipping off a finger — slow, almost unnoticeable, until it's gone. What was the last thing God told you to do that you haven't done? What conviction have you slowly made peace with? Drift doesn't announce itself. It just gradually replaces what once mattered with what's comfortable.",
                anchor: "What small drifts have accumulated in my life recently — in my faith, integrity, relationships, or habits?",
                arrow: "Name one specific drift and take one concrete step back toward center today. Tell a brother what it is."),

            DayData(week: 2, theme: "Week 2 Review", scripture: "Psalm 46:1-3",
                devotional: "\"God is our refuge and strength, a very present help in trouble. Therefore we will not fear.\" Notice the logic: God's presence is the reason for courage — not our strength, not our track record, not our plans. His presence. The psalmist wrote this knowing the earth gives way, mountains fall into the sea. It's not that bad things don't happen — it's that God is present in them. Week 2 was about standing firm. Where did you hold this week? Where did you fold? A man who can be honest about where he folded — not wallowing in shame, but in honest self-assessment — is a man who can grow. Don't let this week pass without naming one place God proved Himself your anchor in a storm.",
                anchor: "How is God proving Himself a refuge and anchor in the storms of my current season?",
                arrow: "Find another man who is in a hard season right now. Reach out and encourage him specifically — not generically."),

            // MARK: Week 3 — Act Like Men / Be Strong

            DayData(week: 3, theme: "Courageous Action", scripture: "Joshua 1:9",
                devotional: "God told Joshua to be strong and courageous three times in nine verses. That tells you something: courage doesn't come naturally when facing what Joshua was walking into. He was leading a million people into fortified cities with fierce armies, following a legend named Moses. The pressure was enormous. And God's answer wasn't a military briefing — it was: \"Have I not commanded you? Be strong and courageous. Do not be frightened or dismayed, for the LORD your God is with you wherever you go.\" The presence of God doesn't remove the difficulty. It removes the excuse for paralysis. What has God been calling you to do that you've been standing at the edge of, looking in, but not stepping forward?",
                anchor: "Where am I being passive right now that God is clearly calling me to act — at home, at work, in a relationship, or in my faith?",
                arrow: "Take one courageous action today that costs you something — comfort, pride, time, or reputation."),

            DayData(week: 3, theme: "Strength in Weakness", scripture: "2 Corinthians 12:10",
                devotional: "Paul had a thorn. He doesn't tell us exactly what it was — maybe intentionally, so every man can fill in the blank with his own. Three times he begged God to take it away. And God said no. Not because He didn't care, but because \"My grace is sufficient for you, for my power is made perfect in weakness.\" The strongest things Paul ever wrote came out of his greatest weakness. The most anchored men you know are almost always men who've been broken somewhere — not men who've never struggled, but men who struggled and discovered that God was enough in the struggle. Your weakness is not disqualifying. In God's economy, it may be your greatest asset.",
                anchor: "Where am I striving in my own strength right now and running dry? What would it look like to stop striving and start trusting?",
                arrow: "Confess one specific weakness to God today — out loud — and ask Him to be strong in that exact place."),

            DayData(week: 3, theme: "Lead Well", scripture: "Ephesians 5:25-26",
                devotional: "\"Husbands, love your wives as Christ loved the church and gave himself up for her.\" The standard isn't cultural — it's the cross. Christ's leadership was servant leadership taken to its ultimate expression: total self-giving for the good of those He led. He didn't lead from comfort and safety. He led toward what was hard and costly because it was what His people needed. Every man in a position of leadership — as husband, father, employer, teammate, or friend — is asked the same question daily: are you leading for your own benefit, or for theirs? Servant leadership is the most masculine form of leadership there is. Not because it's soft — because it costs the most.",
                anchor: "Am I leading the people in my care through genuine love and sacrifice, or through control, distance, or convenience?",
                arrow: "Do one concrete act of servant leadership today at home or at work — something that costs you and benefits someone else."),

            DayData(week: 3, theme: "Speak Truth", scripture: "Proverbs 27:5",
                devotional: "\"Better is open rebuke than hidden love.\" Solomon says the most loving thing you can do for a man is tell him the truth. Hidden love — love that says nothing, agrees with everything, never pushes back — is not love at all. It's your own comfort dressed up as care for them. Iron sharpens iron, but iron only sharpens iron when they actually make contact — when there's friction. A culture of men who only affirm and never challenge produces men who stay soft. Real brotherhood requires the hard conversation, the honest word, the \"brother, I see something in you that I need to name.\" It will cost you comfort. It may cost you temporarily. But it is love, and it's what men who want to grow actually need.",
                anchor: "Am I keeping the peace or actually building it? What hard truth am I withholding from someone who needs to hear it?",
                arrow: "Have one honest conversation you've been avoiding. Speak the truth in love — not to wound, but because you genuinely care."),

            DayData(week: 3, theme: "Provision", scripture: "1 Timothy 5:8",
                devotional: "\"But if anyone does not provide for his relatives, and especially for members of his household, he has denied the faith and is worse than an unbeliever.\" This is one of the strongest statements in the New Testament about masculine responsibility. Provision isn't just financial — though it includes that. It's presence. Emotional engagement. Spiritual covering. Protection. Leadership. The man who provides financially but is emotionally absent is only doing part of the job. The man who is loving and present but abdicates financial responsibility is also falling short. Biblical provision is comprehensive. It asks: who has God put in my care, and am I faithfully covering every dimension of what they need from me? Not perfectly — faithfully.",
                anchor: "Am I faithfully stewarding every dimension of my responsibilities — financially, emotionally, spiritually, and in terms of presence?",
                arrow: "Identify one area of provision — financial, emotional, or spiritual — where you've been falling short. Take one concrete step in it today."),

            DayData(week: 3, theme: "Protect the Weak", scripture: "Proverbs 31:8-9",
                devotional: "\"Speak up for those who cannot speak for themselves; ensure justice for those being crushed.\" This was instruction to a king — but it's a principle for every man with influence. One of the marks of godly masculinity throughout Scripture is advocacy: standing up for those without voice, power, or platform. Where are you in proximity to injustice, need, or vulnerability right now? The man of God doesn't look away. He doesn't say \"that's not my problem.\" He moves toward the need. This isn't just social activism — it's the image of God. God consistently in Scripture moves toward the orphan, the widow, the alien, the marginalized. Men made in His image do the same.",
                anchor: "Who in my immediate circle — family, workplace, neighborhood, church — needs an advocate, a protector, or someone to simply show up for them?",
                arrow: "Speak up for or actively serve someone today who cannot return the favor. Do it without anyone knowing."),

            DayData(week: 3, theme: "Week 3 Review", scripture: "Micah 6:8",
                devotional: "Three commands. Do justice. Love mercy. Walk humbly with your God. Micah cut through all the religious noise of his day and said: this is what God actually wants from you. Not more ritual. Not more impressive religion. Justice — treating people right, advocating for the vulnerable. Mercy — extending grace instead of giving people what they deserve. Humility — walking with God, not ahead of Him or behind Him, but with Him, step by step, dependent on Him for every breath. Which of the three is your weakest? Most men default to justice and struggle with mercy, or lean on mercy and avoid the hard work of justice. The goal is all three, in balance, continuously — not as performance, but as posture.",
                anchor: "Of justice, mercy, and humility — which am I weakest in right now? What does growth in that area actually look like for me?",
                arrow: "Serve anonymously today — do something genuinely good that no one will see and you will get no credit for."),

            // MARK: Week 4 — Let All Be Done in Love

            DayData(week: 4, theme: "Love as Foundation", scripture: "1 Corinthians 13:1-3",
                devotional: "You can preach like an angel, give everything you own, die a martyr's death — and if love isn't the engine, it profits you nothing. Paul isn't being poetic. He's being surgical. He's cutting through every impressive external achievement and asking: what's underneath? A man can look incredibly spiritual and still be fundamentally operating out of ego, fear, or performance. Love is patient. Love is kind. Love does not boast. Love is not proud. Read that list and ask honestly: which of those descriptions actually fits me right now? Not as condemnation — as a compass. Love is not a feeling. It's a direction. It's a consistent orientation toward the good of another, regardless of what it costs you.",
                anchor: "What good things am I currently doing that are actually driven by ego, performance, or fear rather than genuine love?",
                arrow: "Do one thing today purely from love, expecting absolutely nothing in return — no recognition, no reciprocation."),

            DayData(week: 4, theme: "Sacrificial Love", scripture: "John 15:13",
                devotional: "\"Greater love has no one than this: to lay down one's life for one's friends.\" The greatest love is measured by what it costs — not by how it feels or how romantic it is. By what it sacrifices. Jesus modeled this not just at the cross but in every conversation: He gave His attention, time, energy, and truth, even when it was costly to do so. Laying down your life isn't always dramatic. It's the father who comes home exhausted and still gets on the floor with his kids. It's the husband who listens when he wants to check out. It's the friend who makes the call he'd rather not make. Every day you're given opportunities to choose someone else's flourishing over your own comfort. That's where love is built — in the small sacrifices, not just the big ones.",
                anchor: "Where is God calling me to lay something down — comfort, time, preference, or pride — for the genuine good of someone else?",
                arrow: "Sacrifice your preference for someone else's flourishing today in one specific, concrete way."),

            DayData(week: 4, theme: "Love Your Neighbor", scripture: "Luke 10:36-37",
                devotional: "Jesus told a story about a man beaten on the road. Two religious people crossed to the other side to avoid him. Then a Samaritan — from the most despised group in that culture — stopped, helped, paid, and followed up. Then Jesus asked: which of these three was a neighbor? The answer was obvious. Your neighbor isn't defined by geography or culture or existing relationship. It's defined by proximity to need and your capacity to meet it. Who are you in proximity to who has a need you have the ability to address? Most men don't walk past people out of cruelty — they walk past out of busyness, discomfort, or simply not looking up. Today, look up. See someone. Stop.",
                anchor: "Who am I walking past right now — not out of cruelty but out of distraction or discomfort? Who have I been overlooking?",
                arrow: "Take one concrete act of love toward someone outside your usual circle of people today."),

            DayData(week: 4, theme: "Forgiveness", scripture: "Colossians 3:13",
                devotional: "\"Forgive as the Lord forgave you.\" The standard is the cross. You don't forgive because the person deserves it. You don't forgive because you feel like it. You forgive because you have been forgiven an unpayable debt. Unforgiveness is one of the most corrosive forces in a man's life. It doesn't hurt the person who wronged you nearly as much as it hurts you. It pollutes relationships, shapes how you see everything, and keeps you anchored to the past when God is trying to move you into the future. Forgiveness doesn't mean what happened was okay. It doesn't mean there are no consequences. It means you're releasing the debt to God and refusing to carry it anymore. Who do you need to forgive today?",
                anchor: "Is there an unresolved offense or bitterness I'm holding onto that is limiting my freedom and affecting how I live?",
                arrow: "Take one step toward forgiveness today — write it out, pray it out loud, or if appropriate, speak it to the person. Do not let this day pass without movement."),

            DayData(week: 4, theme: "Love in Community", scripture: "Hebrews 10:24-25",
                devotional: "\"Let us consider how to stir up one another to love and good works, not neglecting to meet together.\" The word \"stir up\" means to provoke, to sharpen, to agitate — community isn't just comfort, it's steel against steel. God designed you for this. Not to be a lone wolf, not to have surface-level \"how's it going, good\" relationships with the men around you, but to be truly known, truly challenged, and truly loved by brothers going the same direction. Isolation is the enemy of growth. The enemy knows this too — which is why his strategy is almost always to get you alone first. If you are isolated right now — by choice or by circumstance — that needs to change. Not next month. Now.",
                anchor: "Am I truly known by other men right now? Or am I presenting a managed version of myself while quietly isolating?",
                arrow: "Reach out to one man today for a real conversation — not surface level. Tell him something true about where you actually are."),

            DayData(week: 4, theme: "Love Covers", scripture: "1 Peter 4:8",
                devotional: "\"Above all, keep loving one another earnestly, since love covers a multitude of sins.\" To cover a sin is not to excuse it, minimize it, or pretend it didn't happen. It means you absorb the cost rather than broadcasting the offense. Gossip is the opposite of love — it takes someone's failure and multiplies the damage by spreading it. The man who loves covers. He confronts privately. He protects reputation where possible. He absorbs offense instead of amplifying it. Think honestly about how you talk about people when they're not present. Do your words build or erode? Do you speak life or tear down? The truest test of your love for someone is what you say about them when they're not in the room.",
                anchor: "How do I talk about others when they're not present? Am I a man who builds reputation or tears it down?",
                arrow: "Speak life about someone you've been criticizing — to their face, or to others who've heard you criticize them."),

            DayData(week: 4, theme: "Week 4 Review", scripture: "1 John 4:19",
                devotional: "\"We love because He first loved us.\" Everything comes back to this. You didn't earn God's love. You can't lose it. It preceded you. He loved you while you were still walking away from Him. The entire Christian life is a response to love that came to you — not love you generated. When you feel cold, distant, spiritually dry — you don't need to generate more love. You need to return to the source. Spend time today not trying to perform or produce, but simply receiving. Read back through the passages of this month. Where did you feel most loved by God? Where did you feel most like yourself in relation to Him? Report to your brothers. You don't have to have it all figured out. That's what community is for.",
                anchor: "How has \"we love because He first loved us\" actually changed how I live — toward God, toward my family, toward other men?",
                arrow: "Write a message of genuine encouragement to a man who sharpened you this month. Tell him specifically what he did and what it meant."),

            // MARK: Days 29-30 — Completion

            DayData(week: 4, theme: "Integration Day", scripture: "Romans 8:37-39",
                devotional: "\"In all these things we are more than conquerors through him who loved us.\" Not in spite of them — in them. In the hardship, the grief, the failure, the weakness, the spiritual dryness, the relational difficulty. In all of it. Paul's list in Romans 8 of what cannot separate you from God's love reads like a complete inventory of your worst fears: death, life, angels, demons, present circumstances, future unknowns, powers beyond your control, heights, depths, anything in all of creation. None of it. You are not holding on to God. God is holding on to you. You came into this 30 days as one man. You are leaving it as another — not because of what you achieved, but because of what God did in you. Name it. Say it out loud.",
                anchor: "How has God met me in this 30-day journey? What is different in me now than when I started?",
                arrow: "Share your biggest takeaway from this journey with your circle or a trusted brother today. Do not keep it to yourself."),

            DayData(week: 4, theme: "Stand Firm — Always", scripture: "1 Corinthians 16:13-14",
                devotional: "Here it is again — the verse that started everything. Be watchful. Stand firm in the faith. Act like men. Be strong. Let all that you do be done in love. These are not commands to be completed once. They are the posture of a man who has decided who he is. A man who is anchored doesn't drift because he knows what he's anchored to. A man who is purposeful doesn't wander because he knows what he's aiming at. You were made for this — designed for courage, faithfulness, and strength in love. Not perfect. Faithful. Not without failures. Without quitting. This is not the end of a 30-day program. It is the beginning of the rest of your life as a man who stands firm. The best thing you can do with what you've received is give it away. Go sharpen another man.",
                anchor: "What is my one-sentence commitment going forward as an anchored, purposeful man? Write it. Say it out loud. Mean it.",
                arrow: "Set one new goal. Plan to restart the journey. And identify one man you will invest in — invite him to start this journey with you."),
        ]

        return data.enumerated().map { index, item in
            JourneyDay(
                id: index + 1,
                week: item.week,
                theme: item.theme,
                scripture: item.scripture,
                devotional: item.devotional,
                anchorPrompt: item.anchor,
                arrowPrompt: item.arrow,
                isUnlocked: index == 0,
                completedDate: nil
            )
        }
    }

    // MARK: - Armor of God Journey (30 Days in Ephesians 6)
    private static func armorOfGodJourneyDays() -> [JourneyDay] {
        struct DayData {
            let week: Int
            let theme: String
            let scripture: String
            let devotional: String
            let anchor: String
            let arrow: String
        }

        let data: [DayData] = [

            // MARK: Week 1 — The Belt of Truth & Breastplate of Righteousness

            DayData(week: 1, theme: "Be Strong in the Lord", scripture: "Ephesians 6:10",
                devotional: "Before Paul names a single piece of armor, he gives the foundation: be strong in the Lord and in the strength of His might. Not your might. His. Every man who has tried to white-knuckle his way through temptation, discipline his way out of sin, or hustle his way to spiritual maturity has discovered the same thing — it doesn't hold. Your strength has a ceiling. God's doesn't. The phrase 'be strong' is passive in Greek — it means 'be strengthened,' let yourself be empowered. You don't generate this. You receive it. The man who walks in God's strength isn't the one trying harder. He's the one who has stopped trying to do it alone and started depending on the One who already won the battle.",
                anchor: "Where am I relying on my own strength instead of God's? What would it look like to actually depend on Him today?",
                arrow: "Identify one area where you've been striving in your own power. Consciously surrender it to God's strength before you act today."),

            DayData(week: 1, theme: "The Schemes of the Devil", scripture: "Ephesians 6:11",
                devotional: "Paul doesn't say the devil attacks with brute force. He says 'schemes' — methodeia in Greek, from which we get 'method.' The enemy has a method. He studies you. He knows your patterns, your weak spots, the time of day you're most vulnerable, the emotion that makes you most reckless. He's not creative — he doesn't need to be. He just runs the same play over and over because it keeps working. The scheme against the angry man is provocation. The scheme against the lonely man is counterfeit intimacy. The scheme against the successful man is self-sufficiency. The scheme against the discouraged man is despair. What's the play he keeps running against you? Until you name it, you can't defend against it. The full armor of God isn't optional equipment — it's the only thing that stands against a strategic enemy.",
                anchor: "What pattern does the enemy keep exploiting in my life? What is the scheme I keep falling for?",
                arrow: "Write down the enemy's most effective play against you. Then write down the specific truth from God's Word that counters it."),

            DayData(week: 1, theme: "The Real Battle", scripture: "Ephesians 6:12",
                devotional: "We do not wrestle against flesh and blood. Every man needs to hear this and actually believe it. Your wife is not your enemy. Your boss is not your enemy. The culture is not your enemy. There is a real, personal, spiritual adversary behind the things that tear at your marriage, your integrity, your faith, and your peace. This doesn't mean people don't sin against you — they do. But behind the human conflict is often a spiritual one. When you fight flesh and blood, you use flesh-and-blood weapons: anger, control, manipulation, withdrawal. When you fight spiritual battles with spiritual weapons, everything changes. You pray instead of rage. You speak truth instead of attacking. You stand firm instead of retaliating. The man who understands Ephesians 6:12 fights differently — and he wins differently.",
                anchor: "Where am I fighting flesh and blood when the real battle is spiritual? Who have I been treating as the enemy who isn't?",
                arrow: "Before reacting to any conflict today, pause and ask: is this a flesh-and-blood issue or a spiritual one? Respond accordingly."),

            DayData(week: 1, theme: "The Belt of Truth", scripture: "Ephesians 6:14a",
                devotional: "The belt was the first piece of armor a Roman soldier put on. Everything else attached to it. Without it, nothing held together. Paul says truth is your belt — the foundational piece that holds everything else in place. But truth here isn't just theological knowledge. It's integrity — living the same in private as in public. The belt of truth means you're not hiding anything. You're not performing a version of yourself for the world while living another version behind closed doors. Deception is the enemy's native language. Every stronghold in your life started with a lie you believed or a truth you refused to tell. When a man walks in truth — about who God is, who he is, and what's really going on in his heart — the enemy loses his primary weapon.",
                anchor: "Where am I living with a gap between my public self and my private self? What truth am I avoiding?",
                arrow: "Tell one person one true thing about where you actually are today — spiritually, emotionally, or relationally. No filter."),

            DayData(week: 1, theme: "Truth Sets Free", scripture: "John 8:32",
                devotional: "Jesus said the truth will set you free. Not comfort. Not avoidance. Not denial. Truth. Most men are imprisoned by things they refuse to name. The addiction you won't call an addiction. The marriage issue you keep hoping will fix itself. The bitterness you've relabeled as 'boundaries.' The fear you've disguised as wisdom. Freedom doesn't begin with victory — it begins with honesty. The moment you say 'this is what's really happening' is the moment the chains start to loosen. Not because confession is magic, but because deception is the lock, and truth is the key. You cannot be set free from something you won't acknowledge. What have you been calling by the wrong name?",
                anchor: "What am I calling by the wrong name in my life right now? What truth am I softening to make it easier to live with?",
                arrow: "Name the thing you've been avoiding with its real name — in your journal, to God, or to a trusted brother. Start the freedom process today."),

            DayData(week: 1, theme: "The Breastplate of Righteousness", scripture: "Ephesians 6:14b",
                devotional: "The breastplate protected the heart and vital organs. Paul says righteousness is your breastplate. This is both positional — you are declared righteous through Christ — and practical — you live in a way that guards your heart. A man with no breastplate is a man whose heart is exposed. And an exposed heart gets pierced. Practical righteousness isn't about perfection. It's about alignment — living in step with what you know to be true. Every compromise leaves a crack in the breastplate. Every 'just this once' opens a gap the enemy knows how to exploit. The righteous man isn't the one who never fails. He's the one who refuses to stay down, who repents quickly, who doesn't let yesterday's failure become today's identity. Guard your heart by guarding your choices.",
                anchor: "Where is there a crack in my breastplate — a compromise I've made peace with that's leaving my heart exposed?",
                arrow: "Close one gap today. One area where you know you've been compromising — make the right choice before the temptation comes, not during it."),

            DayData(week: 1, theme: "Week 1 Review", scripture: "Psalm 51:6",
                devotional: "God desires truth in the inward parts. Not external performance. Not polished answers. Truth — the deep, uncomfortable, no-one-is-watching kind. Week 1 was about the foundation: truth and righteousness. The belt that holds everything together and the breastplate that guards your heart. Without these two, nothing else in the armor matters. A man who lies to himself can't fight effectively. A man whose heart is unguarded will take hits that should have been blocked. So here's the honest review: Did you name your enemy's scheme? Did you close a gap in your integrity? Did you tell someone the truth about where you are? If you did — good. Build on it. If you didn't — don't waste time in guilt. Start now. Today is the day.",
                anchor: "What did God reveal this week about my relationship with truth and integrity? Where did I grow? Where did I resist?",
                arrow: "Share one honest insight from this week with a brother. Not a polished summary — the real takeaway."),

            // MARK: Week 2 — Shoes of the Gospel & Shield of Faith

            DayData(week: 2, theme: "Feet Fitted with Readiness", scripture: "Ephesians 6:15",
                devotional: "Roman soldiers wore caligae — heavy sandals studded with nails for grip on any terrain. Paul says your feet should be fitted with the readiness that comes from the gospel of peace. Readiness. Not reaction — readiness. The gospel-ready man doesn't wait for the perfect moment to share his faith, serve his neighbor, or step into hard ground. He's already prepared. His footing is sure because he knows what he stands on. Peace here isn't passive — it's the settled confidence of a man who knows the war is already won. He walks into hostile territory not because he's reckless but because the ground beneath his feet is the finished work of Christ. Where are you hesitating to step because the terrain looks too rough?",
                anchor: "Where is God calling me to step forward that I've been avoiding because the ground feels uncertain?",
                arrow: "Take one step today onto difficult ground — a hard conversation, a new commitment, an act of service — with the confidence that the gospel gives you footing."),

            DayData(week: 2, theme: "The Gospel of Peace", scripture: "Romans 10:15",
                devotional: "How beautiful are the feet of those who bring good news. In a world drowning in bad news, anxiety, and division, you carry the only message that actually solves the problem at the root. Not a political solution. Not a self-help framework. The gospel — that God loved the world so much He entered it, lived in it, died in it, and defeated death in it. Every man you meet today is either at peace with God or at war with Him, and most don't even know which one they are. You do. That knowledge is not for hoarding — it's for delivering. You don't have to be a preacher. You have to be available. The man next to you at work, the friend who's falling apart, the family member who's searching — they need what you carry. Are your feet fitted, or are they planted in comfort?",
                anchor: "Who in my life needs the peace of the gospel, and what is keeping me from bringing it to them?",
                arrow: "Identify one person in your life who is far from God. Pray for them by name, and look for one opportunity to point them toward hope today."),

            DayData(week: 2, theme: "The Shield of Faith", scripture: "Ephesians 6:16",
                devotional: "The Roman scutum was a full-body shield, large enough to crouch behind. Paul says faith is your shield — and it extinguishes all the flaming arrows of the evil one. All of them. Not some. All. But notice: the shield works only when you hold it up. Faith isn't a concept you agree with — it's an active posture you take. The flaming arrows are the lies, doubts, accusations, and temptations the enemy launches at your mind. 'You'll never change.' 'God is disappointed in you.' 'This sin defines you.' 'You're alone in this.' Every single one of those is a lie, and faith — active, deliberate trust in what God says over what you feel — extinguishes them. The question isn't whether the arrows will come. The question is whether your shield is up.",
                anchor: "What flaming arrow has hit me recently — what lie, doubt, or accusation have I been absorbing instead of blocking?",
                arrow: "Write down the specific lie the enemy has been firing at you. Next to it, write the truth from Scripture that extinguishes it. Carry both with you today."),

            DayData(week: 2, theme: "Walking by Faith", scripture: "2 Corinthians 5:7",
                devotional: "We walk by faith, not by sight. This is one of the hardest commands in Scripture because everything in your natural wiring screams for evidence, proof, guarantees. You want to see the outcome before you commit. You want certainty before you obey. But faith by definition operates beyond sight. Abraham left Ur without a map. Moses walked toward a sea that hadn't parted yet. David ran toward a giant everyone else was running from. None of them had guarantees — they had God's word, and they acted on it. What decision are you facing right now where God has spoken but you're waiting for more evidence? Faith doesn't mean you're certain about the outcome. It means you're certain about the One who called you to walk.",
                anchor: "Where am I demanding sight when God is asking for faith? What step is He calling me to take that I can't yet see the end of?",
                arrow: "Take one faith step today — not reckless, but deliberate — in an area where you've been waiting for certainty that may never come."),

            DayData(week: 2, theme: "Faith Under Fire", scripture: "1 Peter 1:7",
                devotional: "Your faith is being tested by fire so that it may be found genuine — more precious than gold. Gold is refined by heat. Impurities rise to the surface and are removed. The process is uncomfortable, but the result is pure. Your faith works the same way. The trials you're going through aren't evidence that God has abandoned you. They're evidence that He's refining you. A faith that has never been tested is a faith you can't rely on. But a faith that has gone through the fire and come out still standing — still believing, still trusting, still choosing God over circumstance — that faith is unshakeable. The men in Scripture who changed the world were all men whose faith had been through fire. Yours is no different. What feels like destruction may actually be purification.",
                anchor: "How is my faith being refined right now? What impurities is God burning away through my current circumstances?",
                arrow: "Instead of asking God to remove your trial today, ask Him what He is building in you through it. Write down what you hear."),

            DayData(week: 2, theme: "Community of Faith", scripture: "Hebrews 10:24-25",
                devotional: "Let us consider how to stir up one another to love and good works, not neglecting to meet together. Your shield is big — but it wasn't designed for solo use. Roman soldiers locked their shields together in a formation called the testudo, creating an impenetrable wall. Your faith is stronger when it's linked with other men's faith. Isolation is the enemy's primary strategy. He doesn't need to overpower you if he can just get you alone. The man fighting by himself will eventually get hit from an angle his shield can't cover. But the man standing in formation — shoulder to shoulder with brothers — has coverage on every side. If you are isolated right now, that is your number one vulnerability. Fix it before you try to fix anything else.",
                anchor: "Am I fighting in formation or fighting alone? Where do I need to lock shields with another man?",
                arrow: "Reach out to one brother today and tell him where you're taking fire. Ask him to stand with you. That's not weakness — it's warfare."),

            DayData(week: 2, theme: "Week 2 Review", scripture: "Hebrews 11:6",
                devotional: "Without faith it is impossible to please God, because anyone who comes to Him must believe that He exists and that He rewards those who earnestly seek Him. Faith is the operating system of the Christian life. Without it, nothing else works. You can't pray without faith. You can't obey without faith. You can't love sacrificially without believing there's something greater on the other side of the sacrifice. This week you've looked at readiness, the gospel of peace, the shield that blocks every arrow, and the fire that refines what's real. Where did your faith grow this week? Where did it waver? Don't judge yourself — assess honestly. A man who knows where his faith is strong and where it's weak is a man who can actually grow. Report in. Tell a brother. Keep building.",
                anchor: "Where did my faith hold firm this week, and where did it crack? What did I learn about trusting God in the process?",
                arrow: "Identify one area where your faith grew this week and one where it faltered. Share both with someone who will hold you accountable."),

            // MARK: Week 3 — Helmet of Salvation & Sword of the Spirit

            DayData(week: 3, theme: "The Helmet of Salvation", scripture: "Ephesians 6:17a",
                devotional: "The helmet protects the head — the mind. Paul says salvation is your helmet. This isn't just about being saved from hell. It's about knowing whose you are and letting that truth protect how you think about yourself, your future, and your worth. The enemy's most effective attacks target your identity. 'You're a failure.' 'You'll never be free.' 'God could never use you after what you've done.' Every one of those is an attack on your helmet — an attempt to make you forget that you are saved, redeemed, adopted, and sealed. When your helmet is on, those attacks bounce off. When it's off, they penetrate and shape your self-image. Put your helmet on today by declaring who God says you are — not who your failures say you are.",
                anchor: "What lies about my identity have I been absorbing because my helmet was off? What does God actually say about who I am?",
                arrow: "Write down three truths about your identity in Christ. Read them out loud. Repeat them until they feel more real than the lies."),

            DayData(week: 3, theme: "Renewing the Mind", scripture: "Romans 12:2",
                devotional: "Do not be conformed to this world, but be transformed by the renewal of your mind. Transformation doesn't start with behavior change — it starts with mind change. Your actions flow from your thoughts. Your thoughts are shaped by what you consume. If you're consuming the world's narrative about masculinity, success, sexuality, and purpose, you'll think like the world and live like the world. If you're consuming God's Word, you'll think differently — and eventually live differently. Renewal isn't passive. You don't accidentally renew your mind. It requires intention: choosing what enters, evaluating what stays, and replacing what's false. Most men try to change their behavior without changing their thinking. It never lasts. Change the inputs. The outputs will follow.",
                anchor: "What am I consuming that is shaping my mind more than God's Word? What needs to change in my inputs?",
                arrow: "Replace one daily input today — one scroll session, one show, one habit — with time in Scripture. Even fifteen minutes changes the trajectory."),

            DayData(week: 3, theme: "The Sword of the Spirit", scripture: "Ephesians 6:17b",
                devotional: "The sword of the Spirit is the Word of God — the only offensive weapon in the armor. Everything else is defensive. This tells you something critical: the Word isn't just for study. It's for combat. When Jesus was tempted in the wilderness, He didn't debate the devil. He didn't try to out-argue him. He quoted Scripture. 'It is written.' Three times. Three specific, precise, relevant truths deployed against three specific attacks. That's how the sword works — not as a blunt instrument, but as a precision weapon. Knowing 'the Bible says some stuff about that' isn't enough. You need to know which verse answers which lie, which promise meets which fear, which truth counters which temptation. Sharpen your sword. Know it well enough to use it in the fight.",
                anchor: "Do I know God's Word well enough to use it in battle, or is my sword dull from neglect?",
                arrow: "Memorize one verse today that directly addresses your most common temptation or struggle. Not just read it — memorize it. It's a weapon."),

            DayData(week: 3, theme: "The Word in Action", scripture: "Hebrews 4:12",
                devotional: "The Word of God is living and active, sharper than any two-edged sword, piercing to the division of soul and spirit, of joints and marrow, and discerning the thoughts and intentions of the heart. This verse tells you three things about your weapon. First, it's alive — not a dead religious text but a living document that speaks into your specific situation. Second, it's precise — it cuts to the exact place that needs cutting, separating what's genuinely from God and what's from your flesh. Third, it sees you — it discerns your real motives, the ones you hide even from yourself. When you open the Bible honestly, it reads you as much as you read it. That's why some men avoid it — because the sword cuts both ways. But the cuts it makes are surgical, not destructive. They heal.",
                anchor: "When was the last time God's Word cut me — revealed something I was hiding or showed me a motive I didn't want to see?",
                arrow: "Open Scripture today not for information but for examination. Ask God: 'What do You want to show me about myself?' and read until He does."),

            DayData(week: 3, theme: "Speaking Truth in Battle", scripture: "Matthew 4:4",
                devotional: "Man shall not live by bread alone, but by every word that comes from the mouth of God. Jesus spoke this when He was physically starving, at His weakest, being tempted at His most vulnerable. The enemy came at Him with something reasonable: 'You're hungry. You have the power to fix it. Why wouldn't You?' And Jesus didn't argue the logic. He wielded the sword. 'It is written.' This is how you fight. Not by debating whether the temptation makes sense — it often does. Not by evaluating whether the shortcut is really that bad — sometimes it isn't. But by declaring what God says is true regardless of how the situation feels. The enemy can't argue with Scripture wielded by a man who believes it. He has to flee. Jesus proved it. You can too.",
                anchor: "When temptation comes with a reasonable argument, do I debate it or cut it with truth? What's my default response?",
                arrow: "Practice the Jesus pattern today: when a temptation or lie arises, respond out loud with 'It is written...' and quote the specific truth."),

            DayData(week: 3, theme: "Guarding Your Thought Life", scripture: "2 Corinthians 10:5",
                devotional: "We take every thought captive to obey Christ. Every thought. Not just the obviously sinful ones. The subtle ones too — the self-pity, the comparison, the entitlement, the rehearsed grievance, the fantasy you keep returning to. Taking thoughts captive is a military image. It means you don't let enemy ideas roam free in your mind. You intercept them. You evaluate them. And if they don't align with Christ, you don't give them a seat at the table. Most men's thought lives are completely unguarded. Thoughts come and go, shaping mood, driving decisions, building resentment or lust or despair — and the man never once stops to examine whether those thoughts are from God, from himself, or from the enemy. Today, stand guard at the gate of your mind. Not every thought deserves residency.",
                anchor: "What thought pattern has been running unchecked in my mind? What would it look like to take it captive today?",
                arrow: "Set three checkpoints today — morning, midday, evening — to examine your thoughts. Ask: what have I been thinking about, and does it honor Christ?"),

            DayData(week: 3, theme: "Week 3 Review", scripture: "Philippians 4:8",
                devotional: "Whatever is true, whatever is honorable, whatever is just, whatever is pure, whatever is lovely, whatever is commendable — think about these things. Paul isn't giving a nice suggestion. He's giving a battle strategy. What you think about determines what you become. Week 3 has been about the mind: the helmet that protects your identity, the sword you wield in battle, the thought life you choose to guard or neglect. This is where most men lose. Not in dramatic moral failures, but in undisciplined thought lives that slowly erode conviction, clarity, and courage. How is your mind right now — renewed or conformed? Sharp or dull? Guarded or wide open? Honest assessment leads to honest growth. Don't perform this review — own it.",
                anchor: "How is the state of my mind after this week? Am I more disciplined in my thinking or still drifting through my thought life?",
                arrow: "Choose one area of your thought life to bring under intentional discipline this week. Tell a brother what it is and ask him to check in."),

            // MARK: Week 4 — Prayer, Perseverance & Standing Together

            DayData(week: 4, theme: "Praying at All Times", scripture: "Ephesians 6:18",
                devotional: "After naming every piece of armor, Paul adds the power source: prayer. Praying at all times in the Spirit, with all prayer and supplication. Notice the intensity — all times, all prayer. This isn't a quick morning prayer and then you're done. This is an ongoing conversation with the Commander who sees the whole battlefield when you can only see your sector. Prayer isn't asking God for things — though it includes that. Prayer is staying connected to the source of your strength, wisdom, and courage. A soldier who loses communication with command is a soldier in danger. Your prayer life is your lifeline. When it goes quiet, you're operating alone — and the enemy knows it. The most armored man in the world is still vulnerable if he's not praying.",
                anchor: "Is my prayer life a lifeline or a formality? What would 'praying at all times' actually look like in my daily routine?",
                arrow: "Set three prayer alarms today — morning, midday, and evening. Even sixty seconds of deliberate, honest prayer three times changes everything."),

            DayData(week: 4, theme: "Perseverance in Prayer", scripture: "Luke 18:1",
                devotional: "Jesus told a parable to show that they should always pray and not give up. The parable is about a widow who keeps coming to an unjust judge until he gives her justice — not because he cares, but because she won't stop. Jesus's point isn't that God is unjust and needs to be nagged. His point is: if even an unjust judge responds to persistence, how much more will a loving Father respond to His children who keep coming? Most men quit praying too early. They pray once, maybe twice, and when nothing visible changes, they assume God said no — or worse, that He's not listening. But perseverance in prayer isn't about wearing God down. It's about building your own faith. Every time you pray again, you're declaring: 'I still trust You.' That declaration matters.",
                anchor: "What prayer have I stopped praying because I got tired of waiting? Does God's silence mean no, or does it mean keep going?",
                arrow: "Resume one prayer you've abandoned. Pray it again today with fresh faith. Don't pray it as a formality — pray it like you believe God is still moving."),

            DayData(week: 4, theme: "Praying for Others", scripture: "Ephesians 6:18b-19",
                devotional: "Keep alert with all perseverance, making supplication for all the saints. Paul doesn't end the armor passage by telling you to pray for yourself. He tells you to pray for your brothers. Your armor isn't just for your survival — it's for the survival of the men fighting alongside you. When was the last time you prayed — really prayed — for another man by name? Not a generic 'bless everyone' prayer, but a specific, targeted prayer for a brother's marriage, his integrity, his faith, his battle? Intercessory prayer is one of the most powerful weapons in your arsenal, and most men never use it. You may never know the impact of praying for a brother at the exact moment he was being tempted, attacked, or discouraged. But God knows. And it matters.",
                anchor: "When was the last time I specifically, intentionally prayed for another man's spiritual battle? Who needs my prayers right now?",
                arrow: "Pray for three men by name today — their specific struggles, not generic blessings. Then text one of them and tell him you prayed."),

            DayData(week: 4, theme: "Standing Firm Together", scripture: "Ecclesiastes 4:12",
                devotional: "A cord of three strands is not easily broken. Solomon knew what every man discovers eventually: you were not designed for isolation. One man can be overpowered. Two can defend each other. Three are nearly unbreakable. This isn't about numbers — it's about genuine, accountable, honest brotherhood. Not surface friendships where you talk about sports and weather. Deep, I-know-your-real-struggles, I-will-call-you-out-in-love, I-will-fight-beside-you-when-it-costs-me relationships. Most men have many acquaintances and almost no brothers. They have men who know their wins but not their wars. Building the kind of relationship Solomon describes requires vulnerability, consistency, and mutual commitment. It's the hardest investment a man can make — and the one that pays the highest return.",
                anchor: "Do I have the kind of brotherhood Solomon describes? If not, what's preventing me from building it?",
                arrow: "Have one real, honest conversation with a man today — not about sports, not about work, but about where you actually are spiritually."),

            DayData(week: 4, theme: "The Battle Belongs to the Lord", scripture: "2 Chronicles 20:15",
                devotional: "Do not be afraid or discouraged because of this vast army. For the battle is not yours, but God's. Jehoshaphat was facing an overwhelming enemy. Three armies were converging on Israel. His response? He didn't strategize first — he prayed. He didn't rally troops first — he worshipped. And God said: 'Position yourselves, stand still, and see the salvation of the Lord.' Sometimes the bravest thing a man can do is stand still. Not because he's passive, but because he's trusting that the battle belongs to someone bigger. You've spent this journey putting on armor, sharpening your sword, strengthening your shield. But never forget: the armor is God's armor. The strength is God's strength. The victory is God's victory. You are invited to participate, not to carry the outcome.",
                anchor: "What battle am I carrying that actually belongs to God? What would it look like to stand still and let Him fight?",
                arrow: "Surrender one outcome you've been trying to control. Say out loud: 'This battle belongs to You, Lord.' Mean it. Rest in it."),

            DayData(week: 4, theme: "Worship as Warfare", scripture: "2 Chronicles 20:21-22",
                devotional: "Jehoshaphat appointed men to sing and praise as they went out before the army. And when they began to sing, the Lord set ambushes against the enemy. Read that again. They won the battle by worshipping. This isn't a prosperity trick or a spiritual hack. It's a profound truth: worship reorients your heart from fear to faith, from self to God, from the size of your problem to the size of your God. The enemy cannot operate effectively in an atmosphere of genuine worship. When you worship in the middle of your battle — not after the victory, but during the fight — you're declaring that God is bigger than what you're facing. That declaration has power. Sing in the storm. Praise in the pressure. Worship before the victory arrives.",
                anchor: "Am I waiting for victory to worship, or am I worshipping as a weapon in the middle of the fight?",
                arrow: "Put on worship music today during your hardest moment — the commute, the temptation window, the anxious hour. Let worship fight for you."),

            DayData(week: 4, theme: "Week 4 Review", scripture: "Ephesians 6:13",
                devotional: "Therefore put on the full armor of God, so that when the day of evil comes, you may be able to stand your ground, and after you have done everything, to stand. 'After you have done everything — stand.' That's the final word. Not advance. Not conquer. Not perform. Stand. There will be days when standing is all you can do — when you're exhausted, when the battle has been brutal, when you feel like you've given everything and you're barely holding on. On those days, standing is enough. God doesn't ask you to win every battle perfectly. He asks you to still be standing when the smoke clears. This whole journey — truth, righteousness, readiness, faith, salvation, the Word, and prayer — is about equipping you to stand. Not in your strength. In His. Stand firm, brother. The battle belongs to the Lord, and He's already won.",
                anchor: "After everything I've learned this month about God's armor, where do I stand? What piece do I need to keep tightening?",
                arrow: "Write your battle plan: which piece of armor needs the most attention going forward? Tell a brother your plan and ask him to hold you to it."),

            // MARK: Days 29-30 — Completion

            DayData(week: 4, theme: "Armored and Anchored", scripture: "Ephesians 6:10-11",
                devotional: "Be strong in the Lord and in the strength of His might. Put on the full armor of God. You started this journey as a man who may have known about the armor of God. You're ending it as a man who has worn it — piece by piece, day by day, battle by battle. The belt of truth that demands integrity. The breastplate of righteousness that guards your heart. The shoes of readiness that give you footing on hard ground. The shield of faith that blocks every lie. The helmet of salvation that protects your identity. The sword of the Spirit that fights with truth. And prayer — the lifeline that connects you to the Commander. This armor isn't something you put on once. It's something you put on every morning for the rest of your life. The man who does that — consistently, humbly, in community — is a man the enemy cannot defeat.",
                anchor: "How has this journey changed the way I understand spiritual battle and my role in it?",
                arrow: "Share your single greatest breakthrough from this 30-day journey with your circle or a trusted brother. Do not keep it to yourself."),

            DayData(week: 4, theme: "Send Another Man Into Battle", scripture: "2 Timothy 2:2",
                devotional: "The things you have heard me say in the presence of many witnesses — entrust to reliable men who will be qualified to teach others. Paul didn't just wear the armor himself. He equipped others to wear it. That's your calling now. You've been through thirty days of truth, refining, and equipping. The question isn't just 'am I ready?' — it's 'who else needs this?' There is a man in your life right now who is fighting without armor. He's exposed, taking hits, wondering why the Christian life feels so hard. He doesn't need another book or podcast. He needs a brother who will walk with him through what you just walked through. The best warriors make more warriors. Don't hoard what God gave you. Deploy it. Sharpen another man. That's the mission.",
                anchor: "Who in my life needs what I've received? What man is fighting without armor that I could help equip?",
                arrow: "Identify one man and invite him to start this journey. Not someday — today. Send the message. Make the call. Extend the invitation."),

        ]

        return data.enumerated().map { index, item in
            JourneyDay(
                id: index + 1,
                week: item.week,
                theme: item.theme,
                scripture: item.scripture,
                devotional: item.devotional,
                anchorPrompt: item.anchor,
                arrowPrompt: item.arrow,
                isUnlocked: index == 0,
                completedDate: nil
            )
        }
    }

    // MARK: - Surrender First Journey (30 Days in Galatians 2:20)
    private static func surrenderFirstJourneyDays() -> [JourneyDay] {
        struct DayData {
            let week: Int
            let theme: String
            let scripture: String
            let devotional: String
            let anchor: String
            let arrow: String
        }

        let data: [DayData] = [

            // MARK: Week 1 — Bow the Knee

            DayData(week: 1, theme: "The Posture of a Man", scripture: "Galatians 2:20",
                devotional: "I have been crucified with Christ. It is no longer I who live, but Christ who lives in me. Most men read that verse and move past it. But Paul isn't being poetic. He's describing what actually happened — and what it costs. The life you were living before Christ? The one driven by your ambition, your reputation, your appetites, your need to be in control? That man died. And the man who rose in his place is fueled by a completely different source. Here's the problem: dead men don't keep getting back up to run the show. But that's exactly what most of us do. We accept Christ's sacrifice in theory, then live practically unchanged — still steering, still strategizing, still performing. Surrender isn't a one-time prayer. It's a daily death. And it's the only place real manhood begins.",
                anchor: "Where am I still living as though I haven't been crucified with Christ — still steering, still controlling, still performing?",
                arrow: "Identify one decision today where you will consciously let Christ lead instead of defaulting to your own plan."),

            DayData(week: 1, theme: "Pride: The First Enemy", scripture: "James 4:6",
                devotional: "God opposes the proud but gives grace to the humble. Read that again slowly. God doesn't just disapprove of pride — He actively opposes it. The Creator of the universe positions Himself against the proud man. And yet pride is so woven into how we operate that we barely notice it. Pride isn't always arrogance. Sometimes it's self-sufficiency — the quiet belief that you can handle life without God's input. Sometimes it's performance — the drive to prove yourself to people who never asked. Sometimes it's control — the refusal to let anyone, including God, tell you what to do. Pride was the first sin in the garden and it's still the root of most of ours. Humility doesn't mean thinking less of yourself. It means thinking of yourself less — and thinking of God accurately. He is God. You are not. And that is the most freeing truth a man can accept.",
                anchor: "Where is pride operating in my life right now — not as arrogance, but as self-sufficiency, performance, or control?",
                arrow: "Do one thing today that your pride would normally prevent — ask for help, admit you were wrong, or let someone else lead."),

            DayData(week: 1, theme: "Letting Go of Control", scripture: "Proverbs 3:5-6",
                devotional: "Trust in the Lord with all your heart, and do not lean on your own understanding. Men are wired to solve, fix, and control. It's not entirely bad — God built you to lead, provide, and protect. But there's a line where healthy leadership becomes white-knuckled control, and most men crossed it a long time ago. You control because you're afraid. Afraid of what happens if you let go. Afraid of looking weak. Afraid that if you stop managing every outcome, everything will fall apart. But here's what Proverbs 3 is really saying: your understanding has limits. Your perspective is partial. Your ability to see around corners is exactly zero. God sees the full picture. He always has. Trusting Him doesn't mean being passive — it means holding your plans with open hands and letting Him redirect when He needs to. The man who surrenders control to God doesn't lose power. He finally finds it.",
                anchor: "What am I gripping so tightly right now that I'm afraid to release to God? Why am I afraid to let go?",
                arrow: "Name one area where you've been overcontrolling — your career, a relationship, a situation — and consciously open your hands to God today."),

            DayData(week: 1, theme: "Come as You Are", scripture: "Romans 5:8",
                devotional: "God demonstrates His own love for us in this: while we were still sinners, Christ died for us. Not after you cleaned up. Not once you had your act together. Not when you finally became the man you thought you should be. While you were still in the mess. This is the scandal of the gospel — it meets you in the dirt. Most men approach God like a job interview. They try to present their best self, highlight their strengths, minimize their failures. But God isn't hiring. He's adopting. And adoption isn't based on your résumé — it's based on His love. Surrender starts here: coming to the cross not with your achievements but with your brokenness. Not with your plans but with your emptiness. The man who comes to God with nothing is the man who receives everything. Stop trying to earn what's already been given.",
                anchor: "Am I approaching God with my performance or with my honest need? What am I hiding from Him that He already sees?",
                arrow: "Spend five minutes in prayer today bringing God your actual state — not your polished version. Tell Him what's really happening."),

            DayData(week: 1, theme: "The Weight You Were Never Meant to Carry", scripture: "Matthew 11:28-30",
                devotional: "Come to me, all who labor and are heavy laden, and I will give you rest. Take my yoke upon you, and learn from me, for I am gentle and lowly in heart. Men carry things they were never meant to carry. The weight of proving yourself. The burden of being enough. The pressure of holding everything together for everyone around you. And the longer you carry it, the more normal it feels — until you can't remember what it was like to live without the weight. Jesus doesn't say 'try harder' or 'figure it out.' He says 'come to me.' That's an invitation, not a command. And His yoke — His way of living — is easy and light. Not because life gets simple, but because you're no longer carrying it alone. Surrender isn't weakness. It's the moment you finally stop pretending you were designed to carry what only God can hold.",
                anchor: "What burden am I carrying right now that Jesus is asking me to lay down? Why have I been holding onto it?",
                arrow: "Write down the heaviest thing on your heart today. Then physically put the paper down, walk away from it, and pray: 'I give this to You.'"),

            DayData(week: 1, theme: "Worship as Surrender", scripture: "Romans 12:1",
                devotional: "Present your bodies as a living sacrifice, holy and acceptable to God, which is your spiritual worship. Paul doesn't separate worship from real life. He doesn't say worship is something you do on Sunday with music. He says your entire life — your body, your time, your decisions, your energy — is an act of worship when it's offered to God. A living sacrifice. That's harder than a dead one. A dead sacrifice stays on the altar. A living one keeps trying to crawl off. Every day you wake up and re-present yourself to God is an act of worship. Every time you choose His way over yours, you're worshipping. Every time you say 'not my will but Yours,' you're laying yourself back on the altar. Most men think of worship as singing. God thinks of worship as surrendering. The man who gives God his Monday morning is worshipping more than the man who only gives God his Sunday hour.",
                anchor: "Is my life an act of worship or an act of self-preservation? Where am I crawling off the altar?",
                arrow: "Choose one ordinary moment today — a commute, a meal, a work task — and consciously dedicate it to God as an act of worship."),

            DayData(week: 1, theme: "Week 1 Review", scripture: "Philippians 2:8-9",
                devotional: "He humbled himself by becoming obedient to the point of death, even death on a cross. Therefore God has highly exalted him. There it is — the pattern that defines everything. Down before up. Humility before exaltation. Cross before crown. Jesus didn't skip the suffering to get to the glory. He walked straight into it — willingly, fully, without reservation. And God exalted Him precisely because He went low. This week was about bowing the knee. Recognizing pride, releasing control, coming to God with your real self instead of your polished self. The question now is: did you actually do it? Not in theory — in practice. Did you let go of something? Did you admit something? Did you come to God with empty hands instead of a highlight reel? If you did, you felt the paradox — that going low with God doesn't diminish you. It anchors you. If you didn't, this is your moment. The knee that bows before Christ is the knee that never has to bow to anything else.",
                anchor: "What did God reveal about my pride, control, or self-reliance this week? Where did I resist surrendering?",
                arrow: "Tell one brother what God showed you this week. Not a summary — the real thing. Then ask him the same question."),

            // MARK: Week 2 — Die to Self

            DayData(week: 2, theme: "Daily Death", scripture: "Luke 9:23",
                devotional: "If anyone would come after me, let him deny himself and take up his cross daily and follow me. Daily. Jesus didn't say 'once.' He said every single day. The cross isn't a one-time event in the Christian life — it's a daily rhythm. You wake up, and the old man wakes up with you. He wants what he's always wanted: comfort, control, validation, pleasure on his terms. And every morning you have a choice — feed him or crucify him. Most men try a middle road. They manage the old nature instead of killing it. They negotiate with sin instead of putting it to death. But Jesus didn't say 'manage yourself daily.' He said deny yourself. That's a total word. It means saying no to the deepest impulses that run contrary to who God is making you. It's not punishment — it's freedom. A dead man has no cravings. A crucified life has no leverage points for the enemy to exploit.",
                anchor: "What part of my old nature keeps waking up every morning demanding to be fed? What does denying it actually look like today?",
                arrow: "Identify your most persistent flesh pattern — the thing you keep negotiating with — and choose active denial of it today. Not management. Death."),

            DayData(week: 2, theme: "The Flesh vs. the Spirit", scripture: "Galatians 5:16-17",
                devotional: "Walk by the Spirit, and you will not gratify the desires of the flesh. For the desires of the flesh are against the Spirit, and the desires of the Spirit are against the flesh. Paul makes it binary. There is no neutral ground. Every moment you are either walking in the flesh or walking in the Spirit. The flesh isn't just sexual sin — it's anything that operates apart from God's direction. Self-pity is flesh. People-pleasing is flesh. Anger as a control mechanism is flesh. Workaholism to prove your worth is flesh. The flesh doesn't always look sinful on the outside. Sometimes it looks productive, driven, even religious. But the test isn't how it looks — it's where it comes from. Is this impulse coming from my need to control, impress, or protect myself? That's flesh. Is it coming from trust, obedience, and dependence on God? That's Spirit. You can't walk in both directions at once.",
                anchor: "What 'respectable' flesh patterns am I walking in that don't look sinful but are still operating apart from God's Spirit?",
                arrow: "Before each major decision today, pause and ask: is this impulse from my flesh or from the Spirit? Choose the Spirit's direction even when the flesh screams louder."),

            DayData(week: 2, theme: "Brokenness as Strength", scripture: "2 Corinthians 12:9-10",
                devotional: "My grace is sufficient for you, for my power is made perfect in weakness. Paul begged God three times to remove his thorn. God said no — and gave him something better than removal. He gave him revelation. My power is made perfect in weakness. The world tells men that vulnerability is a liability. God says it's the access point for His power. Think about that. The very thing you're trying to hide — your struggle, your inadequacy, your failure — is the exact place where God's strength shows up most visibly. Paul's response is staggering: 'Therefore I will boast all the more gladly of my weaknesses.' Not tolerate them. Boast in them. Because when he is weak, then he is strong. This inverts everything the world teaches about manhood. Real strength isn't the absence of weakness — it's the presence of God in the middle of it.",
                anchor: "What weakness am I hiding that God might actually want to use as a display of His power in my life?",
                arrow: "Share one real weakness with a trusted brother today — not to get sympathy, but to invite God's strength into that specific area."),

            DayData(week: 2, theme: "The Death of Self-Reliance", scripture: "John 15:5",
                devotional: "Apart from me you can do nothing. Nothing. Not 'less.' Not 'a diminished version.' Nothing. Jesus is not being dramatic. He's being precise. The vine-and-branches metaphor isn't about trying hard and getting a little help from God. It's about total dependence. A branch that disconnects from the vine doesn't just produce less fruit — it dies. And yet self-reliance is the most celebrated virtue in modern manhood. Figure it out yourself. Pull yourself up. Don't ask for help. Don't show need. Handle it. But Jesus dismantles all of that with one sentence. You were never designed to operate independently of Him. Your competence, your intelligence, your experience — none of it produces spiritual fruit apart from Him. The death of self-reliance isn't the death of capability. It's the death of the illusion that your capability is enough.",
                anchor: "Where am I operating on my own competence and calling it faith? Where have I disconnected from the vine?",
                arrow: "Start one task today — work, family, personal — by first praying: 'Apart from You I can do nothing. Lead me in this.' Then act from that posture."),

            DayData(week: 2, theme: "Surrender in Suffering", scripture: "James 1:2-4",
                devotional: "Count it all joy, my brothers, when you meet trials of various kinds, for you know that the testing of your faith produces steadfastness. James isn't telling you to fake happiness when life hurts. He's telling you to see suffering through a completely different lens. Trials aren't interruptions to God's plan — they are God's plan for producing something in you that comfort never could. Steadfastness. Endurance. Maturity. Completeness. The man who surrenders in suffering — who says 'God, I don't understand this, but I trust You in it' — is the man who comes out the other side unshakeable. The man who fights suffering, resents it, demands God explain it — he survives, but he doesn't grow. Surrender in suffering doesn't mean you don't feel pain. It means you refuse to let pain write the story. God is the author. And He wastes nothing — not one tear, not one sleepless night, not one broken expectation.",
                anchor: "What trial am I currently facing that I've been resenting instead of surrendering to God's purposes in it?",
                arrow: "Pray over your hardest circumstance today — not for removal, but for what God wants to produce in you through it."),

            DayData(week: 2, theme: "Crucified Desires", scripture: "Galatians 5:24",
                devotional: "Those who belong to Christ Jesus have crucified the flesh with its passions and desires. Past tense. Paul doesn't say 'are in the process of managing' or 'are trying to reduce.' Crucified. The cross isn't a negotiation table — it's an execution site. And yet most men treat their flesh like a pet they're training instead of an enemy they're putting to death. You don't bargain with a crucified thing. You don't give it weekends off. You don't feed it 'just a little.' Crucifixion is total. Now here's the reality: living this out is daily warfare. The flesh you crucified yesterday resurrects every morning. That's why Paul says in another letter 'I die daily.' It's not that the crucifixion didn't work — it's that you have to keep choosing it. Every morning you wake up to the same fork in the road: feed the flesh or starve it. The surrendered man has made his choice before his feet hit the floor.",
                anchor: "What desire or passion have I been managing instead of crucifying? What would it look like to stop negotiating with it?",
                arrow: "Identify your most persistent craving that pulls you away from Christ. Fast from it today — not to earn anything, but to practice death to self."),

            DayData(week: 2, theme: "Week 2 Review", scripture: "Romans 6:11",
                devotional: "Consider yourselves dead to sin and alive to God in Christ Jesus. Consider — it means to reckon it as fact. Not to feel it. Not to achieve it. To count it as already true. You are dead to sin. That's your position in Christ whether you feel victorious or defeated today. Week 2 was about dying to self — the daily crucifixion of flesh, self-reliance, and the old patterns that keep pulling you backward. The question isn't whether you did it perfectly. No one does. The question is whether you engaged it honestly. Did you name the flesh patterns? Did you stop negotiating? Did you bring your weakness into the light instead of managing it in the dark? Dying to self isn't a destination you arrive at. It's a posture you return to every single day. And every day you return to it, the old man gets a little quieter and the new man gets a little louder.",
                anchor: "What did dying to self actually look like for me this week? Where did I succeed? Where did the flesh win?",
                arrow: "Share your Week 2 experience with a brother. Be specific about where you struggled and where you saw breakthrough."),

            // MARK: Week 3 — Receive Your Identity

            DayData(week: 3, theme: "Who God Says You Are", scripture: "2 Corinthians 5:17",
                devotional: "If anyone is in Christ, he is a new creation. The old has passed away; behold, the new has come. Most men live from a false identity. They define themselves by what they do, what they've done, what was done to them, or what others think of them. Worker. Provider. Failure. Addict. Nobody. Success. Disappointment. These labels feel like truth because they've been reinforced for years. But Paul says something radical: if you are in Christ, the old version of you is gone. Not improved. Not upgraded. Gone. You are a new creation. The problem isn't that this isn't true — it's that most men don't believe it. They live from the old labels because the old labels are familiar. Familiar isn't the same as true. Today, the most important thing you can do is let God redefine you. Not your father's voice. Not your failures. Not the culture. God. Who does He say you are?",
                anchor: "What old label or identity am I still living from that God has already replaced? What has He said instead?",
                arrow: "Write down the top three labels you carry about yourself. Cross out any that contradict what Scripture says about who you are in Christ."),

            DayData(week: 3, theme: "Son, Not Slave", scripture: "Galatians 4:6-7",
                devotional: "Because you are sons, God has sent the Spirit of his Son into our hearts, crying, 'Abba! Father!' So you are no longer a slave, but a son. A slave performs to earn. A son rests in who he is. A slave is afraid of punishment. A son is secure in love. A slave works from fear. A son works from identity. Most men relate to God as slaves. They perform, strive, achieve, and hope it's enough. They read their Bible out of guilt. They serve out of obligation. They pray out of duty. And they wonder why their relationship with God feels exhausting instead of life-giving. God didn't save you to make you a better worker in His field. He saved you to make you His son. Abba — daddy. It's the most intimate word for father in the ancient world. And God says you can call Him that. Not because you earned it. Because Christ earned it for you. Stop performing for a God who already calls you His child.",
                anchor: "Do I relate to God more like a slave performing for approval or a son resting in love? What would the shift look like?",
                arrow: "Pray today using the word 'Father' — not formally, but personally. Talk to Him as a son who is known and loved, not as a worker filing a report."),

            DayData(week: 3, theme: "Defined by the Cross", scripture: "1 Peter 2:9",
                devotional: "You are a chosen race, a royal priesthood, a holy nation, a people for his own possession. Chosen. Royal. Holy. His. Peter isn't writing to spiritual superstars. He's writing to scattered refugees — people who had lost their homes, their social standing, their security. And he tells them: this is who you actually are. The world will define you by your circumstances. God defines you by His choice. You didn't choose Him — He chose you. You aren't holy because you act holy — you're holy because He set you apart. You aren't valuable because of what you produce — you're valuable because you belong to Him. When your identity is anchored in the cross, it can't be shaken by job loss, rejection, failure, or any voice that tells you you're not enough. The cross already settled the question of your worth. It settled it at the highest possible price.",
                anchor: "Am I letting my circumstances define my worth, or am I letting the cross? Where do I need to return to what God says about me?",
                arrow: "When a thought today tells you you're not enough — not successful enough, not spiritual enough, not man enough — counter it out loud with one truth from Scripture about your identity in Christ."),

            DayData(week: 3, theme: "The Father's Voice", scripture: "Matthew 3:17",
                devotional: "This is my beloved Son, with whom I am well pleased. God spoke these words over Jesus before He did a single miracle. Before He preached a sermon. Before He healed anyone. Before the cross. Before the resurrection. Before any public ministry at all. God declared His pleasure over His Son based on identity, not accomplishment. Every man is looking for that voice — the voice that says 'I'm proud of you. You're mine. You're enough.' Some of us heard it from our fathers. Many didn't. Some heard the opposite — criticism, silence, absence, or conditional approval that had to be constantly re-earned. But here's what changes everything: God speaks that same declaration over you. In Christ, you are His beloved son. He is well pleased — not because of your performance, but because of your position. You are in Christ. And in Christ, the Father's approval is settled. Stop searching for it everywhere else.",
                anchor: "Whose approval am I still chasing — my father's, my boss's, the world's? What would it mean to truly rest in God's approval alone?",
                arrow: "Sit in silence for five minutes today and let God speak over you: 'You are My beloved son. I am pleased with you.' Don't argue with it. Receive it."),

            DayData(week: 3, theme: "Freedom from Comparison", scripture: "Galatians 1:10",
                devotional: "Am I now seeking the approval of man, or of God? If I were still trying to please man, I would not be a servant of Christ. Paul draws a hard line. You cannot serve Christ and live for human approval at the same time. They pull in opposite directions. Comparison is the thief of surrendered identity. The moment you look sideways at another man's life — his success, his body, his marriage, his platform, his calling — you've stepped out of the lane God designed specifically for you. Comparison says 'I should be further along.' God says 'I have you exactly where I need you.' Comparison says 'his story is better.' God says 'I'm writing yours.' The surrendered man doesn't measure himself against other men. He measures himself against one question: am I being faithful to what God has put in front of me? That's it. That's the whole metric.",
                anchor: "Where is comparison stealing my peace and pulling me out of the identity God has given me?",
                arrow: "Celebrate another man's win today without any internal comparison. Genuinely encourage someone whose success would normally trigger envy in you."),

            DayData(week: 3, theme: "New Creation, New Mind", scripture: "Ephesians 4:22-24",
                devotional: "Put off your old self, which belongs to your former manner of life and is corrupt through deceitful desires, and be renewed in the spirit of your minds, and put on the new self, created after the likeness of God in true righteousness and holiness. Paul uses clothing language — put off, put on. This isn't passive. You don't drift into your new identity. You choose it. Every day you decide what you're wearing: the old self or the new. The old self is familiar. It's the version of you that reacts in anger, retreats into isolation, numbs with distraction, and measures worth by output. It feels like you — but it's not. It's the corrupted version. The new self is who you actually are in Christ — righteous, holy, created in God's likeness. Renewal happens in the mind. What you think about yourself determines how you live. If you think like the old man, you'll act like the old man. Renew your mind with who God says you are, and your actions will follow.",
                anchor: "What old-self patterns am I still wearing that don't fit the man God has made me? What does the new self look like in my specific life?",
                arrow: "Catch yourself in one old-self moment today — a reactive thought, a default pattern — and consciously choose the new-self response instead."),

            DayData(week: 3, theme: "Week 3 Review", scripture: "Ephesians 2:10",
                devotional: "We are his workmanship, created in Christ Jesus for good works, which God prepared beforehand, that we should walk in them. Workmanship — the Greek word is poiema, from which we get 'poem.' You are God's poem. His masterwork. His crafted creation. Not mass-produced. Not accidental. Intentionally designed for specific good works that He prepared before you were born. Week 3 was about receiving your identity — letting God's voice replace every counterfeit voice that has tried to define you. The father who was absent. The culture that measures worth by achievement. The inner critic that never shuts up. The comparison game that never ends. God has spoken. You are chosen. You are His son. You are a new creation. The question is whether you'll believe it deeply enough to live from it. Identity isn't something you build. It's something you receive from the One who made you.",
                anchor: "What shifted in how I see myself this week? Which truth about my identity in Christ hit the deepest?",
                arrow: "Write down three identity truths from this week and put them where you'll see them every morning. Let them be the first voice you hear before the world speaks."),

            // MARK: Week 4 — Rise to Serve

            DayData(week: 4, theme: "Surrendered Strength", scripture: "Philippians 4:13",
                devotional: "I can do all things through him who strengthens me. This verse gets quoted on gym walls and graduation cards, but Paul wrote it from a Roman prison. He wasn't talking about peak performance. He was talking about contentment in every circumstance — abundance and need, fullness and hunger, plenty and want. The strength Christ gives isn't the strength to dominate your environment. It's the strength to be faithful in it regardless of what it looks like. Surrendered strength is different from worldly strength. Worldly strength says 'I can handle this.' Surrendered strength says 'He can handle this through me.' The difference isn't subtle — it changes everything. When you operate from surrendered strength, you don't burn out because the source isn't you. You don't give up because the mission isn't yours. You don't break down because the weight isn't on your shoulders. You are a conduit, not the generator. Rise — but rise in His power, not yours.",
                anchor: "Am I trying to be strong for God or strong through God? What would it look like to operate from His strength instead of manufacturing my own?",
                arrow: "Take on one challenge today that feels beyond your capacity and consciously depend on Christ's strength as you do it. Not your willpower — His power."),

            DayData(week: 4, theme: "Lead from the Low Place", scripture: "Mark 10:43-45",
                devotional: "Whoever would be great among you must be your servant, and whoever would be first among you must be slave of all. For even the Son of Man came not to be served but to serve, and to give his life as a ransom for many. Jesus redefines greatness with a towel and a basin. The world's leadership model is ascend, accumulate, command. Christ's model is descend, empty, serve. This isn't weakness disguised as virtue — it's the most powerful form of leadership the world has ever seen. Jesus washed feet the night before He saved the world. He served before He conquered. He knelt before He rose. The surrendered man doesn't lead from a platform above. He leads from a posture below. He doesn't ask 'who is following me?' He asks 'who am I serving?' The paradox of the kingdom is that the way up is down. The man who bows lowest before Christ stands tallest among men — not because he demanded the position, but because he earned it on his knees.",
                anchor: "Is my leadership about being served or about serving? Where is God calling me to lead from the low place this week?",
                arrow: "Find one act of service today that no one will see and no one will thank you for. Do it as unto the Lord."),

            DayData(week: 4, theme: "Advancing with Purpose", scripture: "Ephesians 2:10",
                devotional: "We are his workmanship, created in Christ Jesus for good works, which God prepared beforehand, that we should walk in them. Surrender doesn't end with kneeling. It ends with rising — and walking into the works God prepared for you before time began. You weren't saved just to be saved. You were saved for a purpose. A calling. A mission. And it was designed specifically for you — your gifts, your wounds, your story, your capacity. The surrendered man doesn't wander through life waiting for purpose to find him. He walks into it daily with open hands and a willing heart. Purpose isn't always glamorous. Sometimes it looks like showing up for your family when you're exhausted. Sometimes it's the conversation nobody else wants to have. Sometimes it's quiet faithfulness in a role no one celebrates. But every step taken in obedience is a step into the works God prepared. Walk in them. They are yours.",
                anchor: "What purpose has God placed in front of me that I've been ignoring, delaying, or disqualifying myself from?",
                arrow: "Take one purposeful step today toward the thing God has been pressing on your heart. Don't wait for clarity — obey what you already know."),

            DayData(week: 4, theme: "Humility in Community", scripture: "Proverbs 27:17",
                devotional: "Iron sharpens iron, and one man sharpens another. Surrender isn't a solo project. A man who tries to die to himself by himself usually just ends up talking to himself. You need brothers. Not fans. Not followers. Not people who tell you what you want to hear. Brothers who will look you in the eye and say 'that's not who God made you to be' when you're drifting. Humility in community means being known — really known. It means letting men into the rooms you keep locked. It means confessing, not just venting. It means asking 'how am I really doing?' and being willing to hear the answer. The enemy's strategy has always been isolation. Get the man alone and he's easy prey. But a man in honest community with other surrendered men? That's a threat the enemy can't handle. You weren't designed to carry this alone. Stop acting like you were.",
                anchor: "Am I truly known by other men, or am I managing my image even in my closest relationships? Where do I need to go deeper?",
                arrow: "Reach out to one brother today and ask a real question. Not 'how are you?' but 'where are you actually struggling right now?' Then share yours."),

            DayData(week: 4, theme: "Worship as Warfare", scripture: "2 Chronicles 20:21-22",
                devotional: "He appointed those who were to sing to the Lord and praise him in holy attire, as they went before the army. And when they began to sing and praise, the Lord set an ambush against their enemies. Jehoshaphat faced an army he couldn't beat. Three nations against one. His response? He put the worship team in front of the soldiers. This looks insane by military standards. It's genius by kingdom standards. Worship isn't just something you do after the victory. It's how you fight the battle. When you worship in the middle of the mess — when you praise God before the situation changes — you are declaring that God is bigger than what you're facing. That's not denial. It's defiance. You are defying the narrative that your circumstances are the final word. The surrendered man has discovered that worship isn't a retreat from battle. It is the battle. Praise God today before the answer comes. That's where the ambush happens.",
                anchor: "Am I waiting for the victory to worship, or am I worshipping as the weapon? Where do I need to praise before I see the answer?",
                arrow: "Worship God today in the middle of your hardest situation — out loud if you can. Declare His goodness before the resolution comes."),

            DayData(week: 4, theme: "Week 4 Review", scripture: "Micah 6:8",
                devotional: "He has told you, O man, what is good; and what does the Lord require of you but to do justice, and to love kindness, and to walk humbly with your God? After thirty days, it comes down to this: walk humbly with your God. Not perform for Him. Not impress Him. Walk with Him. Humbly. That's the life of a surrendered man. Week 4 was about rising — not to reclaim the control you surrendered, but to serve from the strength God gave you. Surrendered strength. Servant leadership. Purpose-driven obedience. Humble community. Worship as warfare. This isn't a soft life. This is the most dangerous kind of man — one who has nothing to prove because his identity is settled, nothing to lose because his life belongs to Christ, and nothing to fear because the God of the universe walks with him. You bowed the knee. You died to self. You received your identity. Now you rise — not as the man you were, but as the man God made you to be.",
                anchor: "What does 'walking humbly with God' actually look like in my daily life going forward? What will I carry from this week into every week after?",
                arrow: "Write your commitment for life after this journey: one sentence, from the heart, that captures who God has called you to be as a surrendered man."),

            // MARK: Days 29-30 — Completion

            DayData(week: 4, theme: "The Surrendered Life", scripture: "Romans 12:1-2",
                devotional: "Present your bodies as a living sacrifice, holy and acceptable to God. Do not be conformed to this world, but be transformed by the renewal of your mind. You started this journey on Day 1 with this same call — your life as an act of worship. Now you return to it as a different man. Not because you completed thirty days of devotionals. But because for thirty days you practiced dying. Dying to pride. Dying to control. Dying to false identity. Dying to self-reliance. And in the dying, you found life. Real life. The kind that doesn't depend on circumstances, approval, or your own strength. The surrendered life isn't a life diminished — it's a life unleashed. When you stop white-knuckling your way through faith and start releasing everything to God, His power flows through you without resistance. You became a conduit, not a dam. This isn't the end. It's a new beginning — and every morning for the rest of your life, the invitation is the same: present yourself, surrender your will, and let God transform you from the inside out.",
                anchor: "How has this thirty-day journey changed the way I approach God, my identity, and my daily surrender? What is different now?",
                arrow: "Share your full journey with a brother or your circle. Not the highlights — the whole story. Then ask God: 'What's next?'"),

            DayData(week: 4, theme: "Surrender First — Always", scripture: "Galatians 2:20",
                devotional: "I have been crucified with Christ. It is no longer I who live, but Christ who lives in me. And the life I now live in the flesh I live by faith in the Son of God, who loved me and gave himself for me. Here it is again — the verse that anchored this entire journey. But you hear it differently now. Crucified with Christ — you know what that costs. It costs your pride, your control, your old identity, your self-reliance, your right to run the show. It is no longer I who live — the old man is dead. Not improved. Dead. But Christ who lives in me — this is the exchange. Your striving for His peace. Your performance for His acceptance. Your weakness for His power. The life I now live I live by faith — not by sight, not by feeling, not by the world's metrics. Faith in the Son of God who loved you and gave Himself for you. You are that loved. You are that valued. Every day for the rest of your life, surrender first. Bow before you stand. Die before you live. Kneel before you lead. This is the way of the cross. And it is the way of the man God made you to be.",
                anchor: "What is my one-sentence commitment as a man who surrenders first? Write it. Say it out loud. Carry it forward.",
                arrow: "Identify one man who needs this journey. Invite him today. The best thing you can do with what you've received is give it away."),

        ]

        return data.enumerated().map { index, item in
            JourneyDay(
                id: index + 1,
                week: item.week,
                theme: item.theme,
                scripture: item.scripture,
                devotional: item.devotional,
                anchorPrompt: item.anchor,
                arrowPrompt: item.arrow,
                isUnlocked: index == 0,
                completedDate: nil
            )
        }
    }

    // MARK: - Prophet, Priest, King Journey (30 Days in the Offices of Christ)
    private static func prophetPriestKingJourneyDays() -> [JourneyDay] {
        struct DayData {
            let week: Int
            let theme: String
            let scripture: String
            let devotional: String
            let anchor: String
            let arrow: String
        }

        let data: [DayData] = [

            // MARK: Week 1 — Prophet

            DayData(week: 1, theme: "The Call to Speak", scripture: "Ezekiel 33:7",
                devotional: "Son of man, I have made you a watchman for the house of Israel. Whenever you hear a word from my mouth, you shall give them warning from me. A prophet isn't a fortune teller. He's a truth teller. God positioned Ezekiel on the wall — not for his own safety, but for the sake of the people below. If Ezekiel saw danger and stayed silent, the blood was on his hands. God has put you on a wall too. In your home. In your workplace. In your friendships. In your church. You see things other people don't see — not because you're smarter, but because God has opened your eyes. The question isn't whether you see the danger. The question is whether you'll open your mouth. Most men stay silent because silence is safe. But safety isn't the calling. Faithfulness is. A prophet speaks what God gives him — not to be popular, not to be right, but to be obedient. The world has enough silent men. God is looking for watchmen.",
                anchor: "Where has God shown me something — in my family, friendships, or church — that I've been too afraid to speak up about?",
                arrow: "Identify one truth you've been holding back and speak it today — with courage and with love. Don't wait for the perfect moment."),

            DayData(week: 1, theme: "Truth in Love", scripture: "Ephesians 4:15",
                devotional: "Speaking the truth in love, we are to grow up in every way into him who is the head, into Christ. Truth without love is brutality. Love without truth is sentimentality. The prophet of God carries both — and the tension between them is where real growth happens. Most men default to one side. Some men are blunt and call it honesty — but their words leave wreckage. Other men are gentle and call it kindness — but they never say the hard thing. Neither is the prophetic calling. Paul says speaking truth in love produces growth — maturity — Christlikeness. When you confront someone with the truth, the test isn't just whether what you said was accurate. It's whether you said it for their good or for your satisfaction. Did you speak to build them up or to prove a point? A prophet's words should feel like surgery, not assault. Both involve a blade — but one heals.",
                anchor: "When I speak hard truths, is my motive love or something else — frustration, superiority, control? How can I tell the difference?",
                arrow: "Have one honest conversation today where you prioritize being truthful and loving at the same time. Speak to build, not to tear down."),

            DayData(week: 1, theme: "Hearing God's Voice", scripture: "John 10:27",
                devotional: "My sheep hear my voice, and I know them, and they follow me. You can't speak for God if you aren't listening to God. The prophet's authority doesn't come from his eloquence — it comes from his proximity to the One who sent him. Before Elijah spoke to the king, he listened at the brook. Before Moses spoke to Pharaoh, he stood at the burning bush. Before Jesus taught the crowds, He withdrew to the wilderness. Every public word was born in private communion. Most men are too noisy to hear God. Not externally — internally. The constant mental chatter of worry, planning, striving, and scrolling drowns out the still, small voice. You don't have to manufacture God's voice. You have to get quiet enough to recognize it. He's already speaking. The question is whether you've created enough silence in your life to hear Him.",
                anchor: "Is my life quiet enough to hear God, or am I drowning Him out with noise and busyness? When did I last truly listen?",
                arrow: "Spend ten minutes in total silence today — no phone, no music, no agenda. Just listen. Write down anything God brings to mind."),

            DayData(week: 1, theme: "Courage Over Cowardice", scripture: "Jeremiah 1:7-8",
                devotional: "Do not say, 'I am only a youth.' For to all to whom I send you, you shall go, and whatever I command you, you shall speak. Do not be afraid of them, for I am with you to deliver you. Jeremiah tried to disqualify himself before he started. Too young. Too inexperienced. Too afraid. God didn't argue with his resume — He overruled it. 'Do not be afraid of them, for I am with you.' The prophet's courage doesn't come from confidence in himself. It comes from the presence of the One who sent him. Every man has a list of reasons he's not qualified to speak truth. Not educated enough. Not spiritual enough. Not eloquent enough. My life isn't clean enough. God heard every one of those excuses from Jeremiah and dismissed them with one sentence: I am with you. Your qualification isn't your perfection — it's His presence. Cowardice dresses itself up as humility. 'I shouldn't say anything — who am I?' But when God says speak, silence isn't humility. It's disobedience.",
                anchor: "What excuse am I using to stay silent when God is asking me to speak? Am I calling cowardice humility?",
                arrow: "Do one courageous thing today that your fear has been blocking — a conversation, a confession, a stand you need to take. Go, and He goes with you."),

            DayData(week: 1, theme: "Prophet in the Home", scripture: "Deuteronomy 6:6-7",
                devotional: "These words that I command you today shall be on your heart. You shall teach them diligently to your children, and shall talk of them when you sit in your house, and when you walk by the way, and when you lie down, and when you rise. The first place you are called to be a prophet is in your own house. Not on a stage. Not on social media. At your dinner table. With your kids. With your wife. With your roommate. With whoever God has placed under your roof. Moses describes a rhythm, not an event — truth woven into every part of daily life. When you sit, walk, lie down, rise up. This isn't a Sunday school lesson. It's a lifestyle where God's truth is so embedded in you that it overflows into every conversation, every teachable moment, every bedtime prayer. The prophetic man at home doesn't preach at his family. He lives in a way that makes truth visible — and when the moment comes, he speaks it clearly, tenderly, and with authority.",
                anchor: "Am I a prophet in my home — speaking God's truth into the lives of people closest to me — or am I spiritually silent where it matters most?",
                arrow: "Share one truth from God's Word with someone in your household today. Not a lecture — a conversation. Make it personal and real."),

            DayData(week: 1, theme: "Confrontation as Love", scripture: "Proverbs 27:6",
                devotional: "Faithful are the wounds of a friend; profuse are the kisses of an enemy. A true friend wounds you with truth. A false friend comforts you with lies. Most men have inverted this — they think love means never making someone uncomfortable. But Solomon says the exact opposite. The friend who tells you what you don't want to hear is the faithful one. The friend who only tells you what you want to hear? That's the enemy. Confrontation isn't the opposite of love — it's one of the highest expressions of it. When you see a brother headed toward destruction and you say something, you're not being judgmental. You're being faithful. When you stay silent because you're afraid of the reaction, you're not being kind. You're being complicit. The prophetic man doesn't enjoy confrontation — but he doesn't run from it either. He cares about the person more than the person's opinion of him. That's love.",
                anchor: "Is there a brother, a friend, or a family member headed in the wrong direction that I need to confront in love? What's holding me back?",
                arrow: "If God brings someone to mind today who needs a hard truth spoken in love, don't wait. Reach out. Faithful wounds heal."),

            DayData(week: 1, theme: "Week 1 Review", scripture: "Isaiah 6:8",
                devotional: "Then I heard the voice of the Lord saying, 'Whom shall I send, and who will go for us?' And I said, 'Here I am! Send me.' Isaiah saw God high and lifted up — and his first response wasn't 'send me.' It was 'woe is me, for I am a man of unclean lips.' He saw his own unworthiness before he heard the call. Then God cleansed him — a coal touched his lips — and only then did Isaiah volunteer. The pattern matters. The prophet doesn't speak from a place of moral superiority. He speaks from a place of cleansed brokenness. He has been to the throne room, seen his own sin, received grace, and now goes because he was sent, not because he appointed himself. This week was about the prophetic calling — truth-telling, hearing God, courage, confrontation as love, speaking truth into your home. Did you speak? Did you listen? Did you go where He sent you? The call hasn't expired. Whom shall I send? Your answer today determines your trajectory tomorrow.",
                anchor: "Did I speak truth this week, or did I stay comfortable in silence? Where did God call me and I actually went?",
                arrow: "Tell a brother what you learned this week about being a prophet in your home, work, or relationships. Be specific about where you obeyed and where you hesitated."),

            // MARK: Week 2 — Priest

            DayData(week: 2, theme: "Standing in the Gap", scripture: "Ezekiel 22:30",
                devotional: "I sought for a man among them who should build up the wall and stand in the gap before me for the land, that I should not destroy it, but I found none. God looked for one man. One intercessor. One priest who would stand between a broken world and a holy God. He found none. Let that settle. An entire nation — and not a single man willing to pray on their behalf. The priestly role is intercession — standing between God and the people you love, lifting them before the throne when they can't or won't lift themselves. Your wife. Your children. Your friends. Your coworkers. Your church. Someone in your life right now needs a man who will go to God on their behalf. Not give them advice. Not fix their problem. Pray. The priest doesn't stand in the gap because he's holier than everyone else. He stands there because someone has to, and God is looking at him. Will you be the man God finds?",
                anchor: "Who in my life desperately needs someone to pray for them — and am I that man? Am I standing in the gap or standing on the sidelines?",
                arrow: "Choose three people by name today. Pray for each of them specifically — not quickly, not generally. Stand in the gap like their breakthrough depends on it."),

            DayData(week: 2, theme: "The Prayer Warrior", scripture: "James 5:16",
                devotional: "The prayer of a righteous person has great power as it is working. Not 'might have power someday.' Has great power — present tense, active. James says prayer is working even when you can't see the results. Most men have an anemic prayer life because they've never seen prayer as powerful. They see it as obligation — something you do before meals and at bedtime. But James calls it a weapon. A force. Something with great power that is actively working in the spiritual realm while you speak. The priest is a prayer warrior — not a prayer hobbyist. There's a difference. A hobbyist prays when it's convenient. A warrior prays when it's costly. A hobbyist prays general prayers. A warrior prays targeted, specific, faith-filled prayers that move heaven. Elijah was a man with a nature like ours, James says, and he prayed and the rain stopped. Same nature as you. Different prayer life. What would change in your world if you actually prayed like it mattered?",
                anchor: "Is my prayer life powerful or passive? Do I pray like a warrior or a hobbyist? What would change if I truly believed prayer works?",
                arrow: "Set a timer for fifteen minutes today and pray with intensity. Pray specifically, by name, for situations you've been worrying about instead of praying about."),

            DayData(week: 2, theme: "Connecting Others to God", scripture: "1 Peter 2:5",
                devotional: "You yourselves like living stones are being built up as a spiritual house, to be a holy priesthood, to offer spiritual sacrifices acceptable to God through Jesus Christ. Peter says you are a priest. Not metaphorically — actually. Under the old covenant, only designated Levites could approach God on behalf of the people. But Christ tore the veil. Now every believer is a priest, and every man has a priestly responsibility to connect the people in his life to God. This isn't about being a pastor or having a theological degree. It's about being the man in your home, your friend group, your workplace who builds a bridge between people and the presence of God. Sometimes that looks like praying over your kids before school. Sometimes it's texting a friend a verse when the Spirit prompts you. Sometimes it's simply living in a way that makes people curious about the God you serve. The priest makes God accessible — not distant, not academic, not intimidating. Accessible.",
                anchor: "Am I making God accessible to the people around me, or am I keeping my faith private? Who needs me to build a bridge to God for them?",
                arrow: "Do one priestly act today that connects someone else to God — pray over a meal with others, share a scripture with a friend, or ask someone if you can pray for them right now."),

            DayData(week: 2, theme: "The Family Altar", scripture: "Joshua 24:15",
                devotional: "As for me and my house, we will serve the Lord. Joshua didn't make this declaration alone in a prayer closet. He made it publicly, on behalf of his household. He took responsibility for the spiritual direction of his family. The family altar isn't a piece of furniture — it's a posture. It's the man who says 'in this house, we pray. In this house, we read the Word. In this house, God is honored — not perfectly, but intentionally.' Most families drift spiritually because no one takes the lead. The wife may be more naturally spiritual. The kids may resist it. The schedule may seem too full. But God doesn't call the family to lead itself. He calls the man to lead the family — to be the priest of his household. That doesn't require perfection. It requires presence. Show up. Open the Bible. Pray out loud. It will be awkward at first. Do it anyway. Your family is watching to see if you actually believe what you say you believe.",
                anchor: "Am I the spiritual leader of my home, or have I outsourced that role? What would it look like to build a family altar — even an imperfect one?",
                arrow: "Lead one spiritual moment in your home today. Read a verse at dinner. Pray with your wife or kids before bed. If you live alone, call a family member and pray for them on the phone."),

            DayData(week: 2, theme: "Confession and Repentance", scripture: "James 5:16a",
                devotional: "Confess your sins to one another and pray for one another, that you may be healed. The priest carries his own sin to the cross before he carries anyone else's burdens to the throne. Confession is the most counter-cultural thing a man can do. Everything in modern masculinity says hide your weakness, manage your image, never let them see you bleed. But James says healing — actual, spiritual, relational healing — comes through confession. Not confession to God alone in the dark. Confession to one another. Out loud. To a brother. This isn't about public humiliation. It's about breaking the power of secrecy. Sin thrives in the dark. The moment you drag it into the light by saying it out loud to another human being, its grip loosens. The priest who never confesses becomes a fraud — performing holiness he doesn't possess. The priest who confesses regularly becomes dangerous — because a man with nothing to hide has nothing the enemy can leverage.",
                anchor: "What am I hiding that needs to be confessed — not just to God, but to a trusted brother? What would break free if I said it out loud?",
                arrow: "Confess one thing to a trusted brother today. Not something easy. The thing that has power over you precisely because you've been keeping it in the dark."),

            DayData(week: 2, theme: "Spiritual Covering", scripture: "Job 1:5",
                devotional: "When the days of the feast had run their course, Job would send and consecrate his children, and he would rise early in the morning and offer burnt offerings according to the number of them all. For Job said, 'It may be that my children have sinned, and cursed God in their hearts.' Thus Job did continually. Job prayed for his children before they even knew they needed it. He rose early — before the day started, before the problems surfaced — and covered them. Not occasionally. Continually. This is the priestly covering. The man who prays over his family like a shield, covering them in intercession before the enemy even gets a shot off. Your wife is fighting battles you don't see. Your kids are facing temptations they'll never tell you about. Your friends are struggling with things they haven't named yet. You may not be able to fix any of it. But you can cover all of it — in prayer, before the throne, every single day. The priest doesn't wait for the crisis. He prays before it arrives.",
                anchor: "Am I covering my family and loved ones in prayer proactively, or only reacting when crisis hits? What would a daily spiritual covering look like?",
                arrow: "Rise ten minutes early tomorrow. Before you check your phone, pray over every person in your household by name. Cover them before the day starts."),

            DayData(week: 2, theme: "Week 2 Review", scripture: "Hebrews 4:16",
                devotional: "Let us then with confidence draw near to the throne of grace, that we may receive mercy and find grace to help in time of need. The priest has access. Under the old covenant, only the high priest could enter the Most Holy Place — once a year, with blood, with fear, with a rope tied to his ankle in case he died in God's presence. But Christ opened the way. The veil is torn. And now you can walk into the throne room of the Creator of the universe with confidence. Not arrogance — confidence. Because of what Jesus did, not because of who you are. Week 2 was about the priestly calling — intercession, prayer, connecting others to God, leading your family spiritually, confessing your own sin, and covering the people you love. Did you pray with power? Did you confess honestly? Did you lead spiritually at home? The throne of grace is still open. Draw near today. Your family's spiritual health may depend on whether you show up as their priest.",
                anchor: "What did God teach me about being a priest this week? Where did I intercede well? Where did I neglect my priestly role?",
                arrow: "Share with a brother what you learned about prayer and priesthood this week. Commit to one priestly habit you'll continue beyond this journey."),

            // MARK: Week 3 — King

            DayData(week: 3, theme: "The Servant King", scripture: "John 13:14-15",
                devotional: "If I then, your Lord and Teacher, have washed your feet, you also ought to wash one another's feet. For I have given you an example, that you also should do just as I have done to you. The night before He was crucified, the King of Kings got on His knees with a towel and a basin. No one asked Him to. No one expected it. The disciples were so shocked that Peter resisted. But Jesus was making a point that would redefine kingship forever: the greatest authority is expressed in the lowest service. The world's king sits on a throne and is served. Christ's king kneels on the floor and serves. This is the model for every man who leads — in his home, in his workplace, in his church, in his community. Your authority isn't measured by who serves you. It's measured by who you serve. The man who washes feet isn't weak. He's so secure in his identity that he doesn't need a title to prove his worth. He leads from below — and that's the most powerful position in the kingdom.",
                anchor: "Is my leadership about being served or serving? Where am I leading from the throne when I should be leading from the basin?",
                arrow: "Find the most menial, overlooked task in your home or workplace today and do it. Not for recognition. As an act of kingly service."),

            DayData(week: 3, theme: "Provider, Not Hoarder", scripture: "1 Timothy 5:8",
                devotional: "If anyone does not provide for his relatives, and especially for members of his household, he has denied the faith and is worse than an unbeliever. Paul's words here are severe — worse than an unbeliever. Provision isn't optional for a man. It's foundational. But provision has been distorted by the culture into accumulation. The world says provide means 'get more.' God says provide means 'make sure they have what they need.' There's a difference between providing and hoarding. The king who hoards builds a fortress for himself. The king who provides builds a table for his family. Provision is stewardship — managing what God has given you for the good of the people He's entrusted to you. That includes money, yes. But it also includes your time, your attention, your emotional presence, your spiritual leadership. A man can provide a six-figure income and still fail to provide what his family actually needs — which is often just him, fully present, fully engaged.",
                anchor: "Am I providing what my family actually needs — time, presence, attention, spiritual leadership — or just financial resources?",
                arrow: "Give someone you love something today that money can't buy — your undivided attention for thirty minutes. No phone. No agenda. Just presence."),

            DayData(week: 3, theme: "Protector Without Controlling", scripture: "Psalm 82:3-4",
                devotional: "Give justice to the weak and the fatherless; maintain the right of the afflicted and the destitute. Rescue the weak and the needy; deliver them from the hand of the wicked. Protection is one of the deepest instincts God placed in men. You were designed to guard what matters — your family, the vulnerable, the weak, the overlooked. But protection has a shadow side: control. The man who doesn't know the difference between protecting and controlling will suffocate the very people he's trying to keep safe. Protection says 'I will stand between you and danger.' Control says 'I will decide everything for you so danger never comes.' Protection empowers. Control diminishes. Protection trusts God with the outcome. Control trusts only itself. The kingly man protects his wife by fighting for her heart, not by managing her schedule. He protects his children by building their courage, not by shielding them from every difficulty. He protects his community by standing up for the overlooked, not by dominating the room. True protection creates safety. Control creates cages.",
                anchor: "Where have I confused protecting with controlling? Who am I trying to keep safe in a way that's actually suffocating them?",
                arrow: "Identify one area where you've been overcontrolling in the name of protection. Step back intentionally and trust God to cover what you can't."),

            DayData(week: 3, theme: "Kingdom Over Empire", scripture: "Matthew 6:33",
                devotional: "Seek first the kingdom of God and his righteousness, and all these things will be added to you. Every man is building something. The question is whether you're building a kingdom or an empire. An empire is built for your name, your legacy, your comfort, your control. A kingdom is built for God's name, God's purposes, and the good of others. They can look identical from the outside — same career, same house, same family — but the foundation is completely different. The empire builder asks 'how does this benefit me?' The kingdom builder asks 'how does this honor God and serve others?' Jesus says seek first the kingdom. Not second. Not after you've secured your empire. First. And He makes a promise: everything you actually need will be added. Not everything you want — everything you need. The king who builds for God's kingdom instead of his own empire discovers something surprising: the kingdom life is more abundant than the empire life ever was, because it's built on something that can't be taken away.",
                anchor: "Am I building an empire for my name or a kingdom for God's? What in my life needs to shift from self-serving to God-honoring?",
                arrow: "Look at one area of your life — career, finances, relationships — and honestly ask: am I building this for me or for God's kingdom? Adjust one thing accordingly today."),

            DayData(week: 3, theme: "Building Legacy", scripture: "Psalm 78:4-7",
                devotional: "We will not hide them from their children, but tell to the coming generation the glorious deeds of the Lord. The king doesn't just lead for today — he builds for generations he'll never meet. Psalm 78 describes a man who refuses to let the story die with him. He passes on what God has done — the victories, the rescues, the faithfulness — so that the next generation will set their hope in God. Legacy isn't about your name. It's about the trajectory you set for the people who come after you. Every decision you make today is laying a brick in a building your grandchildren will live in. The shortcuts you take, they inherit. The integrity you build, they stand on. The faith you model, they carry forward. Most men think about legacy when they're old. The kingly man thinks about legacy every day — because he understands that legacy isn't built in a moment. It's built in a thousand ordinary, faithful choices that compound across a lifetime.",
                anchor: "What am I building today that will outlast me? What legacy am I passing to the next generation — intentionally or by default?",
                arrow: "Write down one thing you want the next generation to say about you. Then identify one action today that moves you toward that legacy."),

            DayData(week: 3, theme: "Leading by Example", scripture: "1 Peter 5:2-3",
                devotional: "Shepherd the flock of God that is among you, exercising oversight, not under compulsion, but willingly, as God would have you; not for shameful gain, but eagerly; not domineering over those in your charge, but being examples to the flock. Peter gives three contrasts. Not compulsion — willingness. Not gain — eagerness. Not domination — example. The king leads not by force but by demonstration. Your kids will not do what you say. They will do what you do. Your wife will not trust your words. She will trust your consistency. Your coworkers will not follow your title. They will follow your character. Leadership by example is the slowest form of leadership. It's also the only form that lasts. You can command a room with authority, but if your private life contradicts your public leadership, it's only a matter of time before the cracks show. The kingly man doesn't demand respect — he lives in a way that earns it. Not perfectly. Consistently. The most powerful sermon you will ever preach is the life you live when no one is watching.",
                anchor: "If the people in my life could only see my private habits, would they still trust my leadership? Where is my example strongest? Weakest?",
                arrow: "Choose one area where your actions don't match your words — and close the gap today. Don't announce it. Just do it. Let the example speak."),

            DayData(week: 3, theme: "Week 3 Review", scripture: "Proverbs 29:2",
                devotional: "When the righteous increase, the people rejoice, but when a wicked man rules, people groan. The king's character determines the health of everyone under his leadership. When a righteous man leads — in his home, in his church, in his workplace — people flourish. When a selfish man leads, people suffer. You may not think of yourself as a king. But if anyone depends on you, looks up to you, or is affected by your decisions, you are exercising kingly authority whether you intend to or not. Week 3 was about the kingly calling — servant leadership, provision beyond money, protection without control, building kingdom instead of empire, and leading by example. Did you serve when you could have demanded? Did you provide presence, not just resources? Did you protect without suffocating? Did you lead with your life, not just your words? The kingly man doesn't rule. He serves. He doesn't hoard. He provides. He doesn't control. He protects. And the people around him rejoice.",
                anchor: "What did God reveal about my leadership this week? Where did I lead well? Where did I fall into empire-building or controlling?",
                arrow: "Ask someone you lead — your wife, a coworker, a friend — one honest question: 'How can I lead you better?' Listen without defending."),

            // MARK: Week 4 — The Whole Man

            DayData(week: 4, theme: "Christ the Model", scripture: "Hebrews 1:1-3",
                devotional: "Long ago, at many times and in many ways, God spoke to his fathers by the prophets, but in these last days he has spoken to us by his Son. He is the radiance of the glory of God and the exact imprint of his nature. Jesus is the ultimate Prophet — He didn't just speak God's Word; He was God's Word made flesh. He is the ultimate Priest — He didn't just offer sacrifices; He became the sacrifice. He is the ultimate King — He didn't just rule a territory; He rules all of creation. And He held all three offices simultaneously, perfectly, without any of them diminishing the others. This is your model. Not three separate hats you put on at different times. One integrated man who speaks truth, intercedes faithfully, and leads with humble authority — all at once, all the time. You won't do it perfectly. Christ did. But you are being conformed to His image, and as you step into these three roles daily, you look more and more like the Man you were designed to follow.",
                anchor: "Which of Christ's three roles — Prophet, Priest, King — comes most naturally to me? Which one do I neglect?",
                arrow: "Intentionally practice your weakest role today. If you're a natural leader but weak in prayer, intercede. If you pray well but avoid hard conversations, speak truth."),

            DayData(week: 4, theme: "All Three in Marriage", scripture: "Ephesians 5:25-26",
                devotional: "Husbands, love your wives, as Christ loved the church and gave himself up for her, that he might sanctify her. In one command, Paul calls a husband to all three offices. Prophet: sanctify her — speak truth into her life that draws her closer to God, not further from herself. Priest: gave himself up for her — intercede on her behalf, carry her burdens to the throne, cover her in prayer daily. King: love your wives — lead her with sacrificial authority, provide safety, protect her heart. Most men default to one. The strong-willed man leads but forgets to pray. The gentle man prays but avoids hard conversations. The driven man provides financially but is emotionally absent. Your wife doesn't need one-third of a man. She needs all three — the man who will tell her the truth she doesn't want to hear, pray for her when she can't pray for herself, and lead her with the kind of love that puts her needs above his own. If you're not married, apply this to every relationship where you carry responsibility. The three offices aren't just for husbands — they're for every man.",
                anchor: "In my closest relationship, which role am I strongest in and which am I neglecting? How is the imbalance affecting the people I love?",
                arrow: "Do all three today for one person: speak a truth they need to hear, pray for them specifically, and serve them in a tangible way."),

            DayData(week: 4, theme: "All Three in Fatherhood", scripture: "Proverbs 22:6",
                devotional: "Train up a child in the way he should go; even when he is old he will not depart from it. A father is prophet, priest, and king to his children — and the stakes are generational. As prophet, you speak truth into their identity before the world gets a chance to. You tell your son who he is in Christ before social media tells him who he should be. You tell your daughter she is valued before the culture reduces her to an image. As priest, you intercede for your children — praying over their futures, their friendships, their faith, their battles they don't even know they're fighting yet. You build a spiritual atmosphere in your home where God's presence is normal, not occasional. As king, you provide stability — not perfection, but consistency. Safety. Structure. A home where they know they are loved even when they fail. If you don't have children, this still applies. You are a spiritual father to someone — a younger man, a nephew, a mentee, a kid at church. Every man has someone who needs the prophet, priest, and king in him.",
                anchor: "Am I shaping the next generation as prophet, priest, and king — or have I outsourced their spiritual formation to the culture, the school, or the church?",
                arrow: "Speak one identity truth over a child or young person in your life today. Pray for them by name. Then do one kingly act that makes them feel safe and valued."),

            DayData(week: 4, theme: "All Three at Work", scripture: "Colossians 3:23-24",
                devotional: "Whatever you do, work heartily, as for the Lord and not for men, knowing that from the Lord you will receive the inheritance as your reward. You are serving the Lord Christ. Your workplace is a mission field, and you carry all three offices into it every morning. As prophet, you bring truth into environments that often reward dishonesty — you refuse to cut corners, gossip, or compromise your integrity even when everyone else does. You speak up when something is wrong, even when silence would be easier. As priest, you pray for your coworkers — the ones who are struggling, the ones who don't know God, the ones who would never ask for prayer but desperately need it. You carry them before the throne without them ever knowing it. As king, you lead with excellence and serve with humility. You don't work for the promotion — you work for the Lord. That changes everything. Your boss may never notice your faithfulness. God always does. The man who operates as prophet, priest, and king at work transforms his workplace — not by preaching, but by living.",
                anchor: "How am I carrying the offices of prophet, priest, and king into my work? Where am I most tempted to leave my faith at the door?",
                arrow: "Pray for three coworkers by name today. Speak one honest truth in a work situation where compromise would be easier. Serve someone without being asked."),

            DayData(week: 4, theme: "All Three in the Church", scripture: "Hebrews 10:24-25",
                devotional: "Let us consider how to stir up one another to love and good works, not neglecting to meet together, as is the habit of some, but encouraging one another. The church desperately needs men who will operate in all three offices. As prophet, you speak truth into the body — not gossip, not criticism, but honest words that build up and call out. When you see a brother drifting, you say something. When you see someone gifted but hiding, you call it out. As priest, you intercede for your church — for the pastor who's exhausted, for the marriages crumbling silently in the pews, for the young men who are walking away from faith. You don't just attend church. You cover it in prayer. As king, you serve. You show up early. You stay late. You take the job nobody wants. You lead the small group. You mentor the younger men. You build the kingdom with your hands, not just your attendance. The church has enough consumers. It needs men who will function as prophets, priests, and kings within the body.",
                anchor: "Am I a consumer in my church or a contributor? How can I operate as prophet, priest, and king in my faith community?",
                arrow: "Take one specific action in your church this week: speak an encouragement to your pastor, pray for your church family by name, or volunteer for a role no one else wants."),

            DayData(week: 4, theme: "Raising Up Others", scripture: "2 Timothy 2:2",
                devotional: "What you have heard from me in the presence of many witnesses entrust to faithful men, who will be able to teach others also. Paul describes four generations in one sentence: Paul taught Timothy, who would teach faithful men, who would teach others. The ultimate measure of a prophet, priest, and king isn't what he does — it's who he develops. A prophet who never trains another truth-teller is a voice that dies with him. A priest who never teaches another man to pray leaves a gap when he's gone. A king who never develops another leader builds something that can't outlast his presence. The three offices aren't just for you. They're meant to be multiplied. Somewhere in your life there's a younger man, a newer believer, a brother who's still figuring out what it means to be a godly man. He doesn't need your perfection. He needs your investment. Sit with him. Walk with him. Show him what it looks like. Then send him to do the same for someone else.",
                anchor: "Who am I investing in? Is there a man in my life I should be mentoring, training, or walking with who would grow if I made the time?",
                arrow: "Identify one man you can begin to invest in — a younger believer, a new father, a brother who's struggling. Reach out today and set a time to meet."),

            DayData(week: 4, theme: "Week 4 Review", scripture: "Acts 13:22",
                devotional: "I have found in David the son of Jesse a man after my heart, who will do all my will. God's highest praise for a man wasn't that he was perfect. David was deeply flawed — adulterer, murderer, absent father. But God called him a man after His own heart. David was prophet — he wrote the Psalms, speaking God's truth in worship and lament. David was priest — he danced before the ark, he interceded for his people, he brought the nation back to worship. David was king — he led Israel, protected his people, built a kingdom that pointed to Christ. He did all three imperfectly but wholeheartedly. That's the model. Not perfection in the three offices. Wholehearted pursuit. Week 4 was about integration — bringing the prophet, priest, and king together into every area of your life. Marriage. Fatherhood. Work. Church. You don't need to master all three to start. You need to show up in all three — daily, faithfully, wholeheartedly. A man after God's own heart isn't the man who never fails. He's the man who never stops pursuing.",
                anchor: "Looking at prophet, priest, and king together — where am I growing? Where am I still resisting? What does wholehearted pursuit look like for me going forward?",
                arrow: "Write down your one-sentence commitment for each office: 'As a prophet, I will ___. As a priest, I will ___. As a king, I will ___.' Share them with a brother."),

            // MARK: Days 29-30 — Completion

            DayData(week: 4, theme: "The Integrated Man", scripture: "Micah 6:8",
                devotional: "He has told you, O man, what is good; and what does the Lord require of you but to do justice, and to love kindness, and to walk humbly with your God? Micah distills the entire prophetic, priestly, and kingly calling into one verse. Do justice — that's the king, the man who protects the weak, leads with righteousness, and builds a world where things are set right. Love kindness — that's the priest, the man whose heart is moved by mercy, who intercedes for the broken, who carries compassion into every room he enters. Walk humbly with your God — that's the prophet, the man who stays close enough to God to hear His voice and speak His truth without arrogance. Justice. Mercy. Humility. These aren't three separate goals — they're the description of one integrated man. The man who does justice without mercy becomes harsh. The man who shows mercy without justice becomes permissive. The man who walks humbly without action becomes passive. But the man who holds all three? That's the man God has been building these thirty days. That's the man the world desperately needs.",
                anchor: "How has this journey reshaped my understanding of what God requires of me as a man? What is different now than when I started?",
                arrow: "Share your full journey experience with your circle or a trusted brother. Be honest about where you grew and where you still need to grow."),

            DayData(week: 4, theme: "Prophet, Priest, King — Always", scripture: "2 Timothy 4:2-5",
                devotional: "Preach the word; be ready in season and out of season; reprove, rebuke, and encourage, with complete patience and teaching. As for you, always be sober-minded, endure suffering, do the work of an evangelist, fulfill your ministry. Paul's final charge to Timothy reads like a commissioning into all three offices. Preach the word — prophet. Encourage with patience — priest. Endure suffering, fulfill your ministry — king. This wasn't a temporary assignment. It was Timothy's life calling — and it's yours. You started this journey thirty days ago as a man who may have never thought of himself as a prophet, priest, or king. But God has always seen you that way. He designed you to speak His truth into a world that desperately needs it. He appointed you to stand in the gap for people who can't stand for themselves. He called you to lead with the kind of humble, sacrificial authority that changes everything it touches. These three offices aren't a program you completed. They are the man you are becoming. Every morning for the rest of your life, you wake up and step into them again. Prophet. Priest. King. Go.",
                anchor: "What is my one-sentence commissioning as a man who walks in the offices of prophet, priest, and king? Write it. Carry it forward.",
                arrow: "Identify one man who needs this journey and invite him today. The best thing a prophet, priest, and king can do is raise up another one."),

        ]

        return data.enumerated().map { index, item in
            JourneyDay(
                id: index + 1,
                week: item.week,
                theme: item.theme,
                scripture: item.scripture,
                devotional: item.devotional,
                anchorPrompt: item.anchor,
                arrowPrompt: item.arrow,
                isUnlocked: index == 0,
                completedDate: nil
            )
        }
    }

    // MARK: - Strength in Love Journey (30 Days in 1 Corinthians 16:13-14)
    private static func strengthInLoveJourneyDays() -> [JourneyDay] {
        struct DayData {
            let week: Int
            let theme: String
            let scripture: String
            let devotional: String
            let anchor: String
            let arrow: String
        }

        let data: [DayData] = [

            // MARK: Week 1 — Redefine Strength

            DayData(week: 1, theme: "The World's Lie About Strength", scripture: "1 Corinthians 16:13-14",
                devotional: "Be watchful, stand firm in the faith, act like men, be strong. Let all that you do be done in love. Read those two verses together — because they were always meant to be read together. The world hears 'be strong' and pictures dominance, aggression, self-sufficiency, never backing down. But Paul ends the charge with six words that redefine everything: let all that you do be done in love. Not some of what you do. All of it. The strength God calls men to is inseparable from love. A strong man without love is a dangerous man. A loving man without strength is an ineffective man. But a man who is both strong and loving? That's the man the world has never been able to ignore and has never been able to replicate without Christ. For thirty days, we're going to dismantle the world's counterfeit strength and rebuild it on the foundation it was always meant to stand on — sacrificial, humble, persevering love.",
                anchor: "What has the world taught me about strength that contradicts what Jesus modeled? Where have I been strong without love or loving without strength?",
                arrow: "Identify one relationship where you default to strength without love — harshness, control, cold efficiency. Choose love as the delivery system for your strength today."),

            DayData(week: 1, theme: "Gentle and Lowly", scripture: "Matthew 11:29",
                devotional: "Take my yoke upon you, and learn from me, for I am gentle and lowly in heart. When Jesus described Himself — when He chose the two words that capture who He is at His core — He didn't say powerful and mighty. He said gentle and lowly. The Son of God, who spoke galaxies into existence, who calmed storms with a word, who would rise from the dead — calls Himself gentle. This should wreck every man's definition of strength. Gentleness isn't the absence of power. It's power under perfect control. A stallion in a harness isn't weak — it's the most powerful version of itself because its strength is directed, purposeful, restrained. Jesus had all the power in the universe and chose gentleness. That's not weakness. That's the highest form of strength imaginable. The man who is gentle isn't the man who can't fight. He's the man who can fight and chooses not to — because love governs his power.",
                anchor: "Am I gentle? Not passive — gentle. Where does my strength come out harsh, rushed, or uncontrolled instead of directed by love?",
                arrow: "In every interaction today, filter your strength through gentleness. Speak more softly than usual. Listen longer than you normally would. Let power serve, not dominate."),

            DayData(week: 1, theme: "Power Under Control", scripture: "Proverbs 16:32",
                devotional: "Whoever is slow to anger is better than the mighty, and he who rules his spirit than he who takes a city. Solomon — a king who commanded armies — says the man who controls his own spirit is stronger than a military conqueror. Think about that. The world celebrates the man who takes the city. God celebrates the man who takes control of himself. Self-control is the most underrated form of strength. It doesn't make the highlight reel. Nobody applauds the man who didn't lose his temper, who didn't retaliate, who didn't say the cutting thing he could have said. But God sees it. And He calls it better than mighty. Every time you choose restraint over reaction, patience over retaliation, measured words over explosive ones — you are exercising a strength that conquerors don't possess. The strongest man in the room isn't the loudest. He's the one who has the most power and uses the least of it unnecessarily.",
                anchor: "Where do I lose control of my spirit most often — anger, impatience, sharp words, emotional withdrawal? What triggers it?",
                arrow: "The next time you feel your temper rise or impatience surge today, pause for ten seconds before responding. Let self-control be your strength."),

            DayData(week: 1, theme: "The Cross: Strength Redefined", scripture: "1 Corinthians 1:18",
                devotional: "The word of the cross is folly to those who are perishing, but to us who are being saved it is the power of God. The cross looked like defeat. A king without a throne, nailed to wood, mocked by soldiers, abandoned by friends. By every worldly metric, the crucifixion was weakness on display. But Paul calls it the power of God. The most powerful act in human history looked nothing like what the world calls power. Jesus could have called legions of angels. He could have stepped off the cross. He could have destroyed His accusers with a word. He had all the strength in the universe — and He stayed. He endured. He absorbed the wrath meant for you and didn't fight back. That is strength. Not because He couldn't — but because He chose not to. The strongest thing Jesus ever did wasn't a miracle. It was staying on the cross when He had every right and ability to come down. Love held Him there. And love redefines everything we thought we knew about strength.",
                anchor: "Have I truly let the cross redefine my understanding of strength? Where am I still operating on the world's definition instead of Christ's?",
                arrow: "Choose one moment today to stay instead of flee, to absorb instead of retaliate, to endure instead of escape — and recognize that staying is the stronger move."),

            DayData(week: 1, theme: "Strength to Be Vulnerable", scripture: "2 Corinthians 12:9",
                devotional: "My grace is sufficient for you, for my power is made perfect in weakness. The world says vulnerability is a liability. God says it's the access point for His power. Most men spend their entire lives constructing a fortress of competence, independence, and control — and then wonder why they feel isolated, exhausted, and spiritually dry. The fortress keeps people out. It also keeps God's power out. Paul discovered something counter-intuitive: when he stopped hiding his weakness and started boasting in it, God's power showed up in ways his own strength never could. Vulnerability isn't oversharing. It's the courage to be known — to let someone see the real version of you, not the curated one. It takes more strength to say 'I'm struggling' than to say 'I'm fine.' It takes more courage to ask for help than to suffer in silence. The strong man the world builds is armored and alone. The strong man God builds is open and surrounded.",
                anchor: "What am I hiding behind my strength? What would break open if I admitted weakness to God and to a trusted brother?",
                arrow: "Tell one person the truth about how you're actually doing today. Not the polished version. The real one. Let vulnerability be an act of strength."),

            DayData(week: 1, theme: "Strength in Restraint", scripture: "James 1:19-20",
                devotional: "Let every person be quick to hear, slow to speak, slow to anger; for the anger of man does not produce the righteousness of God. James gives three speeds: quick, slow, slow. Quick to hear — lean in, pay attention, listen before you formulate your response. Slow to speak — don't fill every silence, don't need to have the last word, let your words be few and purposeful. Slow to anger — not never angry, but slow to arrive there. Anger isn't always sin — Jesus was angry. But human anger, James says, doesn't produce God's righteousness. It produces wreckage. The strong man isn't the one with the quickest comeback or the loudest voice. He's the one who listens so well that when he finally speaks, his words carry weight because they were chosen carefully. Restraint is a muscle most men have never trained. We're trained to react — quickly, decisively, forcefully. But James inverts the order. Listen first. Speak second. And let anger come last, if at all.",
                anchor: "Am I quick to listen, or quick to speak? Where is my speed inverted — reacting fast when I should be listening slow?",
                arrow: "Practice James 1:19 in one conversation today. Listen twice as long as you speak. Let the other person finish completely before you respond. Notice what changes."),

            DayData(week: 1, theme: "Week 1 Review", scripture: "Philippians 2:5-8",
                devotional: "Have this mind among yourselves, which is yours in Christ Jesus, who, though he was in the form of God, did not count equality with God a thing to be grasped, but emptied himself, by taking the form of a servant, being born in the likeness of men. And being found in human form, he humbled himself by becoming obedient to the point of death, even death on a cross. The most powerful being in existence emptied Himself. He didn't grasp. He released. He didn't ascend. He descended. He didn't demand service. He became a servant. This is the mind Paul says should be in you — not a mindset you manufacture, but the mind of Christ that reshapes how you think about everything. Week 1 was about redefining strength. Gentle, not harsh. Controlled, not explosive. Vulnerable, not armored. Restrained, not reactive. The cross, not the throne. Did you let Christ's definition replace the world's this week? Where did the old definition fight back? Where did the new one break through? Strength in love isn't a theory. It's a daily choice to let Christ's mind govern your actions.",
                anchor: "How has my understanding of strength shifted this week? Where did I practice Christ's strength instead of the world's? Where did I fall back?",
                arrow: "Tell a brother one specific moment this week where you chose restraint, gentleness, or vulnerability over the world's version of strength. Name what it cost you."),

            // MARK: Week 2 — Strength to Serve

            DayData(week: 2, theme: "The Towel and the Basin", scripture: "John 13:4-5",
                devotional: "He laid aside his outer garments, and taking a towel, tied it around his waist. Then he poured water into a basin and began to wash the disciples' feet. Before Jesus went to the cross, He washed feet. Before He demonstrated the ultimate strength of dying for the world, He demonstrated the daily strength of serving the people in front of Him. The towel and the basin weren't beneath Him — they were the truest expression of who He was. He laid aside His garments — His status, His comfort, His rights — and picked up the tools of a servant. Every man faces this choice daily. Will you lay aside your pride, your convenience, your desire to be served — and pick up the towel? Service isn't something strong men do when they have time left over. It's the primary expression of their strength. The strongest man at the dinner table isn't the one at the head. It's the one clearing the plates. The world will never understand this. But the men who follow Jesus will.",
                anchor: "What would it look like for me to lay aside my garments — my status, my pride, my comfort — and pick up the towel today?",
                arrow: "Do the most menial task in your household today without being asked. Dishes, laundry, cleaning — whatever is beneath your pride. That's where strength lives."),

            DayData(week: 2, theme: "Strength to Serve Your Wife", scripture: "Ephesians 5:25",
                devotional: "Husbands, love your wives, as Christ loved the church and gave himself up for her. Christ gave Himself up. That's the model for how a man loves his wife — not what he gets from her, but what he gives for her. Most men default to one of two failures: they either dominate (using strength to control) or they disengage (withholding strength entirely). Neither is love. Christ-like love is active, sacrificial, and costly. It means putting her needs ahead of yours — not occasionally when it's convenient, but as a lifestyle. It means listening when you'd rather fix. Serving when you'd rather sit. Engaging emotionally when you'd rather retreat. The strongest thing you can do in your marriage isn't win the argument. It's lay down your weapons and serve. If you're not married, apply this to your closest relationship — the person God has placed in your life who needs your sacrificial strength, not your convenient affection.",
                anchor: "Am I serving my wife or closest relationship sacrificially, or only when it's easy? What would 'giving myself up' look like today?",
                arrow: "Ask your wife or closest person: 'What's one thing I could do today that would really help you?' Then do it — fully, without complaint, as an act of love."),

            DayData(week: 2, theme: "Carry Each Other's Burdens", scripture: "Galatians 6:2",
                devotional: "Bear one another's burdens, and so fulfill the law of Christ. The law of Christ is love — and love carries weight. Not theoretically. Physically, emotionally, practically. When your brother is crushed under a burden he can't carry alone, the strong man doesn't say 'I'll pray for you' from a safe distance. He walks over, gets under the load, and helps him carry it. Burden-bearing is costly. It means your schedule gets interrupted. Your energy gets spent on someone else's crisis. Your comfort gets sacrificed for another man's survival. But Paul says this is how you fulfill the law of Christ. Not by attending church. Not by reading your Bible in isolation. By actually bearing weight that doesn't belong to you — because Christ bore weight that didn't belong to Him. Every burden you carry for another man is an echo of the cross. It costs you something. And in the cost, Christ is visible.",
                anchor: "Who around me is carrying a burden too heavy for one man? Am I willing to get under it with them, or am I keeping a safe distance?",
                arrow: "Reach out to one person today who is struggling. Don't just say 'let me know if you need anything.' Offer something specific — a meal, an hour of help, a phone call tonight."),

            DayData(week: 2, theme: "Go Last", scripture: "Mark 9:35",
                devotional: "If anyone would be first, he must be last of all and servant of all. Jesus doesn't say 'consider being last sometimes.' He says must. The path to first is through last. The way up is down. The door to greatness opens when you stop trying to walk through it ahead of everyone else. Going last is not natural for men. We're wired to compete, to lead the pack, to get there first. And sometimes leadership means being out front. But the heart posture Jesus demands is one that doesn't need to be first. Doesn't need the best seat. Doesn't need to be recognized, thanked, or noticed. Going last means letting your wife choose the restaurant. Letting your coworker take the credit. Letting the younger man speak first. Serving the meal before you eat. It's a thousand tiny deaths to ego that, compounded over time, produce a man who looks remarkably like Jesus — powerful, secure, and completely unconcerned with his own status.",
                anchor: "Where am I jockeying for first — for recognition, for the best position, for credit? What would going last look like in my daily life?",
                arrow: "Choose to go last in three situations today — let someone go ahead of you in line, at work, in conversation. Do it consciously as an act of strength, not defeat."),

            DayData(week: 2, theme: "Strength to Ask Forgiveness", scripture: "Matthew 5:23-24",
                devotional: "If you are offering your gift at the altar and there remember that your brother has something against you, leave your gift there before the altar and go. First be reconciled to your brother. Jesus says something stunning here: your worship can wait. Reconciliation can't. It takes strength to forgive someone who wronged you. But it takes even more strength to go to someone you wronged and make it right. Your pride will scream at you the entire way. You'll want to minimize what you did. You'll want to explain your side. You'll want to wait until they come to you first. But Jesus doesn't give you that option. He says go. Don't wait for them. Don't rehearse your defense. Go and be reconciled. The strong man isn't just the man who forgives. He's the man who asks for forgiveness — humbly, specifically, without excuses. He owns what he did, names the harm, and asks for grace. That's vulnerability and strength fused together. And it heals what nothing else can.",
                anchor: "Is there someone I've wronged who I haven't gone to? What's keeping me from making it right — pride, fear, or the hope that they'll just forget?",
                arrow: "If someone comes to mind that you've hurt or wronged, reach out today. Don't defend. Don't explain. Just own it and ask forgiveness. Go first."),

            DayData(week: 2, theme: "Strength to Forgive", scripture: "Colossians 3:13",
                devotional: "Bearing with one another and, if one has a complaint against another, forgiving each other; as the Lord has forgiven you, so you also must forgive. Forgiveness is not weakness. It is one of the most strenuous exercises of strength a man can perform. It requires you to absorb a cost you didn't incur, release a debt you're owed, and give grace to someone who may not deserve it. Everything in your flesh screams against it. They hurt you. They betrayed you. They should pay. But Paul doesn't give you an option — he gives you a mirror. As the Lord has forgiven you. When you remember how much you've been forgiven, the debts others owe you shrink. Unforgiveness feels like holding someone in prison, but you're the one locked in the cell. The bitter man thinks he's punishing the offender. He's actually punishing himself — carrying poison and hoping the other person dies from it. Forgiveness breaks the chain. It takes enormous strength to release someone who owes you. But that's exactly what Christ did for you.",
                anchor: "Who am I refusing to forgive? What bitterness am I carrying that's poisoning me more than the person who hurt me?",
                arrow: "Pray for someone who wronged you today — not a quick prayer, a real one. Ask God for the strength to release them. You don't have to feel it yet. Choose it."),

            DayData(week: 2, theme: "Week 2 Review", scripture: "Mark 10:45",
                devotional: "The Son of Man came not to be served but to serve, and to give his life as a ransom for many. Jesus summarized His entire mission in one sentence: serve and give. Not build and acquire. Not lead and be honored. Serve and give. That's the model. And it cost Him everything. Week 2 was about the strength it takes to serve — to wash feet, to serve your wife sacrificially, to carry another man's burden, to go last, to forgive when everything in you wants to hold on. Service is not the soft option. It's the strongest thing a man can do because it requires him to override every self-preserving instinct he has. Did you pick up the towel this week? Did you go last? Did you serve someone at cost to yourself? Did you forgive? If you did, you've tasted something the world can't manufacture — the strength that comes from living like Jesus. If you struggled, you're in good company. The disciples struggled too. Keep going.",
                anchor: "Where did I serve well this week? Where did I resist? What did it cost me — and was the cost worth it?",
                arrow: "Share one act of service from this week with a brother. Not to get credit — to encourage him to do the same. Service multiplies when it's shared."),

            // MARK: Week 3 — Strength to Endure

            DayData(week: 3, theme: "The Long Obedience", scripture: "Hebrews 12:1-2",
                devotional: "Let us run with endurance the race that is set before us, looking to Jesus, the founder and perfecter of our faith, who for the joy that was set before him endured the cross. The Christian life is not a sprint. It's a marathon — and the writer of Hebrews says the fuel is endurance, not enthusiasm. Most men start strong. They come to Christ with fire. They dive into the Word. They commit to their marriage. They show up for their kids. Then the grind sets in. The feelings fade. The results slow down. And quietly, imperceptibly, they begin to drift. Endurance isn't glamorous. It's showing up on day three hundred with the same faithfulness you had on day one. It's reading the Word when you feel nothing. It's loving your wife when the romance is thin. It's praying when heaven feels silent. Jesus endured the cross — not because it felt good, but because joy was set before Him. He could see past the pain to the purpose. That's endurance: strength that outlasts the feeling.",
                anchor: "Where am I tempted to quit because the results have slowed or the feeling has faded? What would endurance look like in that specific area?",
                arrow: "Do one thing today that you've been tempted to stop doing — a spiritual discipline, a relational commitment, a hard obedience. Show up even though you don't feel like it."),

            DayData(week: 3, theme: "Joy in Trials", scripture: "James 1:2-4",
                devotional: "Count it all joy, my brothers, when you meet trials of various kinds, for you know that the testing of your faith produces steadfastness. And let steadfastness have its full effect, that you may be perfect and complete, lacking in nothing. James doesn't say feel joyful when everything falls apart. He says count it — reckon it, account for it, categorize it as joy. It's a decision, not an emotion. You can choose to see your trial as a random disaster, or you can choose to see it as a crucible that's producing something in you that comfort never could. Steadfastness. Completeness. A man who lacks nothing because he's been tested and proven. The trial isn't the enemy. Quitting during the trial is. Every hardship you endure with faith intact makes you stronger — not the world's kind of stronger, but the kind of strong that can't be shaken because it was forged in fire. The man who has been through the furnace and came out still standing? That's the man other men trust with their lives.",
                anchor: "What trial am I currently in? Can I honestly count it as joy — not because it feels good, but because of what God is producing in me through it?",
                arrow: "Write down one good thing that has come from your hardest season. Thank God for it specifically. Let gratitude reframe the trial."),

            DayData(week: 3, theme: "Sabbath as Strength", scripture: "Exodus 20:8-10",
                devotional: "Remember the Sabbath day, to keep it holy. Six days you shall labor, and do all your work, but the seventh day is a Sabbath to the Lord your God. Rest is a command, not a suggestion. And for most men, it's the hardest command to obey. Because rest feels like weakness. Like you're falling behind. Like someone else is outworking you while you sit still. But God didn't design rest as a reward for finishing everything — He designed it as a rhythm for sustaining everything. The Sabbath principle says: you are not the engine that keeps the world running. God is. And one day a week, you are commanded to stop and remember that. The man who cannot rest is not strong — he's anxious. He's running from something. He's trying to earn something rest would force him to receive for free. Sabbath rest is an act of trust: God, I believe that if I stop, You don't stop. I believe that my value isn't measured by my output. I believe rest is strength, not retreat.",
                anchor: "Do I practice genuine rest, or is my rest just a different form of productivity? Am I afraid to stop? What am I really running from?",
                arrow: "Set aside a block of time today — even one hour — with no productivity. No screens, no tasks, no agenda. Rest as an act of obedience, not laziness."),

            DayData(week: 3, theme: "Rest Without Guilt", scripture: "Mark 6:31",
                devotional: "Come away by yourselves to a desolate place and rest a while. Jesus said this to the disciples when they were so busy they didn't even have time to eat. Ministry was exploding. People needed them. The harvest was urgent. And Jesus said: stop. Come away. Rest. He didn't say 'push through.' He didn't say 'you'll rest when the work is done.' He initiated the rest. He commanded it. Most men feel guilty when they rest because they've tied their worth to their productivity. If I'm not doing something, I'm wasting something. If I'm sitting still, someone else is getting ahead. But Jesus models a different rhythm: intense engagement followed by intentional withdrawal. He worked. Then He rested. He served. Then He retreated to pray. He poured out. Then He refilled. The man who never rests isn't more spiritual — he's more depleted. And a depleted man has nothing left to give the people who need him most. Rest isn't the enemy of strength. It's the replenishment of it.",
                anchor: "Do I feel guilty when I rest? What lie about productivity am I believing that keeps me from the rest Jesus commands?",
                arrow: "Take a real break today — guilt-free, fully disengaged from work and responsibility. Let Jesus' command to 'come away and rest' be your permission."),

            DayData(week: 3, theme: "Faithfulness Over Feelings", scripture: "Galatians 6:9",
                devotional: "Let us not grow weary of doing good, for in due season we will reap, if we do not give up. In due season. Not in your season. Not on your timeline. God's. The gap between sowing and reaping is where most men quit. You do the right thing and nothing changes. You love your wife sacrificially and she doesn't notice. You pray for months and the situation doesn't move. You serve faithfully and nobody thanks you. The feelings of futility set in. What's the point? But Paul says the reaping is coming — if you don't give up. The harvest doesn't arrive because you felt like continuing. It arrives because you refused to stop. Faithfulness is strength that doesn't depend on feedback. It's the farmer who waters the soil whether he sees a sprout or not. It's the man who does the right thing regardless of whether anyone celebrates it. Feelings fluctuate. Faithfulness compounds. And the man who is still standing in due season is the man who kept going when everything said stop.",
                anchor: "Where am I growing weary of doing good because I haven't seen the harvest yet? What would faithfulness over feelings look like today?",
                arrow: "Do one faithful thing today that you've been tempted to abandon — a prayer, a habit, a commitment — not because you feel like it, but because you refuse to quit."),

            DayData(week: 3, theme: "Strength in Waiting", scripture: "Isaiah 40:31",
                devotional: "They who wait for the Lord shall renew their strength; they shall mount up with wings like eagles; they shall run and not be weary; they shall walk and not faint. Waiting is not passive. In Hebrew, the word for 'wait' here means to bind together — like twisting strands into a rope. Waiting on God is the active process of binding yourself to Him while the answer hasn't come yet. Most men don't struggle with action. They struggle with waiting. The gap between prayer and answer. The silence between the promise and the fulfillment. The desert between where you are and where God said you'd be. We fill the gap with striving, with backup plans, with forcing doors open that God hasn't opened yet. But Isaiah says the man who waits — who refuses to run ahead of God — receives renewed strength. Not depleted strength from trying harder. Renewed strength from trusting deeper. Eagles don't flap frantically. They find the current and rise. That's what waiting on God does — it lifts you on a strength that isn't yours.",
                anchor: "Where am I running ahead of God instead of waiting for Him? What door am I trying to force open that He hasn't opened yet?",
                arrow: "Identify one area where you've been striving instead of waiting. Consciously release it to God today and practice active trust — binding yourself to Him instead of your timeline."),

            DayData(week: 3, theme: "Week 3 Review", scripture: "Romans 5:3-5",
                devotional: "We rejoice in our sufferings, knowing that suffering produces endurance, and endurance produces character, and character produces hope, and hope does not put us to shame, because God's love has been poured into our hearts through the Holy Spirit. Paul traces a chain: suffering leads to endurance, endurance leads to character, character leads to hope, and hope is anchored by God's love poured into your heart. Every link in the chain is forged under pressure. You can't get to hope without character. You can't get to character without endurance. You can't get to endurance without suffering. Week 3 was about the strength to endure — running the long race, finding joy in trials, resting in Sabbath rhythm, staying faithful when feelings fade, and waiting on God's timing. Endurance isn't sexy. It doesn't trend. But it produces something nothing else can: a man of tested character whose hope is unshakeable because it's rooted in love, not circumstances. Did you endure this week? Did you rest? Did you stay faithful? The chain is being forged. Don't break it.",
                anchor: "What link in the chain — suffering, endurance, character, hope — am I currently in? How am I responding to the pressure that's forging it?",
                arrow: "Share with a brother where you are in the Romans 5 chain right now. Let him speak into your endurance. Iron sharpens iron — especially in the fire."),

            // MARK: Week 4 — All in Love

            DayData(week: 4, theme: "Love Is Patient", scripture: "1 Corinthians 13:4a",
                devotional: "Love is patient. Paul begins his definition of love with patience — and that's no accident. Patience is the foundation on which every other expression of love is built. Impatience says 'you're not moving fast enough for me.' Patience says 'I will give you the time you need because you matter more than my schedule.' Most men are impatient by default. Impatient with their wife's processing speed. Impatient with their children's learning curve. Impatient with God's timeline. Impatient with their own growth. But love — real love, Christ-like love — absorbs delay without resentment. It waits without punishing. It endures slowness without withdrawing. Patience isn't gritting your teeth through inconvenience. It's genuinely valuing the person more than the pace. When you're patient with someone, you're telling them with your actions: you are worth my time, my energy, and my waiting. That message changes people. It changed you when God was patient with you.",
                anchor: "Who or what am I most impatient with? What would love — real, patient love — look like in that specific situation?",
                arrow: "Choose the person or situation that tests your patience most today and deliberately respond with patience. Not tolerance — love. Give them the gift of unhurried attention."),

            DayData(week: 4, theme: "Love Is Kind", scripture: "1 Corinthians 13:4b",
                devotional: "Love is kind. Kindness is love with its work boots on. It's not a feeling — it's an action. Patient love waits. Kind love moves. It sees a need and meets it. It sees an opportunity to encourage and takes it. It sees someone struggling and steps in — not because it has to, but because love can't help itself. Kindness is severely undervalued in modern masculinity. Men are taught to be tough, competitive, ambitious. Kindness is for the soft. But Jesus was the kindest person who ever lived — and He was anything but soft. He touched lepers. He spoke to outcasts. He noticed the overlooked woman in the crowd. He made children feel welcome when the disciples tried to shoo them away. Kindness in a strong man is devastating. Not because it's unexpected — but because it reveals what strength is actually for. Strength exists to make kindness possible. Without strength, kindness is just niceness. With strength, kindness becomes love in action.",
                anchor: "Am I kind — actively, deliberately kind — to the people closest to me? Or do I save my best behavior for strangers and give my family the leftovers?",
                arrow: "Perform three deliberate acts of kindness today — one for a family member, one for a friend, and one for a stranger. Let kindness be your strength's expression."),

            DayData(week: 4, theme: "Love Does Not Insist on Its Own Way", scripture: "1 Corinthians 13:5",
                devotional: "Love does not insist on its own way; it is not irritable or resentful. Three devastating diagnostics in one verse. Insisting on your own way — the need to be right, to have the final word, to get your preference. Irritability — the short fuse, the sigh, the edge in your voice that tells everyone around you they're inconveniencing you. Resentment — the mental ledger of wrongs committed against you, the score you keep even when you say you've forgiven. Every man struggles with at least one of these. Most struggle with all three. Love dismantles them — not by suppressing them, but by replacing self at the center with someone else. When you stop insisting on your own way, you create space for others to flourish. When you let go of irritability, you become safe to be around. When you release resentment, you become free. Love isn't the absence of preference. It's the willingness to set your preference aside because the person in front of you matters more than being right.",
                anchor: "Which of the three — insistence, irritability, or resentment — has the strongest grip on me right now? Where is it showing up most?",
                arrow: "Catch yourself in one moment of insistence, irritability, or resentment today and consciously choose the opposite. Yield. Soften. Release. That's love in action."),

            DayData(week: 4, theme: "Love in Brotherhood", scripture: "1 John 3:16-18",
                devotional: "By this we know love, that he laid down his life for us, and we ought to lay down our lives for the brothers. But if anyone has the world's goods and sees his brother in need, yet closes his heart against him, how does God's love abide in him? Little children, let us not love in word or talk but in deed and in truth. John makes love tangible. Love isn't a sentiment — it's a sacrifice. And he brings it down from the grand to the practical: you don't have to die for your brother today, but do you see his need? Do you have the resources to help? Then why is your heart closed? Brotherhood in the body of Christ is supposed to be the most radical community on earth — men who actually lay down their lives for each other. Not just say 'praying for you, bro' and move on. Men who show up with a meal when your marriage is failing. Men who drive over at midnight when the temptation is crushing. Men who open their wallet when your rent is short. Love in deed. Love in truth. Not love in word only.",
                anchor: "Am I loving my brothers in deed and truth, or in word only? Where is my heart closed when I have the means to help?",
                arrow: "Look for a tangible need in a brother's life today and meet it — no announcement, no expectation of return. Let love be an action, not just a feeling."),

            DayData(week: 4, theme: "Love for the Difficult", scripture: "Matthew 5:44",
                devotional: "Love your enemies and pray for those who persecute you. This is the command that separates Christ-like love from every other kind. Anyone can love people who love them back. Jesus said even the pagans do that. But loving someone who has hurt you, betrayed you, slandered you, or actively works against you — that requires supernatural strength. It requires a love that doesn't originate in you. You cannot generate enemy-love from your own heart. Your heart wants justice, payback, vindication. But Christ's love — the love that was poured into your heart by the Holy Spirit — can do what your natural love never could. It can pray a genuine blessing over someone who cursed you. It can extend grace to someone who extended harm. It can refuse to retaliate when retaliation is fully justified. This isn't doormat love. It's the most powerful force in the universe — the same love that prayed 'Father, forgive them' from the cross. That love is in you. Use it.",
                anchor: "Who is hardest for me to love right now? What would it cost me to genuinely pray for their good — not their punishment?",
                arrow: "Pray a real blessing over someone who has hurt or frustrated you. Not a performative prayer — ask God to genuinely bless them. Feel the strength it requires. That's love."),

            DayData(week: 4, theme: "Love as Legacy", scripture: "John 13:34-35",
                devotional: "A new commandment I give to you, that you love one another: just as I have loved you, you also are to love one another. By this all people will know that you are my disciples, if you have love for one another. Jesus didn't say the world would know His followers by their theology, their morality, their political positions, or their worship style. He said they'd be known by their love. Love is the badge. Love is the testimony. Love is the legacy. When your children are grown and think about what kind of man their father was, they won't remember your sermons. They'll remember how you treated their mother. They'll remember your patience when they failed. They'll remember whether you were safe to come to with their worst moments. Your legacy is not what you accomplished — it's how you loved. The man who is remembered as strong and loving has left a legacy that echoes for generations. Not because he was perfect, but because the people closest to him felt the weight of his love every single day.",
                anchor: "If the people closest to me were asked 'what was he like?' — would love be the first word they'd use? What needs to change for that to be true?",
                arrow: "Tell someone you love today — out loud, specifically — what they mean to you. Don't assume they know. Words of love spoken are stronger than words of love assumed."),

            DayData(week: 4, theme: "Week 4 Review", scripture: "1 John 4:19",
                devotional: "We love because he first loved us. Everything starts here. You didn't generate this love. You didn't earn it. You didn't discover it. You received it — from a God who loved you before you were lovable, who pursued you before you turned around, who gave His Son before you asked. Every act of patience, kindness, forgiveness, service, and sacrificial love you've practiced in this journey is an echo of the love that came to you first. You are not the source. You are the channel. And the more you stay connected to the source, the more love flows through you without you having to manufacture it. Week 4 was about letting love be the filter for everything — patience, kindness, releasing insistence, loving the difficult, building a legacy of love. Did you let love lead? Did you love when it cost you something? Did you let God's love for you reshape how you love others? This is the capstone. Love is the crown of strength.",
                anchor: "How has God's love reshaped my love this week? Where did His love flow through me to someone who needed it?",
                arrow: "Write down three moments from this week where love led your actions. Share them with a brother. Then commit to making love the default, not the exception."),

            // MARK: Days 29-30 — Completion

            DayData(week: 4, theme: "Love Never Fails", scripture: "1 Corinthians 13:8a",
                devotional: "Love never fails. Three words. The most absolute statement in all of Paul's writing. Everything else ends. Prophecies cease. Tongues are stilled. Knowledge passes away. But love never fails. Never. Not sometimes. Not usually. Never. Your career will end. Your strength will fade. Your achievements will be forgotten. But the love you showed — the patience you gave your wife on a hard Tuesday, the kindness you showed a stranger, the forgiveness you extended when you didn't have to, the service you rendered when no one was watching — that love echoes into eternity. It changes the people it touches. It shapes the generations that follow. It reflects the character of the God who is love. You spent thirty days redefining strength, learning to serve, building endurance, and letting love lead everything. This isn't a program you completed. It's the man you're becoming. Strength in love isn't a phase. It's a life. And love never — ever — fails.",
                anchor: "Looking back over thirty days, how has 'be strong' and 'do everything in love' fused together into one calling? What is different about the man I am now?",
                arrow: "Share your complete journey with your circle or a trusted brother. Hold nothing back — the breakthroughs and the failures. Your honesty will encourage them to start."),

            DayData(week: 4, theme: "Strength in Love — Always", scripture: "1 Corinthians 16:13-14",
                devotional: "Be watchful, stand firm in the faith, act like men, be strong. Let all that you do be done in love. You began this journey with these two verses. You end with them — but you hear them differently now. Be strong — not the world's strength, but Christ's. Gentle, not harsh. Restrained, not explosive. Vulnerable, not armored. Enduring, not quitting. Resting, not striving. Let all that you do be done in love — not sentimental love, but sacrificial love. Patient love. Kind love. Love that forgives. Love that serves. Love that goes last. Love that carries burdens. Love that endures when everything says stop. Love that persists when the feeling fades. Love that never fails. This is the man God is building. Not a man of raw power, but a man of consecrated strength — strength aimed, directed, and delivered through love. Every morning for the rest of your life, you wake up to the same calling: be strong. Do it all in love. That's the whole thing. That's the man. Go be him.",
                anchor: "What is my one-sentence commitment as a man of strength in love? Write it. Say it out loud. Let it define every day that follows.",
                arrow: "Identify one man who needs this journey. Invite him today. The strongest thing a strong man can do is raise up another one — in love."),

        ]

        return data.enumerated().map { index, item in
            JourneyDay(
                id: index + 1,
                week: item.week,
                theme: item.theme,
                scripture: item.scripture,
                devotional: item.devotional,
                anchorPrompt: item.anchor,
                arrowPrompt: item.arrow,
                isUnlocked: index == 0,
                completedDate: nil
            )
        }
    }

    // MARK: - Guard the Gates Journey (30 Days in Nehemiah & 1 Peter 5)
    private static func guardTheGatesJourneyDays() -> [JourneyDay] {
        struct DayData {
            let week: Int
            let theme: String
            let scripture: String
            let devotional: String
            let anchor: String
            let arrow: String
        }

        let data: [DayData] = [

            // MARK: Week 1 — Guard Your Heart

            DayData(week: 1, theme: "The Watchman's Call", scripture: "1 Peter 5:8",
                devotional: "Be sober-minded; be watchful. Your adversary the devil prowls around like a roaring lion, seeking someone to devour. Peter doesn't suggest watchfulness. He commands it. And he tells you why — because you have an enemy, and that enemy is hunting. Not wandering aimlessly. Hunting. Seeking someone to devour. The word 'devour' means to swallow whole — not wound, not inconvenience, but consume entirely. Most men live completely unaware. They scroll through life with their guard down, their gates wide open, assuming the enemy will announce himself before he attacks. He won't. Lions don't roar before they pounce — they roar after the kill. The roar Peter describes is the sound of destruction already in motion. A watchman doesn't wait for the attack to respond. He stands on the wall before the enemy arrives. He scans the horizon. He knows the terrain. He sounds the alarm before the breach, not after. For thirty days, you're going to learn what it means to guard the gates — your heart, your home, your brothers, and the mission God has given you.",
                anchor: "Where are my gates wide open right now? What am I letting in — or letting slide — because I haven't been watching?",
                arrow: "Identify the one gate in your life that's most unguarded today. Name it specifically. Then stand on it — consciously, deliberately — for the rest of the day."),

            DayData(week: 1, theme: "Above All Else", scripture: "Proverbs 4:23",
                devotional: "Keep your heart with all vigilance, for from it flow the springs of life. Solomon says 'above all else' — not among other things, not when you get around to it. Above everything. Guard your heart. Why? Because your heart is the headwaters. Everything downstream — your words, your actions, your relationships, your legacy — flows from what's in your heart. Pollute the source, and everything it feeds is contaminated. Most men guard the wrong things. They guard their reputation, their schedule, their finances, their career. Those matter. But none of them are the source. Your heart is the source. What you allow into your heart — the thoughts you entertain, the images you consume, the narratives you believe — becomes the water supply for your entire life. A man who guards his career but neglects his heart will eventually lose both. A man who guards his heart will find that everything else flows clean. Vigilance isn't paranoia. It's the disciplined awareness that what enters your heart doesn't stay there — it flows out into everything you touch.",
                anchor: "What have I been allowing into my heart unchecked — thoughts, media, conversations, habits? What's polluting the headwaters?",
                arrow: "Audit your inputs today. One thing you watched, read, or listened to this week that you know doesn't belong — cut it. Guard the source."),

            DayData(week: 1, theme: "The Gatekeeper's Eyes", scripture: "Psalm 101:3",
                devotional: "I will not set before my eyes anything that is worthless. David made a decision before the temptation arrived. He didn't say 'I'll try to avoid worthless things.' He said 'I will not set before my eyes.' It was a pre-made commitment — a gate locked in advance. Most men fail at purity, integrity, and mental health not because they're weak in the moment of temptation, but because they never decided in advance what they would and wouldn't look at. The battle is lost before it begins because the gate was never closed. Your eyes are the primary gate to your heart. What you look at shapes what you think about. What you think about shapes what you desire. What you desire shapes what you do. The chain is unbreakable — but it can be interrupted at the first link. Guard your eyes and you guard the entire chain. David didn't have a smartphone. He didn't have infinite scroll. He didn't have algorithm-driven content designed to hijack his attention. You do. Which means your gatekeeping must be more intentional than his ever needed to be.",
                anchor: "What am I setting before my eyes that David would have called worthless? What have I normalized that I should have rejected?",
                arrow: "Make one concrete decision about your eyes today — a screen time limit, an app restriction, a content boundary. Lock the gate before the temptation arrives."),

            DayData(week: 1, theme: "Guarding Your Thought Life", scripture: "2 Corinthians 10:5",
                devotional: "We destroy arguments and every lofty opinion raised against the knowledge of God, and take every thought captive to obey Christ. Paul uses military language — destroy, captive. This is not passive meditation. It's active warfare. Thoughts don't just drift through your mind harmlessly. They set up camp. They build arguments. They raise themselves up against what you know to be true about God. Left unchallenged, a thought becomes a belief, a belief becomes a pattern, and a pattern becomes a prison. Taking a thought captive means intercepting it before it settles. It means recognizing a lie the moment it enters — 'you're not enough,' 'God doesn't care,' 'this sin won't hurt anyone,' 'you deserve this' — and dragging it into the light of Christ. Does this thought obey Christ? Does it align with what God has said? If not, it doesn't get to stay. It doesn't get a seat at the table. It gets captured and dismissed. The man who doesn't guard his thought life will be governed by it. The man who takes every thought captive governs his own mind under Christ's authority.",
                anchor: "What recurring thought has been setting up camp in my mind unchallenged? What lie have I been entertaining as if it were truth?",
                arrow: "The next time a destructive thought enters your mind today, stop it immediately. Say out loud: 'That doesn't obey Christ.' Replace it with a specific truth from Scripture."),

            DayData(week: 1, theme: "The Gate of Your Mouth", scripture: "Proverbs 13:3",
                devotional: "Whoever guards his mouth preserves his life; he who opens wide his lips comes to ruin. Your mouth is a gate that swings both directions. It lets things in and it lets things out. And Solomon says the man who guards it preserves his entire life. Not just his reputation — his life. Words are not neutral. They build or they destroy. They heal or they wound. They encourage or they tear down. And once spoken, they cannot be retrieved. The man who speaks without thinking is the man who leaves the gate wide open — and everything that shouldn't escape does. Anger, criticism, gossip, sarcasm, lies, half-truths, careless promises. Every unguarded word is a breach in the wall. But the man who guards his mouth — who pauses before speaking, who weighs his words, who speaks with intention — that man preserves not just himself but everyone in his path. Silence is not weakness. It's often the strongest form of gatekeeping. The most powerful thing you can say is sometimes nothing at all — because you chose restraint over ruin.",
                anchor: "When did my unguarded mouth last cause damage — a careless word, a sharp response, gossip, a promise I didn't keep?",
                arrow: "Before every significant conversation today, pause for three seconds. Ask: 'Does this need to be said? Does it need to be said by me? Does it need to be said now?'"),

            DayData(week: 1, theme: "Guarding Against Compromise", scripture: "1 Corinthians 15:33",
                devotional: "Do not be deceived: 'Bad company ruins good morals.' Paul quotes a Greek poet to make a universal point: the people you allow close to you shape who you become. This isn't about being judgmental or isolating yourself from unbelievers. It's about knowing which voices have influence over your heart — and guarding that access ruthlessly. Compromise never arrives as compromise. It arrives as convenience, as normalcy, as 'everyone does it,' as 'it's not that big a deal.' It arrives through the friend who mocks your faith subtly. Through the coworker who normalizes dishonesty. Through the culture that redefines what God has already defined. The gate of influence is the most dangerous gate because it's the quietest. Nobody storms through it. They drift through it. One conversation at a time. One compromise at a time. One redefined standard at a time. Until the man who once stood firm is standing nowhere — and can't remember when he moved. Guard your influences. Not with fear, but with discernment. Know who shapes you. Choose it deliberately.",
                anchor: "Who has unguarded influence over my heart and mind right now? Are those voices pulling me toward Christ or away from Him?",
                arrow: "Evaluate your three closest influences — friends, media figures, content creators. If any are pulling you from Christ, create distance today. Guard the gate of influence."),

            DayData(week: 1, theme: "Week 1 Review", scripture: "Proverbs 4:23-27",
                devotional: "Keep your heart with all vigilance, for from it flow the springs of life. Put away from you crooked speech, and put devious talk far from you. Let your eyes look directly forward, and your gaze be straight before you. Ponder the path of your feet; then all your ways will be sure. Do not swerve to the right or to the left; turn your foot away from evil. Solomon gives the complete gatekeeping checklist in five verses: guard your heart, guard your mouth, guard your eyes, guard your steps, guard your direction. Week 1 was about learning to guard your heart — the source from which everything flows. You examined your eyes, your thought life, your mouth, and your influences. You identified gates that were wide open and began to close them. Did you catch a thought before it settled? Did you restrict an input that didn't belong? Did you hold your tongue when silence was the stronger choice? Did you create distance from an influence pulling you from Christ? Every gate you closed this week made the wall stronger. Every compromise you refused made the enemy's path harder. You're becoming a watchman. The wall isn't finished. But you're standing on it now.",
                anchor: "Which gate did I guard best this week? Which gate still has the biggest breach? What specific action will I take to reinforce it?",
                arrow: "Share one gatekeeping win from this week with a brother. Then ask him: 'Where are your gates open?' Let accountability flow both directions."),

            // MARK: Week 2 — Guard Your Home

            DayData(week: 2, theme: "Nehemiah's Wall", scripture: "Nehemiah 4:14",
                devotional: "Do not be afraid of them. Remember the Lord, who is great and awesome, and fight for your brothers, your sons, your daughters, your wives, and your homes. Nehemiah was rebuilding the wall of Jerusalem — and the enemies were threatening to stop the work. His response wasn't a strategic retreat or a committee meeting. It was a battle cry: remember God, and fight for your family. Notice what Nehemiah didn't say. He didn't say 'pray about it and hope for the best.' He said fight. There is a time for prayer and a time for picking up a sword. Nehemiah's men did both — they built with one hand and held a weapon with the other. Your home is your wall. Your family is your Jerusalem. And there are forces — cultural, spiritual, relational — that want to breach it. The question isn't whether the attack is coming. It's whether you'll be standing on the wall when it arrives. Fighting for your home isn't aggression. It's vigilance. It's setting the spiritual temperature of your household. It's deciding what enters your home and what doesn't. It's being present — not just physically, but spiritually and emotionally. A man who fights for his home is a man who has decided that nothing gets through the gate without going through him first.",
                anchor: "Am I fighting for my home, or have I left the wall unguarded? What is currently threatening the peace, purity, or direction of my household?",
                arrow: "Do one thing today that 'builds the wall' of your home — a conversation you've been avoiding, a boundary you need to set, a spiritual practice you need to lead. Build with one hand, fight with the other."),

            DayData(week: 2, theme: "Spiritual Leadership at Home", scripture: "Joshua 24:15",
                devotional: "As for me and my house, we will serve the Lord. Joshua didn't take a vote. He didn't say 'as for me and my house, we'll figure it out.' He made a declaration — a stake in the ground — that set the spiritual direction of his entire household. This is what spiritual leadership looks like. It's not perfection. It's direction. Most men are passive in their homes because they're afraid of getting it wrong. They let their wife set the spiritual pace because she's 'better at it.' They avoid leading prayer because it feels awkward. They don't open Scripture with their family because they don't feel qualified. But Joshua wasn't a priest. He was a soldier. And he led his home spiritually because he understood that someone has to set the direction — and God assigned that responsibility to him. Spiritual leadership doesn't require seminary training. It requires willingness. Pray with your wife even if your words stumble. Read Scripture with your kids even if you can't answer every question. Set the direction even if you haven't arrived. Your family doesn't need a perfect leader. They need a present one.",
                anchor: "Am I leading my home spiritually, or have I abdicated? What would it look like to set the direction like Joshua — imperfectly but decisively?",
                arrow: "Lead one spiritual moment in your home today — pray at a meal, read a verse with your wife or kids, or simply say out loud: 'We will serve the Lord.' Start somewhere."),

            DayData(week: 2, theme: "Guarding What Enters Your Home", scripture: "Psalm 101:2-3",
                devotional: "I will walk with integrity of heart within my house; I will not set before my eyes anything that is worthless. David connects personal integrity with household integrity — what he allows in himself directly affects what enters his home. The two are inseparable. Your home has gates: the television, the Wi-Fi router, the conversations at the dinner table, the attitudes that walk through the front door after work. Every one of those gates either lets life in or lets destruction in. You are the gatekeeper. What entertainment standards have you set for your household? What conversations are normal under your roof? What attitudes do you bring home from work? Do you bring peace or tension? Presence or distraction? Faith or anxiety? The enemy doesn't need to breach your front door with something dramatic. He just needs you to leave the gates unmonitored — a show that normalizes what God calls sin, a phone habit that steals your presence, an attitude of irritability that makes your family walk on eggshells. Guard what enters your home the way David guarded his own eyes. Walk with integrity within your house — not just outside it.",
                anchor: "What have I allowed into my home — through screens, attitudes, or habits — that doesn't belong there? What would David remove?",
                arrow: "Walk through your home today with a gatekeeper's eye. Identify one thing — a media source, a habit, an attitude — that needs to go. Remove it or set a boundary around it today."),

            DayData(week: 2, theme: "Present, Not Just Providing", scripture: "Deuteronomy 6:6-7",
                devotional: "These words that I command you today shall be on your heart. You shall teach them diligently to your children, and shall talk of them when you sit in your house, and when you walk by the way, and when you lie down, and when you rise. God's model for fatherhood isn't a weekly lesson. It's a constant presence. When you sit, when you walk, when you lie down, when you rise. Morning, afternoon, evening, night. Faith isn't transferred through a curriculum — it's transferred through proximity. Your kids don't need a lecture. They need you in the room. They need to see how you handle failure. They need to hear how you talk to their mother. They need to watch you pray when things fall apart. They need to witness your faith in real time, not in a sermon once a week. The greatest lie the world tells a father is that providing is enough. It's not. Your children don't need a bigger house — they need you in the house. Your wife doesn't need a better income — she needs you emotionally present, spiritually engaged, consistently available. Provision without presence is abandonment with a paycheck. Guard your home by being in it — fully, presently, with your heart engaged.",
                anchor: "Am I present in my home, or just providing? When I'm home, am I truly there — or is my mind, my phone, my stress somewhere else?",
                arrow: "Give your family one hour of fully present time today. No phone, no screens, no work thoughts. Be in the room — body, mind, and heart. Guard the gate of presence."),

            DayData(week: 2, theme: "Marriage as a Gate to Guard", scripture: "Ecclesiastes 4:12",
                devotional: "A threefold cord is not quickly broken. Your marriage — or your closest covenant relationship — is a gate the enemy attacks relentlessly. Not because he hates your happiness, but because he knows that a unified household is an impenetrable wall, and a divided one is an open gate. Division between husband and wife is the enemy's favorite breach. He doesn't need to destroy you individually if he can split you apart. A harsh word here. An unresolved conflict there. Emotional distance. Unspoken resentment. Slowly, the cord frays — not because anyone pulled hard, but because nobody repaired the small tears. The threefold cord — you, your wife, and God — is not quickly broken. But it can be slowly worn. Guarding your marriage means catching the small fractures before they become chasms. It means apologizing first. It means choosing unity over being right. It means inviting God into the disagreement instead of retreating into silence. If you're not married, apply this to your closest relationship — the person whose unity with you is a wall the enemy wants to breach. Guard the cord. Repair the tears. A unified household is a fortress. A divided one is a target.",
                anchor: "Where is the cord fraying in my closest relationship? What small tear have I ignored that's slowly becoming a breach?",
                arrow: "Address one unresolved tension in your marriage or closest relationship today. Not the whole war — one small repair. Ask: 'Are we OK? Is there something between us?' Guard the cord."),

            DayData(week: 2, theme: "Protecting Peace in Your Home", scripture: "Colossians 3:15",
                devotional: "Let the peace of Christ rule in your hearts, to which indeed you were called in one body. The word 'rule' here means to act as umpire — to make the call, to decide what stays and what goes. Peace isn't the absence of conflict. It's the presence of Christ's authority governing the atmosphere of your home. You set the thermostat. When you walk through the door angry, the house gets cold. When you walk through the door anxious, the house gets tense. When you walk through the door at peace — genuinely anchored in Christ — the house breathes. Your family can feel it. They adjust to your frequency whether you realize it or not. Guarding the peace of your home means guarding your own peace first. You can't export what you don't possess. If you're running on fumes spiritually, your home will feel the deficit. If you're carrying unresolved anger, your family absorbs it. If you're drowning in worry, your kids learn to worry. The most protective thing a man can do for his household is walk through the door with the peace of Christ ruling his own heart. Then let it spill over into every room.",
                anchor: "What am I bringing through the front door — peace or tension? How does my emotional and spiritual state affect the atmosphere of my home?",
                arrow: "Before you walk through your door today, pause. Take thirty seconds to pray: 'Lord, let Your peace rule in me so it can rule in my home.' Then enter as a carrier of peace, not stress."),

            DayData(week: 2, theme: "Week 2 Review", scripture: "Nehemiah 4:9",
                devotional: "We prayed to our God and set a guard as a protection against them day and night. Nehemiah's strategy was beautifully simple: pray and guard. Not pray instead of guard. Not guard instead of pray. Both. Day and night. The spiritual and the practical working together. Week 2 was about guarding your home — fighting for your family like Nehemiah fought for Jerusalem, leading spiritually like Joshua, controlling what enters your household, being present rather than just providing, and protecting the peace of your home. Did you lead a spiritual moment? Did you remove something that didn't belong? Did you show up — truly present — for the people under your roof? Did you bring peace through the door? Your home is the wall you're rebuilding. And Nehemiah's enemies mocked the wall too — they said a fox could knock it down. But the wall got built. Not because the builders were perfect, but because they refused to stop. Pray and guard. That's the formula. Keep building.",
                anchor: "Where did I guard my home well this week? Where did I leave the wall unfinished? What needs my attention next week?",
                arrow: "Ask your wife or a family member: 'How did I do this week as the spiritual leader of our home?' Listen without defending. Let their answer shape next week."),

            // MARK: Week 3 — Guard Your Brothers

            DayData(week: 3, theme: "The Watchman for Others", scripture: "Ezekiel 33:6",
                devotional: "If the watchman sees the sword coming and does not blow the trumpet, so that the people are not warned, and the sword comes and takes any one of them, that person is taken away in his iniquity, but his blood I will require at the watchman's hand. God holds the watchman accountable — not for whether the people listen, but for whether he warns. If you see the sword coming for a brother and stay silent, his blood is on your hands. That's not metaphor. That's God's standard for the men He places on the wall. Most men stay silent because it's easier. Confrontation is uncomfortable. Speaking truth into another man's life feels presumptuous. 'It's not my business' is the coward's theology disguised as respect. But God says it is your business. You are the watchman. If you see a brother drifting toward destruction — financial ruin, moral failure, spiritual apathy, relational collapse — and you say nothing, you have failed your post. This isn't about being judgmental. It's about loving a man enough to risk the relationship for his sake. The watchman who blows the trumpet may not be thanked. But the watchman who stays silent will be held responsible.",
                anchor: "Is there a brother I can see drifting right now that I haven't warned? What's holding me back — fear of rejection, conflict avoidance, or false respect?",
                arrow: "If a specific man came to mind, reach out to him today. Not to lecture — to ask a genuine question: 'How are you really doing?' Let concern open the door that silence has kept shut."),

            DayData(week: 3, theme: "Speaking Truth in Love", scripture: "Ephesians 4:15",
                devotional: "Speaking the truth in love, we are to grow up in every way into him who is the head, into Christ. Truth without love is brutality. Love without truth is sentimentality. Paul says the path to maturity requires both — truth delivered through love, love grounded in truth. Most men err on one side. Some are all truth — blunt, harsh, 'just telling it like it is' with no concern for how the words land. They call it honesty. It's actually laziness — the refusal to do the harder work of packaging truth in a way that can be received. Others are all love — soft, affirming, never willing to say the hard thing because it might create discomfort. They call it kindness. It's actually cowardice — the refusal to risk the relationship for the brother's good. The watchman who guards his brothers speaks truth in love — he says the hard thing, but he says it with tears in his eyes, not a smirk on his face. He confronts because he cares, not because he's right. He risks awkwardness because the alternative is watching a brother walk off a cliff in silence.",
                anchor: "Do I default to truth without love, or love without truth? Who needs me to speak truthfully and lovingly into their life right now?",
                arrow: "Have one honest conversation today that you've been avoiding. Lead with love — 'I care about you, which is why I need to say this' — and then speak the truth. Don't soften it into meaninglessness."),

            DayData(week: 3, theme: "Catching a Brother Before He Falls", scripture: "Galatians 6:1",
                devotional: "Brothers, if anyone is caught in any transgression, you who are spiritual should restore him in a spirit of gentleness. Keep watch on yourself, lest you too be tempted. Paul gives the protocol for when a brother falls: restore, don't condemn. The goal isn't punishment. It's restoration. And the posture isn't superiority — it's gentleness, coupled with self-awareness that you could be next. Notice Paul says 'caught in' — not 'choosing to.' The language implies a snare, a trap. The brother didn't plan to end up there. He drifted. He wasn't watching. The gate was open. And now he's tangled in something he can't escape alone. This is where the watchman proves his worth. Not by standing over the fallen man with a lecture, but by getting down in the pit with him and helping him climb out. Restoration is messy. It requires proximity. It requires patience. It requires a man who says 'I'm not going anywhere — let's get you out of this.' The world abandons the fallen. The kingdom restores them. Be the man who runs toward the wreckage, not away from it.",
                anchor: "When a brother falls, is my instinct to judge or to restore? Am I gentle enough to help and honest enough to keep watch on myself?",
                arrow: "Think of a man who's struggling — everyone knows it, but nobody's moved toward him. Be the one who moves today. A text, a call, a visit. Restore, don't condemn."),

            DayData(week: 3, theme: "Iron Sharpens Iron", scripture: "Proverbs 27:17",
                devotional: "Iron sharpens iron, and one man sharpens another. Sharpening is not gentle. Iron against iron produces friction, heat, sparks. The process is uncomfortable. But the result is a sharper edge — a man more precise, more effective, more dangerous to the enemy. Most men want brotherhood without the friction. They want encouragement without confrontation. Affirmation without accountability. But that's not sharpening — that's coddling. And a coddled man is a dull man. A dull blade is more dangerous than a sharp one because it requires more force and causes more damage through tearing instead of clean cutting. The brother who sharpens you is the brother who tells you the truth when everyone else tells you what you want to hear. He's the one who pushes back on your excuses. Who asks the hard questions. Who refuses to let you coast. He doesn't do it because he enjoys it — he does it because he respects you enough to believe you can handle the friction. Find the men who sharpen you. Submit to the process. Welcome the sparks. And be that man for someone else — because a blade that never meets another blade stays dull forever.",
                anchor: "Who sharpens me? Do I have men in my life who challenge me, or only men who affirm me? Am I sharpening anyone else?",
                arrow: "Ask a trusted brother: 'Where do you see me getting dull?' Give him permission to sharpen you. Then receive it without defensiveness."),

            DayData(week: 3, theme: "Building the Wall Together", scripture: "Nehemiah 4:19-20",
                devotional: "The work is great and widely spread, and we are separated far from one another on the wall. In the place where you hear the sound of the trumpet, rally to us there. Our God will fight for us. Nehemiah's workers were spread out across the wall — each man guarding his section, but connected by the trumpet. When one section was under attack, they didn't fight alone. They rallied. The trumpet called them together. Brotherhood isn't a nice addition to the Christian life — it's the architecture. You cannot guard every gate alone. Your section of the wall has blind spots. There are attacks coming that you won't see until it's too late. You need men on either side of you — close enough to hear the trumpet, committed enough to come running when they do. The isolated man isn't strong. He's exposed. The enemy doesn't attack the part of the wall where the men are gathered. He attacks the gap. He finds the man standing alone, unconnected, unaccountable — and that's where he breaches. Rally to each other. Build in proximity. Fight as a unit. The wall gets built not by individual heroes, but by ordinary men standing shoulder to shoulder.",
                anchor: "Am I connected enough to other men that they'd hear my trumpet? Would they come running? Would I hear theirs?",
                arrow: "Reach out to a brother today and say: 'I need you on the wall with me.' Make a specific plan to connect this week — not abstractly, but with a time and place."),

            DayData(week: 3, theme: "Guarding the Vulnerable", scripture: "Psalm 82:3-4",
                devotional: "Give justice to the weak and the fatherless; maintain the right of the afflicted and the destitute. Rescue the weak and the needy; deliver them from the hand of the wicked. The watchman doesn't just protect those who can protect themselves. He guards the vulnerable — the weak, the fatherless, the afflicted, the destitute. The ones who can't stand on the wall themselves. God's heart has always been for the unprotected. And He delegates that protection to His men. Look around your community, your church, your neighborhood. Who is unguarded? The single mother raising kids alone. The fatherless boy with no man in his life. The elderly neighbor nobody checks on. The new believer with no mentor. The man in your circle who's too proud to ask for help. These are the breaches in the wall that the enemy exploits. And God is looking for watchmen who will stand in the gap — not just for their own families, but for those who have no one standing for them. Guarding the vulnerable isn't charity. It's mandate. It's the very thing that distinguishes the kingdom of God from every system the world builds.",
                anchor: "Who in my community is vulnerable and unguarded? Am I willing to stand in the gap for someone beyond my own household?",
                arrow: "Identify one vulnerable person in your orbit and take one protective action today — a meal, a phone call, an offer of help. Stand in the gap for someone who can't stand for themselves."),

            DayData(week: 3, theme: "Week 3 Review", scripture: "Hebrews 10:24-25",
                devotional: "Let us consider how to stir up one another to love and good works, not neglecting to meet together, as is the habit of some, but encouraging one another. The writer of Hebrews gives the purpose of brotherhood in one verse: stir up, don't neglect, encourage. Three active verbs that describe what it means to guard your brothers. Week 3 was about being the watchman for others — sounding the alarm when a brother drifts, speaking truth in love, restoring the fallen with gentleness, building the wall together, and guarding the vulnerable. Did you reach out to a brother who was drifting? Did you speak a hard truth wrapped in love? Did you rally to someone's section of the wall? Did you stand in the gap for someone vulnerable? The watchman's call is not just personal protection — it's communal vigilance. You're not just guarding your own gates anymore. You're watching the gates of every man standing near you. That's the wall Nehemiah built. That's the wall God is building through you.",
                anchor: "How did I guard my brothers this week? Did I speak up when I should have? Did I show up when it mattered? Where can I do better?",
                arrow: "Send a specific encouragement to three brothers today. Not generic — specific. Tell them what you see God doing in them. Stir them up."),

            // MARK: Week 4 — Guard the Mission

            DayData(week: 4, theme: "From Defense to Offense", scripture: "Matthew 16:18",
                devotional: "I will build my church, and the gates of hell shall not prevail against it. Read that again carefully. It's not the gates of the church that hell is attacking. It's the gates of hell that the church is storming. Jesus' picture of the church is offensive, not defensive. The kingdom doesn't huddle behind walls hoping the enemy doesn't break through. The kingdom advances — and hell's gates can't hold against it. For three weeks you've been learning to guard — your heart, your home, your brothers. That's essential. But guarding is only half the job. The watchman who only plays defense will eventually be overrun. At some point, you have to advance. You have to take ground. You have to storm the gates that hold people captive. The mission isn't survival. It's conquest — not by violence, but by the unstoppable advance of the gospel into every dark corner the enemy occupies. Depression, addiction, hopelessness, broken families, lost men — these are territories the enemy holds. And Jesus says his gates can't hold. Not against a church that's actually moving.",
                anchor: "Have I been playing only defense with my faith? Where is God calling me to go on offense — to advance, not just protect?",
                arrow: "Identify one area where you've been in survival mode spiritually. Choose to advance today — a conversation with an unbeliever, a bold prayer, a step of faith you've been avoiding. Storm the gate."),

            DayData(week: 4, theme: "Guarding Sound Doctrine", scripture: "2 Timothy 4:3-4",
                devotional: "The time is coming when people will not endure sound teaching, but having itching ears they will accumulate for themselves teachers to suit their own passions, and will turn away from listening to the truth and wander into myths. Paul warned Timothy that the day was coming when people would reject truth and choose comfort. That day has arrived. We live in a culture that has redefined love, redesigned gender, rewritten morality, and repackaged sin as freedom. And the most dangerous version of this isn't what the world teaches — it's what the church tolerates. Guarding the mission means guarding the truth the mission is built on. If the foundation shifts, everything built on it collapses. You don't have to be a theologian to guard doctrine. You just have to know what Scripture actually says — not what culture says it says, not what a popular pastor reinterprets it to mean, not what makes you feel comfortable. Read the Word for yourself. Compare every teaching against it. If it contradicts Scripture, it doesn't matter who said it, how many followers they have, or how good it made you feel. The watchman guards truth. Even when truth is unpopular.",
                anchor: "Is my understanding of God built on Scripture or on cultural comfort? Where have I drifted from what the Bible actually teaches?",
                arrow: "Read one chapter of Scripture today with fresh eyes — not through a devotional filter, not through a podcast summary. Read it raw. Let God's Word speak for itself. Guard the source."),

            DayData(week: 4, theme: "Raising Watchmen", scripture: "2 Timothy 2:2",
                devotional: "What you have heard from me in the presence of many witnesses entrust to faithful men, who will be able to teach others also. Paul tells Timothy to multiply — not just learn, but entrust. Not just grow, but raise others who grow. Four generations are embedded in this one verse: Paul taught Timothy, Timothy teaches faithful men, faithful men teach others. The mission isn't complete when you learn to guard the gates. It's complete when you raise other men who can guard them too. The watchman who never trains another watchman leaves the wall unguarded when he's gone. Your son needs to learn what you've learned. The younger man in your church needs what you've been given. The new believer needs a man who's been through the fire to walk with him through his. Discipleship isn't a program. It's the most strategic form of guarding the mission — because it multiplies the number of men on the wall. One watchman is vulnerable. Ten watchmen are a fortress. A hundred watchmen change a city. Every man you raise is another section of the wall that gets built.",
                anchor: "Who am I raising? Is there a younger man, a son, a new believer who needs me to entrust to him what God has entrusted to me?",
                arrow: "Identify one man you could pour into — a son, a younger brother, a new believer. Reach out today with an invitation: 'Let me walk with you.' Start the multiplication."),

            DayData(week: 4, theme: "Salt and Light in a Dark World", scripture: "Matthew 5:13-14",
                devotional: "You are the salt of the earth. You are the light of the world. A city set on a hill cannot be hidden. Jesus doesn't say you should try to be salt and light. He says you are. It's identity, not aspiration. Salt preserves — it stops decay. Light reveals — it exposes what darkness hides. Both are aggressive. Salt doesn't sit in the shaker and hope the food comes to it. Light doesn't hide under a bowl and hope darkness notices. They are deployed. They enter the environment and change it. Guarding the mission means engaging the world — not retreating from it. The watchman who hides in the fortress and never engages the battlefield isn't guarding anything. He's hiding. Your workplace needs salt. Your neighborhood needs light. Your social circles need a man who lives differently — not loudly religious, but quietly transformative. Present where darkness is. Preserving what's decaying. Illuminating what's hidden. You don't guard the mission by building a bunker. You guard it by being deployed into the exact places where salt and light are most needed.",
                anchor: "Where has God deployed me as salt and light? Am I engaging those environments with kingdom influence, or am I hiding my faith?",
                arrow: "Choose one environment today — workplace, gym, neighborhood — and deliberately be salt. Preserve something. Illuminate something. Let your presence change the atmosphere."),

            DayData(week: 4, theme: "Bold Witness", scripture: "Acts 1:8",
                devotional: "You will receive power when the Holy Spirit has come upon you, and you will be my witnesses in Jerusalem and in all Judea and Samaria, and to the end of the earth. Jesus' last words before ascending weren't about comfort, safety, or self-improvement. They were about deployment. You will be my witnesses. Not you might. Not you should consider. You will. And the power to do it doesn't come from your personality, your theological training, or your eloquence. It comes from the Holy Spirit. Most men are silent about their faith because they're afraid of what people will think. They guard their reputation instead of guarding the mission. They'd rather be liked than be faithful. But the mission advances through witness — through men who are willing to say, in ordinary conversations and extraordinary moments, 'Let me tell you what Christ has done.' You don't need a platform. You need a willingness. Your coworker who's going through a divorce needs your witness. Your neighbor who just lost a parent needs your witness. Your friend who's searching for meaning needs your witness. The watchman who guards the mission doesn't hide the message. He declares it — from the wall, to the city, to anyone within earshot.",
                anchor: "When was the last time I shared my faith with someone who doesn't know Christ? What's holding me back — fear, comfort, or pride?",
                arrow: "Ask God for one opportunity to share your faith today. Then watch for it. When it comes, don't overthink it — just tell them what Christ has done for you."),

            DayData(week: 4, theme: "Generational Faithfulness", scripture: "Psalm 78:4-7",
                devotional: "We will tell the coming generation the glorious deeds of the Lord, and his might, and the wonders that he has done. He established a testimony in Jacob and appointed a law in Israel, which he commanded our fathers to teach to their children, that the next generation might know them, the children yet unborn, and arise and tell them to their children, so that they should set their hope in God. Four generations in one passage: fathers, children, grandchildren, and the children yet unborn. This is the longest view of guarding the mission — you're not just protecting what exists today. You're building a wall that stands for generations. The stories you tell your children about God become the foundation of their faith. The standards you hold become the baseline for their convictions. The way you live becomes the template they follow — whether you intend it or not. Every man is building a generational legacy. The question is whether that legacy is intentional or accidental. The watchman who thinks generationally doesn't just guard today's gates. He builds gates that will still be standing when his grandchildren are old enough to guard them. Tell the stories. Establish the testimony. Teach the law. Not because your children will be perfect — but because they need to know what the wall looks like so they can keep building it.",
                anchor: "What story of God's faithfulness in my life have I never told my children or the next generation? What legacy am I building — intentionally or by default?",
                arrow: "Tell one story of God's faithfulness to a younger person today — a child, a nephew, a mentee. Let them see that the God who was faithful to you will be faithful to them."),

            DayData(week: 4, theme: "Standing Against Cultural Drift", scripture: "Romans 12:2",
                devotional: "Do not be conformed to this world, but be transformed by the renewal of your mind, that by testing you may discern what is the will of God, what is good and acceptable and perfect. Cultural drift is the slow, invisible current that pulls you from where God planted you. It doesn't feel like rebellion. It feels like normalcy. Everyone's doing it. Everyone thinks this way. The language shifts. The standards bend. What was unthinkable ten years ago is celebrated today. And most men don't even notice they've moved — because the current carried everyone together. Paul's antidote is active resistance: do not be conformed. That's a fight, not a float. Transformation requires the daily renewal of your mind — washing it in Scripture, testing every cultural assumption against God's Word, refusing to let the world's operating system run your life. Cultural conformity is the default. You don't have to try to drift. You just have to stop resisting. But the watchman resists. He plants his feet. He tests the current. He discerns what's good and what's drift disguised as progress. Standing against cultural drift doesn't make you backward. It makes you anchored.",
                anchor: "Where has cultural drift moved me without my noticing? What standard have I relaxed because 'everyone else has'?",
                arrow: "Identify one area where you've conformed to the world's thinking instead of God's Word. Name it. Repent of it. Renew your mind with the specific Scripture that speaks to it."),

            DayData(week: 4, theme: "Week 4 Review", scripture: "1 Timothy 6:20",
                devotional: "O Timothy, guard the deposit entrusted to you. Guard the deposit. Four words that summarize the entire mission. God has entrusted something to you — the gospel, your faith, your family, your brothers, your calling. It's a deposit. Not something you earned, but something placed in your hands for safekeeping and multiplication. Week 4 was about guarding the mission — going from defense to offense, guarding sound doctrine, raising other watchmen, being salt and light, and standing against cultural drift. Did you advance where you'd been retreating? Did you guard truth when it was unpopular? Did you invest in another man's growth? Did you engage your world as salt and light? Did you resist the current that tries to carry every man downstream? The deposit is in your hands. God trusted you with it. Not because you're qualified — because He's faithful. Guard it with everything you have. And when you're done guarding it, entrust it to another man who will guard it after you.",
                anchor: "What has God entrusted to me — specifically — that I need to guard more fiercely? Am I guarding it, or have I grown careless?",
                arrow: "Write down the deposit God has entrusted to you — your faith, your family, your calling, your brothers. Put it somewhere you'll see it daily. Guard it."),

            // MARK: Days 29-30 — Completion

            DayData(week: 4, theme: "The Watchman's Reward", scripture: "2 Timothy 4:7-8",
                devotional: "I have fought the good fight, I have finished the race, I have kept the faith. Henceforth there is laid up for me the crown of righteousness, which the Lord, the righteous judge, will award to me on that day. Paul's final words to Timothy are the words of a watchman who never left his post. He fought — not perfectly, but faithfully. He finished — not quickly, but completely. He kept the faith — not because it was easy, but because it was entrusted to him. The watchman's reward isn't fame, recognition, or earthly comfort. It's a crown laid up by a righteous judge who sees every silent stand, every guarded gate, every night watch that nobody else knew about. You've spent thirty days learning to guard the gates — your heart, your home, your brothers, and the mission. Some days you guarded well. Some days the gate was breached. But you showed up. You stood on the wall. You blew the trumpet. You fought the good fight. The race isn't over. The faith still needs keeping. But you are no longer the man who left the gates wide open. You are a watchman. And the Lord who entrusted the deposit to you will reward the faithfulness with which you guarded it.",
                anchor: "When I look back over thirty days, what gates did I close that were wide open? What did it cost me — and what did it protect?",
                arrow: "Share your complete Guard the Gates journey with a brother. The wins and the failures. Your transparency will encourage him to step onto the wall himself."),

            DayData(week: 4, theme: "Guard the Gates — Always", scripture: "1 Peter 5:8-9",
                devotional: "Be sober-minded; be watchful. Your adversary the devil prowls around like a roaring lion, seeking someone to devour. Resist him, firm in your faith, knowing that the same kinds of suffering are being experienced by your brotherhood throughout the world. You began with this verse. You end with it — but you hear it differently now. Be watchful — not because you're paranoid, but because you're positioned. You know what the gates are. You know where the breaches happen. You know what the enemy targets. Your heart — the source from which everything flows. Guard it with all vigilance. Your home — the wall your family lives behind. Fight for it like Nehemiah. Your brothers — the men standing on either side of you. Sound the trumpet for them. The mission — the deposit entrusted to you. Guard it, advance it, multiply it. Resist him. Not in your own strength, but firm in your faith. And know this: you're not alone. The same fight is being fought by your brotherhood throughout the world. Men on every continent, in every time zone, standing on the wall. You are one of them. The gates are guarded. Stay on the wall. Stay watchful. Stay firm. Guard the gates — always.",
                anchor: "What is my one-sentence commitment as a watchman? Write it. Say it out loud. Let it define how you live from this day forward.",
                arrow: "Identify one man who needs to start this journey. Invite him today. The wall needs more watchmen — and you're the one who can put him on it."),

        ]

        return data.enumerated().map { index, item in
            JourneyDay(
                id: index + 1,
                week: item.week,
                theme: item.theme,
                scripture: item.scripture,
                devotional: item.devotional,
                anchorPrompt: item.anchor,
                arrowPrompt: item.arrow,
                isUnlocked: index == 0,
                completedDate: nil
            )
        }
    }

    // MARK: - Today's Prompt
    /// Combined prompt pool — originals + extended content
    static var allAnchorPrompts: [AnchorPrompt] {
        anchorPrompts + PromptLibrary.extraAnchorPrompts
    }

    static var allArrowPrompts: [ArrowPrompt] {
        arrowPrompts + PromptLibrary.extraArrowPrompts
    }

    static func anchorPromptForToday() -> AnchorPrompt {
        let all = allAnchorPrompts
        precondition(!all.isEmpty, "anchorPrompts must not be empty")
        let dayOfYear = max(1, Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1)
        return all[(dayOfYear - 1) % all.count]
    }

    static func arrowPromptForToday() -> ArrowPrompt {
        let all = allArrowPrompts
        precondition(!all.isEmpty, "arrowPrompts must not be empty")
        let dayOfYear = max(1, Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1)
        return all[(dayOfYear - 1) % all.count]
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
