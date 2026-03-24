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

    // MARK: - Today's Prompt
    static func anchorPromptForToday() -> AnchorPrompt {
        let count = anchorPrompts.count
        precondition(count > 0, "anchorPrompts must not be empty")
        let dayOfYear = max(1, Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1)
        return anchorPrompts[(dayOfYear - 1) % count]
    }

    static func arrowPromptForToday() -> ArrowPrompt {
        let count = arrowPrompts.count
        precondition(count > 0, "arrowPrompts must not be empty")
        let dayOfYear = max(1, Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1)
        return arrowPrompts[(dayOfYear - 1) % count]
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
