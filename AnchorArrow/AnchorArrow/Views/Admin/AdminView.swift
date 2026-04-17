// AdminView.swift
// Admin panel — reports queue, circle management, user management
// Only accessible to users with isAdmin == true

import SwiftUI
import FirebaseAuth

// MARK: - Admin Panel

struct AdminView: View {
    @EnvironmentObject var userStore: UserStore
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab picker
                Picker("", selection: $selectedTab) {
                    Text("Dashboard").tag(0)
                    Text("Reports").tag(1)
                    Text("Circles").tag(2)
                    Text("Users").tag(3)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, AATheme.paddingMedium)
                .padding(.top, AATheme.paddingSmall)

                switch selectedTab {
                case 0: AdminDashboardTab()
                case 1: AdminReportsTab()
                case 2: AdminCirclesTab()
                case 3: AdminUsersTab()
                default: EmptyView()
                }
            }
            .aaScreenBackground()
            .navigationTitle("Admin Panel")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Dashboard Tab

private struct AdminDashboardTab: View {
    @State private var userCount = 0
    @State private var circleCount = 0
    @State private var pendingReports = 0
    @State private var isLoading = true

    var body: some View {
        ScrollView {
            VStack(spacing: AATheme.paddingMedium) {
                if isLoading {
                    ProgressView().padding(.top, 40)
                } else {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: AATheme.paddingMedium) {
                        StatCard(title: "Users", value: "\(userCount)", icon: "person.3.fill", color: AATheme.steel)
                        StatCard(title: "Circles", value: "\(circleCount)", icon: "circle.hexagongrid.fill", color: AATheme.amber)
                        StatCard(title: "Reports", value: "\(pendingReports)", icon: "exclamationmark.triangle.fill",
                                 color: pendingReports > 0 ? AATheme.destructive : AATheme.success)
                    }
                }
            }
            .padding(AATheme.paddingMedium)
        }
        .task { await loadStats() }
    }

    private func loadStats() async {
        isLoading = true
        defer { isLoading = false }
        let service = FirestoreService.shared
        userCount = (try? await service.userCount()) ?? 0
        circleCount = (try? await service.circleCount()) ?? 0
        pendingReports = (try? await service.pendingReportCount()) ?? 0
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(AATheme.primaryText)
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AATheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(AATheme.paddingMedium)
        .background(AATheme.cardBackground)
        .cornerRadius(AATheme.cornerRadius)
    }
}

// MARK: - Reports Tab

private struct AdminReportsTab: View {
    @State private var reports: [ContentReport] = []
    @State private var isLoading = true
    @State private var selectedReport: ContentReport?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if isLoading {
                    ProgressView().padding(.top, 40)
                } else if reports.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 40))
                            .foregroundColor(AATheme.success)
                        Text("No pending reports")
                            .font(AATheme.subheadlineFont)
                            .foregroundColor(AATheme.secondaryText)
                    }
                    .padding(.top, 60)
                } else {
                    ForEach(reports) { report in
                        ReportRow(report: report, onDismiss: {
                            Task { await resolveReport(report, resolution: "dismissed") }
                        }, onDeletePost: {
                            Task { await deleteReportedPost(report) }
                        }, onRemoveUser: {
                            Task { await removeReportedUser(report) }
                        })
                    }
                }
            }
            .padding(AATheme.paddingMedium)
        }
        .task { await loadReports() }
    }

    private func loadReports() async {
        isLoading = true
        defer { isLoading = false }
        reports = (try? await FirestoreService.shared.fetchReports()) ?? []
        // Enrich with post previews
        for i in reports.indices {
            reports[i].postPreview = try? await FirestoreService.shared.fetchPostContent(
                circleId: reports[i].circleId, postId: reports[i].postId)
        }
    }

    private func resolveReport(_ report: ContentReport, resolution: String) async {
        try? await FirestoreService.shared.resolveReport(reportId: report.id, resolution: resolution)
        reports.removeAll { $0.id == report.id }
    }

    private func deleteReportedPost(_ report: ContentReport) async {
        try? await FirestoreService.shared.deletePost(circleId: report.circleId, postId: report.postId)
        try? await FirestoreService.shared.resolveReport(reportId: report.id, resolution: "post_deleted")
        reports.removeAll { $0.id == report.id }
    }

    private func removeReportedUser(_ report: ContentReport) async {
        // Get the post author
        if let content = try? await FirestoreService.shared.fetchPostContent(circleId: report.circleId, postId: report.postId) {
            // Remove from circle + delete the post
            try? await FirestoreService.shared.deletePost(circleId: report.circleId, postId: report.postId)
        }
        try? await FirestoreService.shared.resolveReport(reportId: report.id, resolution: "user_removed")
        reports.removeAll { $0.id == report.id }
    }
}

