// FirestoreService+Admin.swift
// Admin-only Firestore operations: reports, user management, circle oversight

import Foundation
import Firebase
import FirebaseFirestore

// MARK: - Admin Models

struct ContentReport: Identifiable {
    var id: String
    var reporterId: String
    var circleId: String
    var postId: String
    var commentId: String?
    var reason: String
    var status: String       // "pending", "resolved", "dismissed"
    var type: String?        // "block" or nil for content reports
    var timestamp: Date
    var reporterName: String? // populated after fetch
    var postPreview: String?  // populated after fetch
}

struct AdminUserSummary: Identifiable {
    var id: String { uid }
    var uid: String
    var displayName: String
    var email: String
    var isPremium: Bool
    var isAdmin: Bool
    var currentStreak: Int
    var joinDate: Date
    var circleCount: Int?
}

struct AdminCircleSummary: Identifiable {
    var id: String
    var name: String
    var creatorId: String
    var creatorName: String?
    var memberCount: Int
    var memberIds: [String]
    var isPublic: Bool
    var createdAt: Date
}

// MARK: - Admin Firestore Operations

extension FirestoreService {

    // MARK: - Reports

    /// Fetch all pending reports, newest first
    func fetchReports(status: String = "pending", limit: Int = 50) async throws -> [ContentReport] {
        let snapshot = try await Firestore.firestore().collection("reports")
            .whereField("status", isEqualTo: status)
            .order(by: "timestamp", descending: true)
            .limit(to: limit)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            guard let reporterId = data["reporterId"] as? String,
                  let reason = data["reason"] as? String,
                  let statusVal = data["status"] as? String,
                  let timestamp = (data["timestamp"] as? Timestamp)?.dateValue()
            else { return nil }

            return ContentReport(
                id: doc.documentID,
                reporterId: reporterId,
                circleId: (data["circleId"] as? String) ?? "",
                postId: (data["postId"] as? String) ?? "",
                commentId: data["commentId"] as? String,
                reason: reason,
                status: statusVal,
                type: data["type"] as? String,
                timestamp: timestamp
            )
        }
    }

    /// Resolve a report (dismiss or actioned)
    func resolveReport(reportId: String, resolution: String) async throws {
        try await Firestore.firestore().collection("reports").document(reportId).updateData([
            "status": resolution,
            "resolvedAt": Timestamp(date: Date())
        ])
    }

    // MARK: - Circle Admin

    /// Fetch all circles (admin only)
    func fetchAllCircles(limit: Int = 100) async throws -> [AdminCircleSummary] {
        let snapshot = try await Firestore.firestore().collection("circles")
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            guard let name = data["name"] as? String,
                  let creatorId = data["creatorId"] as? String,
                  let memberIds = data["memberIds"] as? [String],
                  let createdAt = (data["createdAt"] as? Timestamp)?.dateValue()
            else { return nil }

            return AdminCircleSummary(
                id: doc.documentID,
                name: name,
                creatorId: creatorId,
                memberCount: memberIds.count,
                memberIds: memberIds,
                isPublic: (data["isPublic"] as? Bool) ?? false,
                createdAt: createdAt
            )
        }
    }

    /// Remove a specific member from a circle (admin or leader action)
    func removeMemberFromCircle(circleId: String, uid: String) async throws {
        try await Firestore.firestore().collection("circles").document(circleId).updateData([
            "memberIds": FieldValue.arrayRemove([uid])
        ])
    }

    // MARK: - User Admin

    /// Search users by display name or email prefix
    func searchUsers(query: String, limit: Int = 20) async throws -> [AdminUserSummary] {
        let q = query.lowercased()

        // Firestore doesn't support full-text search, so we fetch recent users and filter locally
        // For production, consider Algolia or Cloud Functions
        let snapshot = try await Firestore.firestore().collection("users")
            .order(by: "joinDate", descending: true)
            .limit(to: 200)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            let name = (data["displayName"] as? String) ?? ""
            let email = (data["email"] as? String) ?? ""

            // Filter by query
            if !q.isEmpty && !name.lowercased().contains(q) && !email.lowercased().contains(q) {
                return nil
            }

            return AdminUserSummary(
                uid: doc.documentID,
                displayName: name,
                email: email,
                isPremium: (data["isPremium"] as? Bool) ?? false,
                isAdmin: (data["isAdmin"] as? Bool) ?? false,
                currentStreak: (data["currentStreak"] as? Int) ?? 0,
                joinDate: (data["joinDate"] as? Timestamp)?.dateValue() ?? Date()
            )
        }
    }

    /// Toggle admin status for a user
    func setAdmin(uid: String, isAdmin: Bool) async throws {
        try await updateUser(uid: uid, fields: ["isAdmin": isAdmin])
    }

    /// Fetch post content for a report preview
    func fetchPostContent(circleId: String, postId: String) async throws -> String? {
        let doc = try await Firestore.firestore().collection("circles").document(circleId)
            .collection("posts").document(postId).getDocument()
        return doc.data()?["content"] as? String
    }

    /// Count all users
    func userCount() async throws -> Int {
        let snapshot = try await Firestore.firestore().collection("users").count.getAggregation(source: .server)
        return Int(truncating: snapshot.count)
    }

    /// Count all circles
    func circleCount() async throws -> Int {
        let snapshot = try await Firestore.firestore().collection("circles").count.getAggregation(source: .server)
        return Int(truncating: snapshot.count)
    }

    /// Count pending reports
    func pendingReportCount() async throws -> Int {
        let snapshot = try await Firestore.firestore().collection("reports")
            .whereField("status", isEqualTo: "pending")
            .count.getAggregation(source: .server)
        return Int(truncating: snapshot.count)
    }
}
