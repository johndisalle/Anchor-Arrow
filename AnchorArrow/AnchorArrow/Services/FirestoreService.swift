// FirestoreService.swift
// All Firestore read/write operations

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

// MARK: - FirestoreService
class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()

    private init() {}

    // MARK: - Collection Refs
    private func userRef(_ uid: String) -> DocumentReference {
        db.collection("users").document(uid)
    }

    private func entriesRef(_ uid: String) -> CollectionReference {
        db.collection("users").document(uid).collection("entries")
    }

    private func driftRef(_ uid: String) -> CollectionReference {
        db.collection("users").document(uid).collection("driftLogs")
    }

    private func circlesRef() -> CollectionReference {
        db.collection("circles")
    }

    private func circlePostsRef(_ circleId: String) -> CollectionReference {
        db.collection("circles").document(circleId).collection("posts")
    }

    private func commentsRef(circleId: String, postId: String) -> CollectionReference {
        db.collection("circles").document(circleId).collection("posts").document(postId).collection("comments")
    }

    // MARK: - User CRUD

    /// Create user document on sign-up
    func createUser(uid: String, email: String, displayName: String) async throws {
        let user = AppUser(
            uid: uid,
            email: email,
            displayName: displayName,
            joinDate: Date()
        )
        try userRef(uid).setData(from: user, merge: false)
    }

    /// Fetch user document; creates one if missing
    func fetchUser(uid: String) async throws -> AppUser {
        let doc = try await userRef(uid).getDocument()
        if doc.exists {
            return try doc.data(as: AppUser.self)
        } else {
            // First-time sign-in via Apple may not have called createUser
            let email = Auth.auth().currentUser?.email ?? ""
            let name = Auth.auth().currentUser?.displayName ?? "Warrior"
            let user = AppUser(uid: uid, email: email, displayName: name, joinDate: Date())
            try userRef(uid).setData(from: user, merge: false)
            return user
        }
    }

    /// Update user fields
    func updateUser(uid: String, fields: [String: Any]) async throws {
        try await userRef(uid).updateData(fields)
    }

    /// Listen to user document in real-time
    func listenToUser(uid: String, completion: @escaping (Result<AppUser, Error>) -> Void) -> ListenerRegistration {
        userRef(uid).addSnapshotListener { snapshot, error in
            if let error { completion(.failure(error)); return }
            guard let snapshot else { return }
            do {
                let user = try snapshot.data(as: AppUser.self)
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Daily Entries

    /// Fetch today's entry (or nil if not yet started)
    func fetchTodayEntry(uid: String) async throws -> DailyEntry? {
        let docId = Date().entryDateString
        let doc = try await entriesRef(uid).document(docId).getDocument()
        guard doc.exists else { return nil }
        return try doc.data(as: DailyEntry.self)
    }

    /// Save/update daily entry
    func saveEntry(uid: String, entry: DailyEntry) async throws {
        let docId = entry.dateString
        try entriesRef(uid).document(docId).setData(from: entry, merge: true)
    }

    /// Fetch last N entries for stats
    func fetchRecentEntries(uid: String, limit: Int = 60) async throws -> [DailyEntry] {
        let snapshot = try await entriesRef(uid)
            .order(by: "date", descending: true)
            .limit(to: limit)
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            do { return try doc.data(as: DailyEntry.self) }
            catch {
                #if DEBUG
                print("[Firestore] Failed to decode entry \(doc.documentID): \(error.localizedDescription)")
                #endif
                return nil
            }
        }
    }

    /// Fetch entries for streak calendar
    func fetchEntriesInRange(uid: String, from: Date, to: Date) async throws -> [DailyEntry] {
        let snapshot = try await entriesRef(uid)
            .whereField("date", isGreaterThanOrEqualTo: from)
            .whereField("date", isLessThanOrEqualTo: to)
            .order(by: "date")
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            do { return try doc.data(as: DailyEntry.self) }
            catch {
                #if DEBUG
                print("[Firestore] Failed to decode entry \(doc.documentID): \(error.localizedDescription)")
                #endif
                return nil
            }
        }
    }

    // MARK: - Streak Management

    struct StreakResult {
        let streak: Int
        let graceDayBurned: Bool
    }

    /// Recalculate and update streak after entry completion.
    /// Premium users get one grace day per 30-day period — a missed day that doesn't break the streak.
    @discardableResult
    func updateStreak(uid: String) async throws -> StreakResult {
        let entries = try await fetchRecentEntries(uid: uid, limit: 120)
        // Use dateString for timezone-agnostic day comparisons
        let activeDateStrings = Set(
            entries
                .filter { $0.anchorCompleted || $0.arrowCompleted }
                .map { $0.dateString }
        )

        let user = try await fetchUser(uid: uid)
        let today = Calendar.current.startOfDay(for: Date())

        var streak = 0
        var checkDate = today
        var usedGraceDay = false
        let graceDayAvailable = user.hasGraceDayAvailable

        while true {
            if activeDateStrings.contains(checkDate.entryDateString) {
                streak += 1
                guard let prev = Calendar.current.date(byAdding: .day, value: -1, to: checkDate) else { break }
                checkDate = prev
            } else if graceDayAvailable && !usedGraceDay && checkDate != today && streak > 0 {
                // Grace day: skip this gap, don't increment streak count
                usedGraceDay = true
                guard let prev = Calendar.current.date(byAdding: .day, value: -1, to: checkDate) else { break }
                checkDate = prev
            } else {
                break
            }
        }

        let totalAnchor = entries.filter { $0.anchorCompleted }.count
        let totalArrow  = entries.filter { $0.arrowCompleted }.count

        var updates: [String: Any] = [
            "currentStreak": streak,
            "totalAnchorDays": totalAnchor,
            "totalArrowDays": totalArrow,
            "lastEntryDate": Timestamp(date: Date())
        ]

        if streak > user.longestStreak {
            updates["longestStreak"] = streak
        }

        // Burn the grace day if it was used
        if usedGraceDay {
            updates["graceDayUsedDate"] = Timestamp(date: Date())
            if user.graceDayPeriodStart == nil ||
               (Calendar.current.dateComponents([.day], from: user.graceDayPeriodStart!, to: Date()).day ?? 0) >= 30 {
                updates["graceDayPeriodStart"] = Timestamp(date: Date())
            }
        }

        try await updateUser(uid: uid, fields: updates)
        return StreakResult(streak: streak, graceDayBurned: usedGraceDay)
    }

    // MARK: - Drift Logs

    func saveDriftLog(uid: String, log: DriftLog) async throws {
        try driftRef(uid).addDocument(from: log)
    }

    func fetchDriftLogs(uid: String, limit: Int = 50) async throws -> [DriftLog] {
        let snapshot = try await driftRef(uid)
            .order(by: "timestamp", descending: true)
            .limit(to: limit)
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            do { return try doc.data(as: DriftLog.self) }
            catch {
                #if DEBUG
                print("[Firestore] Failed to decode drift log \(doc.documentID): \(error.localizedDescription)")
                #endif
                return nil
            }
        }
    }

    func driftLogCount(uid: String) async throws -> Int {
        let query = driftRef(uid)
        let snapshot = try await query.count.getAggregation(source: .server)
        return Int(truncating: snapshot.count)
    }

    // MARK: - Badges

    func awardBadge(uid: String, badgeType: BadgeType) async throws {
        let updates: [String: Any] = [
            "badges": FieldValue.arrayUnion([badgeType.rawValue])
        ]
        try await updateUser(uid: uid, fields: updates)
    }

    /// Check and award any newly earned badges
    func evaluateAndAwardBadges(uid: String, entry: DailyEntry? = nil) async throws {
        let user = try await fetchUser(uid: uid)
        let driftCount = try await driftLogCount(uid: uid)
        let currentBadges = Set(user.badges)

        for badgeType in BadgeType.allCases {
            if !currentBadges.contains(badgeType.rawValue) &&
               badgeType.shouldEarn(user: user, entry: entry, driftCount: driftCount) {
                try await awardBadge(uid: uid, badgeType: badgeType)
            }
        }
    }

    // MARK: - Circles

    func createCircle(circle: Circle) async throws -> String {
        let ref = try circlesRef().addDocument(from: circle)
        return ref.documentID
    }

    func fetchCircle(circleId: String) async throws -> Circle {
        let doc = try await circlesRef().document(circleId).getDocument()
        return try doc.data(as: Circle.self)
    }

    func leaveCircle(circleId: String, uid: String) async throws {
        try await circlesRef().document(circleId).updateData([
            "memberIds": FieldValue.arrayRemove([uid])
        ])
    }

    /// Delete a circle. Only the creator should call this.
    /// Deletes the circle document first (critical), then best-effort cleans subcollections.
    func deleteCircle(circleId: String) async throws {
        // 1. Delete the circle document first — this is what matters
        try await circlesRef().document(circleId).delete()

        // 2. Best-effort cleanup of orphaned subcollections
        //    These run after the circle is already gone. If they fail, no harm —
        //    orphaned docs are invisible and can be cleaned up via Cloud Functions.
        Task {
            do {
                let posts = try await circlePostsRef(circleId).getDocuments()
                for postDoc in posts.documents {
                    let comments = try await commentsRef(circleId: circleId, postId: postDoc.documentID).getDocuments()
                    let batch = db.batch()
                    comments.documents.forEach { batch.deleteDocument($0.reference) }
                    batch.deleteDocument(postDoc.reference)
                    try await batch.commit()
                }
            } catch {
                #if DEBUG
                print("[Firestore] Subcollection cleanup failed (non-fatal): \(error.localizedDescription)")
                #endif
            }
        }
    }

    func fetchMemberNames(memberIds: [String]) async throws -> [String: String] {
        var names: [String: String] = [:]
        try await withThrowingTaskGroup(of: (String, String).self) { group in
            for uid in memberIds {
                group.addTask {
                    let doc = try await self.db.collection("users").document(uid).getDocument()
                    let name = (doc.data()?["displayName"] as? String) ?? "A Brother"
                    return (uid, name)
                }
            }
            for try await (uid, name) in group {
                names[uid] = name
            }
        }
        return names
    }

    /// Fetches accountability profiles for all circle members in parallel.
    /// Returns streak, activity status, and display name — enough for the Battle Formation card.
    func fetchMemberProfiles(memberIds: [String]) async throws -> [String: MemberProfile] {
        var profiles: [String: MemberProfile] = [:]
        try await withThrowingTaskGroup(of: (String, MemberProfile).self) { group in
            for uid in memberIds {
                group.addTask {
                    let doc = try await self.db.collection("users").document(uid).getDocument()
                    let data = doc.data() ?? [:]
                    let name = (data["displayName"] as? String) ?? "A Brother"
                    let streak = (data["currentStreak"] as? Int) ?? 0
                    let lastEntry = (data["lastEntryDate"] as? Timestamp)?.dateValue()
                    return (uid, MemberProfile(uid: uid, displayName: name,
                                               currentStreak: streak, lastEntryDate: lastEntry))
                }
            }
            for try await (uid, profile) in group {
                profiles[uid] = profile
            }
        }
        return profiles
    }

    func markPrayerAnswered(circleId: String, postId: String) async throws {
        try await circlePostsRef(circleId).document(postId).updateData(["isAnswered": true])
    }

    func fetchComments(circleId: String, postId: String) async throws -> [CircleComment] {
        let snapshot = try await commentsRef(circleId: circleId, postId: postId)
            .order(by: "timestamp", descending: false)
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            do { return try doc.data(as: CircleComment.self) }
            catch {
                #if DEBUG
                print("[Firestore] Failed to decode comment \(doc.documentID): \(error.localizedDescription)")
                #endif
                return nil
            }
        }
    }

    func postComment(comment: CircleComment) async throws {
        var sanitized = comment
        sanitized.content = String(sanitized.content
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .prefix(1000))
        guard !sanitized.content.isEmpty else { return }
        try commentsRef(circleId: sanitized.circleId, postId: sanitized.postId).addDocument(from: sanitized)
    }

    func fetchUserCircles(uid: String) async throws -> [Circle] {
        let snapshot = try await circlesRef()
            .whereField("memberIds", arrayContains: uid)
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            do { return try doc.data(as: Circle.self) }
            catch {
                #if DEBUG
                print("[Firestore] Failed to decode circle \(doc.documentID): \(error.localizedDescription)")
                #endif
                return nil
            }
        }
    }

    /// Fetch public circles that the user hasn't already joined
    func fetchPublicCircles(excludingUid uid: String) async throws -> [Circle] {
        let snapshot = try await circlesRef()
            .whereField("isPublic", isEqualTo: true)
            .order(by: "createdAt", descending: true)
            .limit(to: 30)
            .getDocuments()
        return snapshot.documents
            .compactMap { doc in
                do { return try doc.data(as: Circle.self) }
                catch {
                    #if DEBUG
                    print("[Firestore] Failed to decode public circle \(doc.documentID): \(error.localizedDescription)")
                    #endif
                    return nil
                }
            }
            .filter { !$0.memberIds.contains(uid) }
    }

    /// Join a public circle directly (no invite code needed)
    func joinPublicCircle(circleId: String, uid: String) async throws -> Circle {
        let doc = try await circlesRef().document(circleId).getDocument()
        var circle = try doc.data(as: Circle.self)

        guard circle.isPublic else { throw CircleError.invalidCode }
        guard circle.memberCount < 8 else { throw CircleError.full }
        guard !circle.memberIds.contains(uid) else { throw CircleError.alreadyMember }

        try await circlesRef().document(circleId).updateData([
            "memberIds": FieldValue.arrayUnion([uid])
        ])

        circle.memberIds.append(uid)
        return circle
    }

    func joinCircle(code: String, uid: String) async throws -> Circle {
        let snapshot = try await circlesRef()
            .whereField("inviteCode", isEqualTo: code.uppercased())
            .limit(to: 1)
            .getDocuments()

        guard let doc = snapshot.documents.first else {
            throw CircleError.invalidCode
        }

        var circle = try doc.data(as: Circle.self)
        guard let circleId = circle.id else { throw CircleError.invalidCode }

        guard circle.memberCount < 8 else { throw CircleError.full }
        guard !circle.memberIds.contains(uid) else { throw CircleError.alreadyMember }

        try await circlesRef().document(circleId).updateData([
            "memberIds": FieldValue.arrayUnion([uid])
        ])

        circle.memberIds.append(uid)
        return circle
    }

    func fetchCirclePosts(circleId: String, limit: Int = 30) async throws -> [CirclePost] {
        let snapshot = try await circlePostsRef(circleId)
            .order(by: "timestamp", descending: true)
            .limit(to: limit)
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            do { return try doc.data(as: CirclePost.self) }
            catch {
                #if DEBUG
                print("[Firestore] Failed to decode circle post \(doc.documentID): \(error.localizedDescription)")
                #endif
                return nil
            }
        }
    }

    func postToCircle(post: CirclePost) async throws {
        var sanitized = post
        sanitized.content = String(sanitized.content
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .prefix(2000))
        guard !sanitized.content.isEmpty else { return }
        try circlePostsRef(sanitized.circleId).addDocument(from: sanitized)
    }

    func reactToPost(circleId: String, postId: String, emoji: String) async throws {
        try await circlePostsRef(circleId).document(postId).updateData([
            "reactions.\(emoji)": FieldValue.increment(Int64(1))
        ])
    }

    /// Pin a post to the top of a circle feed (leader only). Unpins any previously pinned post.
    func pinPost(circleId: String, postId: String) async throws {
        // Unpin all existing pinned posts first
        let pinned = try await circlePostsRef(circleId)
            .whereField("isPinned", isEqualTo: true)
            .getDocuments()
        for doc in pinned.documents {
            try await circlePostsRef(circleId).document(doc.documentID).updateData(["isPinned": false])
        }
        // Pin the selected post
        try await circlePostsRef(circleId).document(postId).updateData(["isPinned": true])
    }

    func unpinPost(circleId: String, postId: String) async throws {
        try await circlePostsRef(circleId).document(postId).updateData(["isPinned": false])
    }

    // MARK: - Moderation

    /// Delete a single post and all its comments
    func deletePost(circleId: String, postId: String) async throws {
        let comments = try await commentsRef(circleId: circleId, postId: postId).getDocuments()
        if !comments.documents.isEmpty {
            let batch = db.batch()
            comments.documents.forEach { batch.deleteDocument($0.reference) }
            try await batch.commit()
        }
        try await circlePostsRef(circleId).document(postId).delete()
    }

    /// Delete a single comment
    func deleteComment(circleId: String, postId: String, commentId: String) async throws {
        try await commentsRef(circleId: circleId, postId: postId).document(commentId).delete()
    }

    /// Report a post or comment for moderation review
    func submitReport(reporterId: String, circleId: String, postId: String,
                      commentId: String? = nil, reason: String) async throws {
        let data: [String: Any] = [
            "reporterId": reporterId,
            "circleId": circleId,
            "postId": postId,
            "commentId": commentId as Any,
            "reason": reason,
            "status": "pending",
            "timestamp": Timestamp(date: Date())
        ]
        try await db.collection("reports").addDocument(data: data)
    }

    /// Report a user block event to the developer (Apple Guideline 1.2)
    func submitBlockReport(reporterId: String, blockedUid: String) async throws {
        let data: [String: Any] = [
            "reporterId": reporterId,
            "blockedUserId": blockedUid,
            "reason": "User blocked — content hidden from reporter's feed",
            "type": "block",
            "status": "pending",
            "timestamp": Timestamp(date: Date())
        ]
        try await db.collection("reports").addDocument(data: data)
    }

    // MARK: - Account Deletion (cascade)

    /// Deletes all user data from Firestore before the Auth account is removed.
    /// Order: leave circles → delete entries → delete drift logs → delete user doc.
    func deleteUserData(uid: String) async throws {
        // 1. Remove from every circle the user belongs to
        let circles = (try? await fetchUserCircles(uid: uid)) ?? []
        for circle in circles {
            if let circleId = circle.id {
                try? await leaveCircle(circleId: circleId, uid: uid)
            }
        }

        // 2. Delete entries subcollection in batches (Firestore max 500/batch)
        let entryDocs = try await entriesRef(uid).getDocuments()
        if !entryDocs.documents.isEmpty {
            let batch = db.batch()
            entryDocs.documents.forEach { batch.deleteDocument($0.reference) }
            try await batch.commit()
        }

        // 3. Delete driftLogs subcollection
        let driftDocs = try await driftRef(uid).getDocuments()
        if !driftDocs.documents.isEmpty {
            let batch = db.batch()
            driftDocs.documents.forEach { batch.deleteDocument($0.reference) }
            try await batch.commit()
        }

        // 4. Delete user document last
        try await userRef(uid).delete()
    }

    // MARK: - Block / Unblock Users

    func blockUser(uid: String, blockedUid: String) async throws {
        try await updateUser(uid: uid, fields: [
            "blockedUserIds": FieldValue.arrayUnion([blockedUid])
        ])
    }

    func unblockUser(uid: String, blockedUid: String) async throws {
        try await updateUser(uid: uid, fields: [
            "blockedUserIds": FieldValue.arrayRemove([blockedUid])
        ])
    }

    /// Fetch display names for a list of UIDs (used for Blocked Users list)
    func fetchUserNames(uids: [String]) async throws -> [String: String] {
        var names: [String: String] = [:]
        try await withThrowingTaskGroup(of: (String, String).self) { group in
            for uid in uids {
                group.addTask {
                    let doc = try await self.db.collection("users").document(uid).getDocument()
                    let data = doc.data() ?? [:]
                    let name = (data["displayName"] as? String)
                        ?? (data["email"] as? String)
                        ?? "A Brother"
                    return (uid, name.isEmpty ? "A Brother" : name)
                }
            }
            for try await (uid, name) in group {
                names[uid] = name
            }
        }
        return names
    }

    // MARK: - Custom Drift Categories (Premium)
    func saveCustomDriftCategories(uid: String, categories: [String]) async throws {
        try await updateUser(uid: uid, fields: ["customDriftCategories": categories])
    }

    // MARK: - Premium flag
    func setPremium(uid: String, isPremium: Bool, expiry: Date?) async throws {
        var updates: [String: Any] = ["isPremium": isPremium]
        if let expiry {
            updates["premiumExpiry"] = Timestamp(date: expiry)
        } else {
            updates["premiumExpiry"] = FieldValue.delete()
        }
        try await updateUser(uid: uid, fields: updates)
    }

    // MARK: - Journey
    func updateJourney(uid: String, day: Int, startDate: Date?, series: JourneySeries? = nil) async throws {
        var updates: [String: Any] = [
            "journeyActive": true,
            "journeyDay": day
        ]
        if let start = startDate {
            updates["journeyStartDate"] = Timestamp(date: start)
        }
        if let series {
            updates["journeySeries"] = series.rawValue
        }
        try await updateUser(uid: uid, fields: updates)
    }

    /// Abandon a journey in progress without marking it complete
    func abandonJourney(uid: String) async throws {
        try await updateUser(uid: uid, fields: [
            "journeyActive": false,
            "journeyDay": 0
        ])
    }

    /// Mark a journey series as completed and deactivate
    func completeJourney(uid: String, series: JourneySeries) async throws {
        try await updateUser(uid: uid, fields: [
            "journeyActive": false,
            "completedJourneys": FieldValue.arrayUnion([series.rawValue])
        ])
    }

    // MARK: - Global Brotherhood

    /// The well-known document ID for the Global Brotherhood circle
    static let globalCircleId = "global_brotherhood"

    /// Posts today's devotional to the Global Brotherhood if not already posted today.
    func seedGlobalBrotherhoodPost() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let circleId = Self.globalCircleId
        let today = Date().entryDateString  // e.g. "2026-03-31"

        // Check if today's devotional already exists (use today's date as doc ID to prevent duplicates)
        let postRef = circlePostsRef(circleId).document("daily_\(today)")
        do {
            let doc = try await postRef.getDocument()
            if doc.exists { return } // Already posted today

            let devotionals = DevotionalLibrary.dailyDevotionals
            let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
            let devotional = devotionals[(dayOfYear - 1) % devotionals.count]

            let data: [String: Any] = [
                "circleId": circleId,
                "authorId": uid,
                "authorName": "Daily Anchor",
                "content": devotional,
                "type": "general",
                "isAnonymous": false,
                "timestamp": Timestamp(date: Date()),
                "reactions": [:] as [String: Int],
                "isAnswered": false,
                "isPinned": true
            ]
            try await postRef.setData(data)
        } catch {
            #if DEBUG
            print("[GlobalBrotherhood] Failed to seed daily post: \(error.localizedDescription)")
            #endif
        }
    }

    static let dailyDevotionals: [String] = [
        "\"Be watchful, stand firm in the faith, act like men, be strong.\" — 1 Cor 16:13\n\nWhat does it mean to 'act like men' today? It's not about toughness — it's about responsibility. Where is God asking you to step up?",
        "\"Iron sharpens iron, and one man sharpens another.\" — Proverbs 27:17\n\nWho is sharpening you right now? If the answer is 'no one,' that's the drift talking. Reach out to a brother today.",
        "\"The Lord is my shepherd; I shall not want.\" — Psalm 23:1\n\nWhat are you trying to provide for yourself that only God can give? Surrender it. He's already ahead of you.",
        "\"Watch and pray so that you will not fall into temptation.\" — Matthew 26:41\n\nJesus didn't say 'try harder.' He said watch and pray. What are you watching for today? What are you praying against?",
        "\"Be strong and courageous. Do not be afraid; do not be discouraged, for the Lord your God will be with you wherever you go.\" — Joshua 1:9\n\nCourage isn't the absence of fear. It's moving forward anyway because God is with you. Where do you need courage today?",
        "\"He who began a good work in you will carry it on to completion.\" — Philippians 1:6\n\nYou're not finished. Neither is God. The fact that you're here, anchoring, proves the work is still happening.",
        "\"Whoever walks with the wise becomes wise, but the companion of fools will suffer harm.\" — Proverbs 13:20\n\nLook at your inner circle. Are they pulling you toward Christ or away from Him? This circle exists because isolation kills.",
        "\"No temptation has overtaken you except what is common to mankind.\" — 1 Cor 10:13\n\nYou're not the only one fighting this. Every brother in this circle knows the battle. You're not alone.",
        "\"Let all that you do be done in love.\" — 1 Cor 16:14\n\nStrength without love is just aggression. How will you lead with love today — at home, at work, in your circle?",
        "\"Create in me a clean heart, O God, and renew a right spirit within me.\" — Psalm 51:10\n\nDavid didn't hide his mess. He brought it to God. What do you need to bring to Him today?",
        "\"The righteous man falls seven times, and rises again.\" — Proverbs 24:16\n\nFalling isn't the problem. Staying down is. If you drifted yesterday, get back up. That's what righteous men do.",
        "\"Do not be conformed to this world, but be transformed by the renewal of your mind.\" — Romans 12:2\n\nWhat is the world telling you today that contradicts what God says about you? Reject the lie. Anchor into truth.",
        "\"As iron sharpens iron, so one man sharpens the face of his friend.\" — Proverbs 27:17\n\nToday's challenge: send a message to one brother. Ask how he's really doing. Don't settle for 'fine.'",
        "\"Trust in the Lord with all your heart, and do not lean on your own understanding.\" — Proverbs 3:5\n\nSelf-reliance is the quiet drift. Where are you leaning on your own understanding instead of His?",
        "\"Greater love has no one than this: to lay down one's life for one's friends.\" — John 15:13\n\nYou don't have to die for someone today. But you can sacrifice your time, your pride, your comfort. That's the arrow.",
        "\"But the fruit of the Spirit is love, joy, peace, patience, kindness, goodness, faithfulness, gentleness, self-control.\" — Galatians 5:22-23\n\nWhich fruit is hardest for you right now? That's where the Spirit wants to grow you.",
        "\"Put on the full armor of God, so that you can take your stand against the devil's schemes.\" — Ephesians 6:11\n\nThe armor isn't optional. Truth, righteousness, peace, faith, salvation, the Word. Which piece are you missing today?",
        "\"Come to me, all who labor and are heavy laden, and I will give you rest.\" — Matthew 11:28\n\nStrength isn't grinding harder. Sometimes it's stopping and letting God carry it. What burden do you need to lay down?",
        "\"Above all else, guard your heart, for everything you do flows from it.\" — Proverbs 4:23\n\nWhat did you let into your heart this week that shouldn't be there? Guard the gates, brother.",
        "\"Therefore encourage one another and build one another up.\" — 1 Thessalonians 5:11\n\nLeave an encouraging word for a brother in this circle today. Your words might be the anchor someone needs.",
        "\"I have fought the good fight, I have finished the race, I have kept the faith.\" — 2 Timothy 4:7\n\nYou're not at the finish line yet. But every day you anchor and loose your arrow, you're running the race. Keep going.",
    ]

    /// Ensures the Global Brotherhood circle exists and the user is a member.
    /// Creates it on first-ever call; adds the user if not already a member.
    func ensureGlobalCircleMembership(uid: String) async -> String? {
        let ref = circlesRef().document(Self.globalCircleId)
        do {
            let doc = try await ref.getDocument()
            guard doc.exists else {
                return "Global Brotherhood circle not found in Firestore."
            }
            let memberIds = (doc.data()?["memberIds"] as? [String]) ?? []
            if !memberIds.contains(uid) {
                try await ref.updateData([
                    "memberIds": FieldValue.arrayUnion([uid])
                ])
            }
            return nil
        } catch {
            return "Global Brotherhood error: \(error.localizedDescription)"
        }
    }
}

// MARK: - CircleError
enum CircleError: LocalizedError {
    case invalidCode
    case full
    case alreadyMember

    var errorDescription: String? {
        switch self {
        case .invalidCode:    return "That invite code doesn't match any circle."
        case .full:           return "This circle is full (8 members max)."
        case .alreadyMember:  return "You're already in this circle."
        }
    }
}