private struct ReportRow: View {
    let report: ContentReport
    let onDismiss: () -> Void
    let onDeletePost: () -> Void
    let onRemoveUser: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack {
                Image(systemName: report.type == "block" ? "person.crop.circle.badge.xmark" : "flag.fill")
                    .foregroundColor(AATheme.destructive)
                Text(report.type == "block" ? "Block Report" : "Content Report")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AATheme.primaryText)
                Spacer()
                Text(report.timestamp, style: .relative)
                    .font(.system(size: 12))
                    .foregroundColor(AATheme.secondaryText)
            }

            // Reason
            Text(report.reason)
                .font(.system(size: 14))
                .foregroundColor(AATheme.primaryText)
                .lineLimit(3)

            // Post preview
            if let preview = report.postPreview {
                Text(preview)
                    .font(.system(size: 13))
                    .foregroundColor(AATheme.secondaryText)
                    .lineLimit(2)
                    .padding(10)
                    .background(AATheme.background)
                    .cornerRadius(8)
            }

            // Actions
            HStack(spacing: 12) {
                Button("Dismiss") { onDismiss() }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AATheme.secondaryText)

                Spacer()

                Button("Delete Post") { onDeletePost() }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AATheme.warning)

                Button("Remove User") { onRemoveUser() }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AATheme.destructive)
            }
        }
        .padding(AATheme.paddingMedium)
        .background(AATheme.cardBackground)
        .cornerRadius(AATheme.cornerRadius)
    }
}

// MARK: - Circles Tab

private struct AdminCirclesTab: View {
    @State private var circles: [AdminCircleSummary] = []
    @State private var isLoading = true
    @State private var selectedCircle: AdminCircleSummary?
    @State private var memberNames: [String: String] = [:]
    @State private var showDeleteConfirm = false
    @State private var circleToDelete: AdminCircleSummary?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if isLoading {
                    ProgressView().padding(.top, 40)
                } else {
                    ForEach(circles) { circle in
                        CircleAdminRow(
                            circle: circle,
                            isExpanded: selectedCircle?.id == circle.id,
                            memberNames: memberNames,
                            onTap: {
                                withAnimation {
                                    if selectedCircle?.id == circle.id {
                                        selectedCircle = nil
                                    } else {
                                        selectedCircle = circle
                                        Task { await loadMembers(for: circle) }
                                    }
                                }
                            },
                            onRemoveMember: { uid in
                                Task { await removeMember(uid, from: circle) }
                            },
                            onDelete: {
                                circleToDelete = circle
                                showDeleteConfirm = true
                            }
                        )
                    }
                }
            }
            .padding(AATheme.paddingMedium)
        }
        .task { await loadCircles() }
        .confirmationDialog("Delete this circle?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete Circle", role: .destructive) {
                if let circle = circleToDelete {
                    Task { await deleteCircle(circle) }
                }
            }
        } message: {
            Text("This will permanently delete the circle, all posts, and all comments. This cannot be undone.")
        }
    }

    private func loadCircles() async {
        isLoading = true
        defer { isLoading = false }
        circles = (try? await FirestoreService.shared.fetchAllCircles()) ?? []
    }

    private func loadMembers(for circle: AdminCircleSummary) async {
        let names = (try? await FirestoreService.shared.fetchMemberNames(memberIds: circle.memberIds)) ?? [:]
        for (uid, name) in names { memberNames[uid] = name }
    }

    private func removeMember(_ uid: String, from circle: AdminCircleSummary) async {
        try? await FirestoreService.shared.removeMemberFromCircle(circleId: circle.id, uid: uid)
        if let idx = circles.firstIndex(where: { $0.id == circle.id }) {
            circles[idx].memberIds.removeAll { $0 == uid }
        }
        if selectedCircle?.id == circle.id {
            selectedCircle?.memberIds.removeAll { $0 == uid }
        }
    }

    private func deleteCircle(_ circle: AdminCircleSummary) async {
        try? await FirestoreService.shared.deleteCircle(circleId: circle.id)
        circles.removeAll { $0.id == circle.id }
        selectedCircle = nil
    }
}

