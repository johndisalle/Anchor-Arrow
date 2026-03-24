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
        return snapshot.documents.compactMap { try? $0.data(as: DailyEntry.self) }
    }

    /// Fetch entries for streak calendar
    func fetchEntriesInRange(uid: String, from: Date, to: Date) async throws -> [DailyEntry] {
        let snapshot = try await entriesRef(uid)
            .whereField("date", isGreaterThanOrEqualTo: from)
            .whereField("date", isLessThanOrEqualTo: to)
            .order(by: "date")
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: DailyEntry.self) }
    }

    // MARK: - Streak Management

    /// Recalculate and update streak after entry completion.
    /// Premium users get one grace day per 30-day period — a missed day that doesn't break the streak.
    func updateStreak(uid: String) async throws {
        let entries = try await fetchRecentEntries(uid: uid, limit: 120)
        let activeDates = Set(
            entries
                .filter { $0.anchorCompleted || $0.arrowCompleted }
                .map { Calendar.current.startOfDay(for: $0.date) }
        )

        let user = try await fetchUser(uid: uid)
        let today = Calendar.current.startOfDay(for: Date())

        var streak = 0
        var checkDate = today
        var usedGraceDay = false
        let graceDayAvailable = user.hasGraceDayAvailable

        while true {
            if activeDates.contains(checkDate) {
                streak += 1
                checkDate = Calendar.current.date(byAdding: .day, value: -1, to: checkDate)!
            } else if graceDayAvailable && !usedGraceDay && checkDate != today && streak > 0 {
                // Grace day: skip this gap, don't increment streak count
                usedGraceDay = true
                checkDate = Calendar.current.date(byAdding: .day, value: -1, to: checkDate)!
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
        return snapshot.documents.compactMap { try? $0.data(as: DriftLog.self) }
    }

    func driftLogCount(uid: String) async throws -> Int {
        let snapshot = try await driftRef(uid).getDocuments()
        return snapshot.count
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
        return snapshot.documents.compactMap { try? $0.data(as: CircleComment.self) }
    }

    func postComment(comment: CircleComment) async throws {
        try commentsRef(circleId: comment.circleId, postId: comment.postId).addDocument(from: comment)
    }

    func fetchUserCircles(uid: String) async throws -> [Circle] {
        let snapshot = try await circlesRef()
            .whereField("memberIds", arrayContains: uid)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Circle.self) }
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
        return snapshot.documents.compactMap { try? $0.data(as: CirclePost.self) }
    }

    func postToCircle(post: CirclePost) async throws {
        try circlePostsRef(post.circleId).addDocument(from: post)
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

    /// Mark a journey series as completed and deactivate
    func completeJourney(uid: String, series: JourneySeries) async throws {
        try await updateUser(uid: uid, fields: [
            "journeyActive": false,
            "completedJourneys": FieldValue.arrayUnion([series.rawValue])
        ])
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