private struct CircleAdminRow: View {
    let circle: AdminCircleSummary
    let isExpanded: Bool
    let memberNames: [String: String]
    let onTap: () -> Void
    let onRemoveMember: (String) -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header row
            Button(action: onTap) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(circle.name)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AATheme.primaryText)
                            if circle.isPublic {
                                Text("PUBLIC")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(AATheme.steel)
                                    .cornerRadius(4)
                            }
                            if circle.id == FirestoreService.globalCircleId {
                                Text("GLOBAL")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(AATheme.amber)
                                    .cornerRadius(4)
                            }
                        }
                        Text("\(circle.memberCount) members")
                            .font(.system(size: 13))
                            .foregroundColor(AATheme.secondaryText)
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(AATheme.secondaryText)
                }
            }
            .buttonStyle(.plain)
            .padding(AATheme.paddingMedium)

            // Expanded: member list + actions
            if isExpanded {
                Divider().padding(.horizontal, AATheme.paddingMedium)

                VStack(spacing: 0) {
                    ForEach(circle.memberIds, id: \.self) { uid in
                        HStack {
                            Text(memberNames[uid] ?? uid.prefix(8) + "...")
                                .font(.system(size: 14))
                                .foregroundColor(AATheme.primaryText)
                            if uid == circle.creatorId {
                                Text("LEADER")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(AATheme.warmGold)
                            }
                            Spacer()
                            if uid != circle.creatorId {
                                Button("Remove") { onRemoveMember(uid) }
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(AATheme.destructive)
                            }
                        }
                        .padding(.horizontal, AATheme.paddingMedium)
                        .padding(.vertical, 8)
                    }
                }

                Divider().padding(.horizontal, AATheme.paddingMedium)

                Button(role: .destructive, action: onDelete) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete Circle")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AATheme.destructive)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
            }
        }
        .background(AATheme.cardBackground)
        .cornerRadius(AATheme.cornerRadius)
    }
}

// MARK: - Users Tab

private struct AdminUsersTab: View {
    @State private var searchText = ""
    @State private var users: [AdminUserSummary] = []
    @State private var isLoading = false
    @State private var hasSearched = false
    @State private var confirmToggleAdmin: AdminUserSummary?
    @State private var showAdminConfirm = false

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AATheme.secondaryText)
                TextField("Search by name or email", text: $searchText)
                    .font(.system(size: 15))
                    .onSubmit { Task { await search() } }
                if !searchText.isEmpty {
                    Button { searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AATheme.secondaryText)
                    }
                }
            }
            .padding(12)
            .background(AATheme.cardBackground)
            .cornerRadius(AATheme.cornerRadiusSmall)
            .padding(AATheme.paddingMedium)

            ScrollView {
                LazyVStack(spacing: 8) {
                    if isLoading {
                        ProgressView().padding(.top, 40)
                    } else if !hasSearched {
                        VStack(spacing: 8) {
                            Image(systemName: "person.text.rectangle")
                                .font(.system(size: 36))
                                .foregroundColor(AATheme.secondaryText)
                            Text("Search for users by name or email")
                                .font(.system(size: 14))
                                .foregroundColor(AATheme.secondaryText)
                            Text("Leave blank and press Return to see all")
                                .font(.system(size: 12))
                                .foregroundColor(AATheme.secondaryText.opacity(0.6))
                        }
                        .padding(.top, 40)
                    } else if users.isEmpty {
                        Text("No users found")
                            .foregroundColor(AATheme.secondaryText)
                            .padding(.top, 40)
                    } else {
                        ForEach(users) { user in
                            UserAdminRow(user: user, onToggleAdmin: {
                                confirmToggleAdmin = user
                                showAdminConfirm = true
                            }, onTogglePremium: {
                                Task { await togglePremium(user) }
                            })
                        }
                    }
                }
                .padding(.horizontal, AATheme.paddingMedium)
            }
        }
        .confirmationDialog(
            confirmToggleAdmin?.isAdmin == true ? "Remove admin access?" : "Grant admin access?",
            isPresented: $showAdminConfirm,
            titleVisibility: .visible
        ) {
            Button(confirmToggleAdmin?.isAdmin == true ? "Remove Admin" : "Make Admin",
                   role: confirmToggleAdmin?.isAdmin == true ? .destructive : nil) {
                if let user = confirmToggleAdmin {
                    Task { await toggleAdmin(user) }
                }
            }
        } message: {
            if let user = confirmToggleAdmin {
                Text(user.isAdmin
                     ? "\(user.displayName) will lose admin privileges."
                     : "\(user.displayName) will gain full admin access to all circles, reports, and users.")
            }
        }
    }

    private func search() async {
        isLoading = true
        hasSearched = true
        defer { isLoading = false }
        users = (try? await FirestoreService.shared.searchUsers(query: searchText)) ?? []
    }

    private func toggleAdmin(_ user: AdminUserSummary) async {
        let newValue = !user.isAdmin
        try? await FirestoreService.shared.setAdmin(uid: user.uid, isAdmin: newValue)
        if let idx = users.firstIndex(where: { $0.uid == user.uid }) {
            users[idx] = AdminUserSummary(
                uid: user.uid, displayName: user.displayName, email: user.email,
                isPremium: user.isPremium, isAdmin: newValue,
                currentStreak: user.currentStreak, joinDate: user.joinDate
            )
        }
    }

    private func togglePremium(_ user: AdminUserSummary) async {
        let newValue = !user.isPremium
        try? await FirestoreService.shared.setPremium(uid: user.uid, isPremium: newValue, expiry: newValue ? Calendar.current.date(byAdding: .year, value: 1, to: Date()) : nil)
        if let idx = users.firstIndex(where: { $0.uid == user.uid }) {
            users[idx] = AdminUserSummary(
                uid: user.uid, displayName: user.displayName, email: user.email,
                isPremium: newValue, isAdmin: user.isAdmin,
                currentStreak: user.currentStreak, joinDate: user.joinDate
            )
        }
    }
}

private struct UserAdminRow: View {
    let user: AdminUserSummary
    let onToggleAdmin: () -> Void
    let onTogglePremium: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(user.displayName)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AATheme.primaryText)
                        if user.isAdmin {
                            Text("ADMIN")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(AATheme.destructive)
                                .cornerRadius(4)
                        }
                        if user.isPremium {
                            Text("PRO")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(AATheme.warmGold)
                                .cornerRadius(4)
                        }
                    }
                    Text(user.email)
                        .font(.system(size: 12))
                        .foregroundColor(AATheme.secondaryText)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 3) {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 11))
                            .foregroundColor(AATheme.amber)
                        Text("\(user.currentStreak)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AATheme.primaryText)
                    }
                    Text("Joined \(user.joinDate, style: .date)")
                        .font(.system(size: 11))
                        .foregroundColor(AATheme.secondaryText)
                }
            }

            HStack(spacing: 12) {
                Button(action: onToggleAdmin) {
                    Text(user.isAdmin ? "Remove Admin" : "Make Admin")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(user.isAdmin ? AATheme.destructive : AATheme.steel)
                }
                Button(action: onTogglePremium) {
                    Text(user.isPremium ? "Remove Premium" : "Grant Premium")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(user.isPremium ? AATheme.warning : AATheme.success)
                }
            }
        }
        .padding(AATheme.paddingMedium)
        .background(AATheme.cardBackground)
        .cornerRadius(AATheme.cornerRadius)
    }
}
