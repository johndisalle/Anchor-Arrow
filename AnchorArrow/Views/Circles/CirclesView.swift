// CirclesView.swift
// Iron Sharpeners – private accountability circles

import SwiftUI
import FirebaseAuth

// MARK: - CirclesView
struct CirclesView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var storeKitManager: StoreKitManager
    @State private var circles: [Circle] = []
    @State private var publicCircles: [Circle] = []
    @State private var showCreateCircle = false
    @State private var showJoinCircle = false
    @State private var showBrowsePublic = false
    @State private var showPremiumUpsell = false
    @State private var isLoading = false
    @State private var selectedCircle: Circle?
    @State private var circleActivity: [String: Int] = [:]  // circleId -> active this week count

    private let firestoreService = FirestoreService.shared

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    SkeletonCirclesList()
                } else if circles.isEmpty {
                    emptyState
                } else {
                    circlesList
                }
            }
            .background(Color("BackgroundPrimary").ignoresSafeArea())
            .navigationTitle("Iron Sharpeners")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("BackgroundPrimary"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            if userStore.isPremium || circles.isEmpty {
                                showCreateCircle = true
                            } else {
                                showPremiumUpsell = true
                            }
                        } label: {
                            Label("Create a Circle", systemImage: "plus.circle")
                        }
                        Button {
                            showJoinCircle = true
                        } label: {
                            Label("Join with Code", systemImage: "link")
                        }
                        Button {
                            showBrowsePublic = true
                        } label: {
                            Label("Browse Public Circles", systemImage: "globe")
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color("BrandAnchor"))
                    }
                }
            }
            .sheet(isPresented: $showCreateCircle) {
                CreateCircleView { newCircle in
                    circles.insert(newCircle, at: 0)
                }
            }
            .sheet(isPresented: $showJoinCircle) {
                JoinCircleView { joinedCircle in
                    if !circles.contains(where: { $0.id == joinedCircle.id }) {
                        circles.append(joinedCircle)
                    }
                }
            }
            .sheet(isPresented: $showBrowsePublic) {
                BrowsePublicCirclesView { joinedCircle in
                    if !circles.contains(where: { $0.id == joinedCircle.id }) {
                        circles.append(joinedCircle)
                    }
                }
            }
            .sheet(isPresented: $showPremiumUpsell) {
                PremiumUpsellView(reason: "Create unlimited Iron Sharpeners circles")
            }
            .sheet(item: $selectedCircle) { circle in
                CircleDetailView(circle: circle, onLeave: {
                    circles.removeAll { $0.id == circle.id }
                })
            }
        }
        .task { await loadCircles() }
        .refreshable { await loadCircles() }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 28) {
            Spacer()
            Image(systemName: "person.3.fill")
                .font(.system(size: 52))
                .foregroundColor(Color("BrandAnchor").opacity(0.5))
            VStack(spacing: 10) {
                Text("No Circles Yet")
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(Color("TextPrimary"))
                Text("\"As iron sharpens iron, so one person sharpens another.\" — Proverbs 27:17")
                    .font(.system(size: 15, weight: .medium, design: .serif))
                    .italic()
                    .foregroundColor(Color("TextSecondary"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, 32)
                Text("Start or join a circle of 3–8 brothers to share wins, struggles, and accountability.")
                    .font(.system(size: 14))
                    .foregroundColor(Color("TextSecondary"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
                    .padding(.top, 4)
            }
            VStack(spacing: 12) {
                Button { showCreateCircle = true } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Create a Circle")
                            .font(.system(size: 17, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity).frame(height: 52)
                    .background(Color("BrandAnchor"))
                    .cornerRadius(14)
                }
                Button { showJoinCircle = true } label: {
                    HStack {
                        Image(systemName: "link")
                        Text("Join with Invite Code")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(Color("BrandAnchor"))
                    .frame(maxWidth: .infinity).frame(height: 52)
                    .background(Color("BrandAnchor").opacity(0.1))
                    .cornerRadius(14)
                }
                Button { showBrowsePublic = true } label: {
                    HStack {
                        Image(systemName: "globe")
                        Text("Browse Public Circles")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(Color("BrandArrow"))
                    .frame(maxWidth: .infinity).frame(height: 52)
                    .background(Color("BrandArrow").opacity(0.1))
                    .cornerRadius(14)
                }
            }
            .padding(.horizontal, 32)
            Spacer()
        }
    }

    // MARK: - Circles List
    private var circlesList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                if !userStore.isPremium && circles.count >= 1 {
                    HStack(spacing: 10) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(Color("BrandGold"))
                        Text("Free plan: react only. Upgrade to post and comment.")
                            .font(.system(size: 13))
                            .foregroundColor(Color("TextSecondary"))
                        Spacer()
                        Button("Upgrade") { showPremiumUpsell = true }
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color("BrandGold"))
                    }
                    .padding(14)
                    .background(Color("BrandGold").opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                }
                ForEach(circles) { circle in
                    CircleCard(circle: circle,
                               activeThisWeek: circleActivity[circle.id ?? ""]) {
                        selectedCircle = circle
                    }
                    .padding(.horizontal, 20)
                }
                Spacer(minLength: 100)
            }
            .padding(.top, 16)
        }
    }

    private func loadCircles() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        circles = (try? await firestoreService.fetchUserCircles(uid: uid)) ?? []
        isLoading = false

        // Load weekly activity counts for health badge
        for circle in circles {
            guard let cid = circle.id else { continue }
            if let profiles = try? await firestoreService.fetchMemberProfiles(memberIds: circle.memberIds) {
                let activeCount = profiles.values.filter { $0.daysSinceActive <= 7 }.count
                circleActivity[cid] = activeCount
            }
        }
    }
}

// MARK: - CircleCard
struct CircleCard: View {
    let circle: Circle
    var activeThisWeek: Int? = nil  // number of members active in last 7 days
    let onTap: () -> Void
    @State private var showCopiedToast = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    SwiftUI.Circle()
                        .fill(Color("BrandAnchor").opacity(0.15))
                        .frame(width: 52, height: 52)
                    Text(String(circle.name.prefix(2)).uppercased())
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(Color("BrandAnchor"))
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(circle.name)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Color("TextPrimary"))
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        Label("\(circle.memberCount) brothers", systemImage: "person.2.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color("TextSecondary"))
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)

                        // Public/Private badge
                        HStack(spacing: 3) {
                            Image(systemName: circle.isPublic ? "globe" : "lock.fill")
                                .font(.system(size: 9, weight: .semibold))
                            Text(circle.isPublic ? "Public" : "Private")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(circle.isPublic ? Color("BrandArrow") : Color("TextSecondary"))
                        .fixedSize(horizontal: true, vertical: false)

                        // Weekly health badge
                        if let active = activeThisWeek {
                            HStack(spacing: 3) {
                                SwiftUI.Circle()
                                    .fill(active == circle.memberCount ? Color("BrandArrow") : Color("BrandWarning"))
                                    .frame(width: 6, height: 6)
                                Text("\(active)/\(circle.memberCount) active")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(active == circle.memberCount
                                                     ? Color("BrandArrow") : Color("BrandWarning"))
                            }
                            .fixedSize(horizontal: true, vertical: false)
                        }
                    }
                }
                .layoutPriority(1)
                Spacer(minLength: 4)
                // Copy invite code chip
                Button {
                    UIPasteboard.general.string = circle.inviteCode
                    showCopiedToast = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showCopiedToast = false
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: showCopiedToast ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 11, weight: .semibold))
                        Text(showCopiedToast ? "Copied!" : circle.inviteCode)
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(showCopiedToast ? Color("BrandArrow") : Color("BrandAnchor"))
                    .padding(.horizontal, 8).padding(.vertical, 5)
                    .background(Color("BrandAnchor").opacity(0.1))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .fixedSize(horizontal: true, vertical: false)
                .accessibilityLabel(showCopiedToast ? "Invite code copied" : "Copy invite code \(circle.inviteCode)")

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("TextSecondary"))
            }
            .padding(16)
            .background(Color("CardBackground"))
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - CircleDetailView
struct CircleDetailView: View {
    let circle: Circle
    let onLeave: () -> Void

    @EnvironmentObject var userStore: UserStore
    @Environment(\.dismiss) var dismiss
    @State private var posts: [CirclePost] = []
    @State private var isLoading = false
    @State private var showNewPost = false
    @State private var showQuickRally = false
    @State private var showRallyConfirm = false
    @State private var showPremiumUpsell = false
    @State private var showMemberList = false
    @State private var memberProfiles: [String: MemberProfile] = [:]
    @State private var showLeaveAlert = false
    @State private var showDeleteAlert = false
    @State private var isDeleting = false
    @State private var postToDelete: CirclePost?
    @State private var postToReport: CirclePost?
    @State private var showReportSheet = false
    @State private var reportReason = ""
    @State private var showReportConfirm = false
    @State private var selectedPostForComments: CirclePost?
    @State private var codeCopied = false

    private let service = FirestoreService.shared
    private let dailyPrompt = PromptLibrary.circlePromptForToday()

    var canPost: Bool { userStore.isPremium }

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    SkeletonPostFeed()
                } else {
                    ZStack(alignment: .bottom) {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 12) {
                                // Battle Formation — who's in the fight today
                                BattleFormationCard(memberIds: circle.memberIds,
                                                    profiles: memberProfiles)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 16)

                                // Daily prompt
                                dailyPromptBanner
                                    .padding(.horizontal, 20)

                                // Prayer Wall — pinned above feed
                                let prayerPosts = posts.filter { $0.type == .prayer }
                                if !prayerPosts.isEmpty {
                                    PrayerWallSection(
                                        posts: prayerPosts,
                                        onPray: { post in Task { await react(to: post, emoji: "🙏") } },
                                        onMarkAnswered: { post in Task { await markAnswered(post: post) } }
                                    )
                                    .padding(.horizontal, 20)
                                }

                                // Regular post feed (excludes prayer — shown above)
                                let feedPosts = posts.filter { $0.type != .prayer }
                                let pinnedPosts = feedPosts.filter { $0.isPinned }
                                let unpinnedPosts = feedPosts.filter { !$0.isPinned }
                                let orderedFeed = pinnedPosts + unpinnedPosts

                                if feedPosts.isEmpty && prayerPosts.isEmpty {
                                    emptyPostsState
                                } else {
                                    ForEach(orderedFeed) { post in
                                        CirclePostRow(
                                            post: post,
                                            isLeader: isCircleLeader,
                                            canModerate: canModerate,
                                            onReact: { emoji in
                                                Task { await react(to: post, emoji: emoji) }
                                            },
                                            onComment: {
                                                if canPost {
                                                    selectedPostForComments = post
                                                } else {
                                                    showPremiumUpsell = true
                                                }
                                            },
                                            onPin: {
                                                Task { await togglePin(post: post) }
                                            },
                                            onDelete: canModerate ? {
                                                postToDelete = post
                                            } : nil,
                                            onReport: {
                                                postToReport = post
                                                reportReason = ""
                                                showReportSheet = true
                                            }
                                        )
                                        .padding(.horizontal, 20)
                                    }
                                }
                                Spacer(minLength: 140)
                            }
                        }
                        .refreshable { await loadPosts() }

                        // Quick Rally — send a struggle to the circle
                        Button {
                            if canPost { showRallyConfirm = true }
                            else { showPremiumUpsell = true }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "shield.lefthalf.filled")
                                    .font(.system(size: 15, weight: .semibold))
                                Text("I Need My Brothers")
                                    .font(.system(size: 15, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 22).padding(.vertical, 13)
                            .background(
                                LinearGradient(
                                    colors: [Color("BrandWarning"), Color("BrandWarning").opacity(0.8)],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .cornerRadius(28)
                            .shadow(color: Color("BrandWarning").opacity(0.4), radius: 10, y: 4)
                        }
                        .buttonStyle(.plain)
                        .padding(.bottom, 20)
                    }
                }
            }
            .background(Color("BackgroundPrimary").ignoresSafeArea())
            .navigationTitle(circle.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }.foregroundColor(Color("BrandAnchor"))
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    ShareLink(
                        item: URL(string: "anchorarrow://join?code=\(circle.inviteCode)") ?? URL(string: "https://johndisalle.github.io/Anchor-Arrow/")!,
                        subject: Text("Join \(circle.name) on Anchor & Arrow"),
                        message: Text("Join my circle \"\(circle.name)\" on Anchor & Arrow! Use code \(circle.inviteCode) or tap this link.")
                    ) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16))
                            .foregroundColor(Color("BrandAnchor"))
                    }
                    Button { showMemberList = true } label: {
                        Image(systemName: "person.2")
                            .font(.system(size: 16))
                            .foregroundColor(Color("BrandAnchor"))
                    }
                    Button {
                        if canPost { showNewPost = true }
                        else { showPremiumUpsell = true }
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 17))
                            .foregroundColor(Color("BrandAnchor"))
                    }
                    Menu {
                        if circle.creatorId == Auth.auth().currentUser?.uid {
                            Button(role: .destructive) { showDeleteAlert = true } label: {
                                Label("Delete Circle", systemImage: "trash")
                            }
                        } else {
                            Button(role: .destructive) { showLeaveAlert = true } label: {
                                Label("Leave Circle", systemImage: "arrow.right.circle")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16))
                            .foregroundColor(Color("TextSecondary"))
                    }
                }
            }
            .sheet(isPresented: $showNewPost) {
                NewCirclePostView(circleId: circle.id ?? "", preselectedType: nil) { newPost in
                    posts.insert(newPost, at: 0)
                }
            }
            .sheet(isPresented: $showQuickRally) {
                NewCirclePostView(circleId: circle.id ?? "", preselectedType: .drift) { newPost in
                    posts.insert(newPost, at: 0)
                }
            }
            .sheet(isPresented: $showPremiumUpsell) {
                PremiumUpsellView(reason: "Post and comment in Iron Sharpeners circles")
            }
            .sheet(isPresented: $showMemberList) {
                MemberListSheet(circle: circle, memberProfiles: memberProfiles)
            }
            .sheet(item: $selectedPostForComments) { post in
                CommentsSheet(post: post, circle: circle)
            }
            .alert("Leave Circle?", isPresented: $showLeaveAlert) {
                Button("Leave", role: .destructive) { Task { await leaveCircle() } }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("You'll need an invite code to rejoin \"\(circle.name)\".")
            }
            .alert("Delete Circle?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) { Task { await deleteCircle() } }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will permanently delete \"\(circle.name)\" and all its posts. This cannot be undone.")
            }
            .alert("Delete Post?", isPresented: .init(
                get: { postToDelete != nil },
                set: { if !$0 { postToDelete = nil } }
            )) {
                Button("Delete", role: .destructive) {
                    if let post = postToDelete { Task { await deletePost(post) } }
                }
                Button("Cancel", role: .cancel) { postToDelete = nil }
            } message: {
                Text("This will permanently remove this post and all its replies.")
            }
            .sheet(isPresented: $showReportSheet) {
                ReportSheet(
                    onSubmit: { reason in
                        if let post = postToReport {
                            Task { await reportPost(post, reason: reason) }
                        }
                        showReportSheet = false
                    },
                    onCancel: { showReportSheet = false }
                )
            }
            .confirmationDialog(
                "Rally Your Brothers?",
                isPresented: $showRallyConfirm,
                titleVisibility: .visible
            ) {
                Button("Yes, I Need Them") { showQuickRally = true }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will share a drift moment with your circle so they can stand with you.")
            }
        }
        .task { await loadData() }
    }

    // MARK: - Daily Prompt Banner
    private var dailyPromptBanner: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color("BrandGold"))
                Text("TODAY'S CIRCLE PROMPT")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundColor(Color("BrandGold"))
                    .tracking(0.5)
                Spacer()
            }
            Text(dailyPrompt)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("TextPrimary"))
                .lineSpacing(4)
        }
        .padding(16)
        .background(Color("BrandGold").opacity(0.08))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color("BrandGold").opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Empty Posts State
    private var emptyPostsState: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 60)
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 44))
                .foregroundColor(Color("TextSecondary").opacity(0.4))
            Text("No posts yet. Be the first to share.")
                .font(.system(size: 15))
                .foregroundColor(Color("TextSecondary"))
            if !canPost {
                Button { showPremiumUpsell = true } label: {
                    Text("Upgrade to Post")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20).padding(.vertical, 10)
                        .background(Color("BrandGold"))
                        .cornerRadius(20)
                }
            }
        }
    }

    private var isCircleLeader: Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false }
        return circle.creatorId == uid && userStore.isPremium
    }

    /// Admin or circle creator can delete posts/comments
    private var canModerate: Bool {
        userStore.isAdmin || isCircleLeader
    }

    // MARK: - Actions
    private func loadData() async {
        guard let circleId = circle.id else { return }
        isLoading = true
        async let fetchedPosts    = service.fetchCirclePosts(circleId: circleId)
        async let fetchedProfiles = service.fetchMemberProfiles(memberIds: circle.memberIds)
        posts          = (try? await fetchedPosts) ?? []
        memberProfiles = (try? await fetchedProfiles) ?? [:]
        isLoading = false
    }

    private func markAnswered(post: CirclePost) async {
        guard let circleId = circle.id, let postId = post.id else { return }
        do {
            try await service.markPrayerAnswered(circleId: circleId, postId: postId)
            if let idx = posts.firstIndex(where: { $0.id == post.id }) {
                posts[idx].isAnswered = true
            }
        } catch {
            userStore.errorMessage = "Couldn't mark prayer as answered. Try again."
        }
    }

    private func loadPosts() async {
        guard let circleId = circle.id else { return }
        posts = (try? await service.fetchCirclePosts(circleId: circleId)) ?? []
    }

    private func react(to post: CirclePost, emoji: String) async {
        guard let circleId = circle.id, let postId = post.id else { return }
        do {
            try await service.reactToPost(circleId: circleId, postId: postId, emoji: emoji)
            // Optimistic local update only on success
            if let index = posts.firstIndex(where: { $0.id == post.id }) {
                let current = posts[index].reactions[emoji] ?? 0
                posts[index].reactions[emoji] = current + 1
            }
        } catch {
            userStore.errorMessage = "Couldn't send reaction. Check your connection."
        }
    }

    private func togglePin(post: CirclePost) async {
        guard let circleId = circle.id, let postId = post.id else { return }
        do {
            if post.isPinned {
                try await service.unpinPost(circleId: circleId, postId: postId)
                if let idx = posts.firstIndex(where: { $0.id == post.id }) {
                    posts[idx].isPinned = false
                }
            } else {
                try await service.pinPost(circleId: circleId, postId: postId)
                for i in posts.indices { posts[i].isPinned = false }
                if let idx = posts.firstIndex(where: { $0.id == post.id }) {
                    posts[idx].isPinned = true
                }
            }
        } catch {
            userStore.errorMessage = "Couldn't update pin. Try again."
        }
    }

    private func leaveCircle() async {
        guard let circleId = circle.id,
              let uid = Auth.auth().currentUser?.uid else { return }
        do {
            try await service.leaveCircle(circleId: circleId, uid: uid)
            onLeave()
            dismiss()
        } catch {
            userStore.errorMessage = "Couldn't leave circle. Try again."
        }
    }

    private func deleteCircle() async {
        guard let circleId = circle.id,
              circle.creatorId == Auth.auth().currentUser?.uid else { return }
        isDeleting = true
        do {
            try await service.deleteCircle(circleId: circleId)
            onLeave()
            dismiss()
        } catch {
            #if DEBUG
            print("[Circles] Delete failed: \(error)")
            #endif
            userStore.errorMessage = "Couldn't delete circle. Try again."
        }
        isDeleting = false
    }

    private func deletePost(_ post: CirclePost) async {
        guard let circleId = circle.id, let postId = post.id else { return }
        do {
            try await service.deletePost(circleId: circleId, postId: postId)
            posts.removeAll { $0.id == postId }
        } catch {
            userStore.errorMessage = "Couldn't delete post. Try again."
        }
    }

    private func reportPost(_ post: CirclePost, reason: String) async {
        guard let uid = Auth.auth().currentUser?.uid,
              let circleId = circle.id,
              let postId = post.id else { return }
        do {
            try await service.submitReport(reporterId: uid, circleId: circleId, postId: postId, reason: reason)
            userStore.errorMessage = nil
        } catch {
            userStore.errorMessage = "Couldn't submit report. Try again."
        }
    }
}

// MARK: - MemberListSheet
struct MemberListSheet: View {
    let circle: Circle
    let memberProfiles: [String: MemberProfile]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(circle.memberIds as [String], id: \.self) { uid in
                    let profile = memberProfiles[uid]
                    let name = profile?.displayName ?? "A Brother"
                    HStack(spacing: 14) {
                        ZStack {
                            SwiftUI.Circle()
                                .fill(profile?.isActiveToday == true
                                      ? Color("BrandAnchor")
                                      : Color("BrandAnchor").opacity(0.15))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    SwiftUI.Circle()
                                        .stroke(profile?.isActiveToday == true ? Color("BrandGold") : Color.clear,
                                                lineWidth: 2)
                                )
                            Text(String(name.prefix(1)).uppercased())
                                .font(.system(size: 16, weight: .heavy))
                                .foregroundColor(profile?.isActiveToday == true ? .white : Color("BrandAnchor"))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(name)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color("TextPrimary"))
                            if uid == circle.creatorId {
                                Text("Circle Leader")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color("BrandGold"))
                            } else if profile?.isActiveToday == true {
                                Text("Active today")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color("BrandAnchor"))
                            } else if let days = profile?.daysSinceActive, days >= 2 {
                                Text("Last seen \(days) day\(days == 1 ? "" : "s") ago")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color("BrandWarning"))
                            }
                        }
                        Spacer()
                        if let streak = profile?.currentStreak, streak > 0 {
                            HStack(spacing: 3) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 11))
                                    .foregroundColor(profile?.isStreakAlive == true ? Color("BrandGold") : Color("TextSecondary").opacity(0.4))
                                Text("\(streak)")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(profile?.isStreakAlive == true ? Color("BrandGold") : Color("TextSecondary").opacity(0.4))
                            }
                        }
                    }
                    .listRowBackground(Color("CardBackground"))
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color("BackgroundPrimary").ignoresSafeArea())
            .navigationTitle("Brothers (\(circle.memberCount))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }.foregroundColor(Color("BrandAnchor"))
                }
            }
        }
    }
}

// MARK: - BattleFormationCard
/// Shows every brother's accountability status at a glance.
/// Active today = bright anchor color with gold ring.
/// Streak alive but not today = muted.
/// Gone dark 2+ days = warning — someone call that man.
struct BattleFormationCard: View {
    let memberIds: [String]
    let profiles: [String: MemberProfile]

    private var activeToday: Int {
        memberIds.filter { profiles[$0]?.isActiveToday == true }.count
    }

    private var isolated: [MemberProfile] {
        memberIds.compactMap { profiles[$0] }.filter { $0.daysSinceActive >= 2 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Image(systemName: "shield.fill")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundColor(Color("BrandAnchor"))
                Text("BATTLE FORMATION")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundColor(Color("BrandAnchor"))
                    .tracking(0.5)
                Spacer()
                Text("\(activeToday)/\(memberIds.count) active today")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(activeToday == memberIds.count ? Color("BrandGold") : Color("TextSecondary"))
            }

            // Member dot row
            HStack(spacing: 10) {
                ForEach(memberIds, id: \.self) { uid in
                    brotherDot(uid: uid, profile: profiles[uid])
                }
                Spacer()
            }

            // Alert if anyone has gone dark
            if !isolated.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color("BrandWarning"))
                        .padding(.top, 1)
                    Text(isolated.count == 1
                         ? "\(isolated[0].displayName) hasn't checked in — your brother may need a call."
                         : "\(isolated.count) brothers haven't checked in. The lion circles the isolated.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color("BrandWarning"))
                        .lineSpacing(3)
                }
                .padding(10)
                .background(Color("BrandWarning").opacity(0.08))
                .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color("CardBackground"))
        .cornerRadius(16)
    }

    @ViewBuilder
    private func brotherDot(uid: String, profile: MemberProfile?) -> some View {
        VStack(spacing: 4) {
            ZStack {
                SwiftUI.Circle()
                    .fill(dotFill(profile))
                    .frame(width: 42, height: 42)
                    .overlay(
                        SwiftUI.Circle()
                            .stroke(profile?.isActiveToday == true ? Color("BrandGold") : Color.clear,
                                    lineWidth: 2.5)
                    )
                Text(String((profile?.displayName ?? "?").prefix(1)).uppercased())
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundColor(.white)
            }
            // Streak badge
            if let p = profile, p.currentStreak > 0 {
                HStack(spacing: 2) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(p.isStreakAlive ? Color("BrandGold") : Color("TextSecondary").opacity(0.4))
                    Text("\(p.currentStreak)")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundColor(p.isStreakAlive ? Color("BrandGold") : Color("TextSecondary").opacity(0.4))
                }
            } else {
                // Placeholder so all dots align
                Text(" ")
                    .font(.system(size: 9))
            }
        }
    }

    private func dotFill(_ profile: MemberProfile?) -> Color {
        guard let p = profile else { return Color("TextSecondary").opacity(0.25) }
        if p.isActiveToday   { return Color("BrandAnchor") }
        if p.isStreakAlive   { return Color("BrandAnchor").opacity(0.45) }
        if p.daysSinceActive < 7 { return Color("BrandWarning").opacity(0.55) }
        return Color("TextSecondary").opacity(0.25)
    }
}

// MARK: - PrayerWallSection
struct PrayerWallSection: View {
    let posts: [CirclePost]
    let onPray: (CirclePost) -> Void
    let onMarkAnswered: (CirclePost) -> Void

    private var active: [CirclePost] { posts.filter { !$0.isAnswered } }
    private var answered: [CirclePost] { posts.filter { $0.isAnswered } }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "hands.sparkles.fill")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundColor(Color("BrandGold"))
                Text("PRAYER WALL")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundColor(Color("BrandGold"))
                    .tracking(0.5)
                Spacer()
                if !answered.isEmpty {
                    Label("\(answered.count) answered", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color("BrandArrow"))
                }
            }

            ForEach(active) { post in
                PrayerCard(
                    post: post,
                    onPray: { onPray(post) },
                    onMarkAnswered: { onMarkAnswered(post) }
                )
            }

            if !answered.isEmpty {
                Divider().padding(.vertical, 2)
                VStack(spacing: 8) {
                    ForEach(answered) { post in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color("BrandArrow"))
                            Text(post.content)
                                .font(.system(size: 13))
                                .foregroundColor(Color("TextSecondary"))
                                .lineLimit(2)
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color("BrandGold").opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color("BrandGold").opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - PrayerCard
struct PrayerCard: View {
    let post: CirclePost
    let onPray: () -> Void
    let onMarkAnswered: () -> Void

    private var prayingCount: Int { post.reactions["🙏"] ?? 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(post.isAnonymous ? "A brother asks for prayer:" : "\(post.authorName) asks for prayer:")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color("TextSecondary"))

            Text(post.content)
                .font(.system(size: 14))
                .foregroundColor(Color("TextPrimary"))
                .lineSpacing(4)

            HStack(spacing: 8) {
                Button(action: onPray) {
                    HStack(spacing: 6) {
                        Text("🙏")
                        Text(prayingCount > 0 ? "\(prayingCount) praying" : "I'm praying for this")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(Color("BrandGold"))
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(Color("BrandGold").opacity(0.12))
                    .cornerRadius(20)
                }
                .buttonStyle(.plain)

                Spacer()

                Button(action: onMarkAnswered) {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle")
                        Text("Answered")
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color("BrandArrow"))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(Color("CardBackground"))
        .cornerRadius(12)
    }
}

// MARK: - CirclePostRow
struct CirclePostRow: View {
    let post: CirclePost
    var isLeader: Bool = false
    var canModerate: Bool = false
    let onReact: (String) -> Void
    let onComment: () -> Void
    var onPin: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    var onReport: (() -> Void)? = nil

    private let reactionEmojis = ["🔥", "🙏", "🙌", "💪"]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Pinned banner
            if post.isPinned {
                HStack(spacing: 4) {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 10, weight: .semibold))
                    Text("Pinned")
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundColor(Color("BrandGold"))
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background(Color("BrandGold").opacity(0.12))
                .cornerRadius(6)
            }

            // Type badge + time + leader menu
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: post.type.icon)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(post.type.color))
                    Text(post.type.displayName)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(post.type.color))
                }
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(Color(post.type.color).opacity(0.1))
                .cornerRadius(8)
                Spacer()
                Text(post.timestamp.timeAgo)
                    .font(.system(size: 11))
                    .foregroundColor(Color("TextSecondary"))

                // Post actions menu
                if isLeader || canModerate || onReport != nil {
                    Menu {
                        if isLeader, let onPin {
                            Button {
                                onPin()
                            } label: {
                                Label(post.isPinned ? "Unpin Post" : "Pin to Top",
                                      systemImage: post.isPinned ? "pin.slash" : "pin.fill")
                            }
                        }
                        if canModerate, let onDelete {
                            Button(role: .destructive) { onDelete() } label: {
                                Label("Delete Post", systemImage: "trash")
                            }
                        }
                        if let onReport {
                            Button { onReport() } label: {
                                Label("Report Post", systemImage: "flag")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 13))
                            .foregroundColor(Color("TextSecondary"))
                            .padding(.leading, 4)
                    }
                }
            }
            // Author
            Text(post.isAnonymous ? "A brother shared:" : post.authorName)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color("TextSecondary"))
            // Content
            Text(post.content)
                .font(.system(size: 15))
                .foregroundColor(Color("TextPrimary"))
                .lineSpacing(4)
            // Reactions + Reply row
            HStack(spacing: 6) {
                ForEach(reactionEmojis, id: \.self) { emoji in
                    Button { onReact(emoji) } label: {
                        HStack(spacing: 3) {
                            Text(emoji).font(.system(size: 14))
                            let count = post.reactions[emoji] ?? 0
                            if count > 0 {
                                Text("\(count)")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Color("TextSecondary"))
                            }
                        }
                        .padding(.horizontal, 9).padding(.vertical, 5)
                        .background(Color("BackgroundPrimary"))
                        .cornerRadius(20)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
                Button(action: onComment) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 12))
                        Text("Reply")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(Color("BrandAnchor"))
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Color("BackgroundPrimary"))
                    .cornerRadius(20)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(Color("CardBackground"))
        .cornerRadius(14)
    }
}

// MARK: - CommentsSheet
struct CommentsSheet: View {
    let post: CirclePost
    let circle: Circle

    @EnvironmentObject var userStore: UserStore
    @Environment(\.dismiss) var dismiss
    @State private var comments: [CircleComment] = []
    @State private var isLoading = false
    @State private var newComment = ""
    @State private var isPosting = false
    @State private var isAnonymous = false
    @State private var commentToReport: CircleComment?
    @State private var showReportSheet = false
    @FocusState private var focused: Bool

    private let service = FirestoreService.shared

    private var canModerate: Bool {
        let uid = Auth.auth().currentUser?.uid
        return userStore.isAdmin || (circle.creatorId == uid && userStore.isPremium)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        // Original post context
                        VStack(alignment: .leading, spacing: 8) {
                            Text(post.isAnonymous ? "A brother shared:" : post.authorName)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color("TextSecondary"))
                            Text(post.content)
                                .font(.system(size: 15))
                                .foregroundColor(Color("TextPrimary"))
                                .lineSpacing(4)
                        }
                        .padding(14)
                        .background(Color("BrandAnchor").opacity(0.06))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color("BrandAnchor").opacity(0.15), lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 16)

                        if isLoading {
                            ProgressView().padding(.top, 24).frame(maxWidth: .infinity)
                        } else if comments.isEmpty {
                            Text("No replies yet. Encourage your brother.")
                                .font(.system(size: 14))
                                .foregroundColor(Color("TextSecondary"))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 24)
                        } else {
                            ForEach(comments) { comment in
                                CommentRow(
                                    comment: comment,
                                    canModerate: canModerate,
                                    onDelete: canModerate ? {
                                        Task { await deleteComment(comment) }
                                    } : nil,
                                    onReport: {
                                        commentToReport = comment
                                        showReportSheet = true
                                    }
                                )
                                .padding(.horizontal, 20)
                            }
                        }
                        Spacer(minLength: 80)
                    }
                }

                // Comment input bar
                VStack(spacing: 0) {
                    Divider()
                    VStack(spacing: 8) {
                        Toggle(isOn: $isAnonymous) {
                            Text("Reply anonymously")
                                .font(.system(size: 13))
                                .foregroundColor(Color("TextSecondary"))
                        }
                        .tint(Color("BrandAnchor"))

                        HStack(spacing: 10) {
                            TextField("Reply to your brother...", text: $newComment, axis: .vertical)
                                .font(.system(size: 14))
                                .focused($focused)
                                .lineLimit(1...4)
                                .padding(10)
                                .background(Color("CardBackground"))
                                .cornerRadius(12)

                            Button { Task { await submitComment() } } label: {
                                Image(systemName: isPosting ? "hourglass" : "arrow.up.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(newComment.trimmingCharacters(in: .whitespaces).isEmpty
                                        ? Color("TextSecondary").opacity(0.3)
                                        : Color("BrandAnchor"))
                            }
                            .disabled(newComment.trimmingCharacters(in: .whitespaces).isEmpty || isPosting)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color("BackgroundPrimary"))
                }
            }
            .background(Color("BackgroundPrimary").ignoresSafeArea())
            .navigationTitle("Replies")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }.foregroundColor(Color("BrandAnchor"))
                }
            }
        }
        .task { await loadComments() }
        .sheet(isPresented: $showReportSheet) {
            ReportSheet(
                onSubmit: { reason in
                    if let comment = commentToReport {
                        Task { await reportComment(comment, reason: reason) }
                    }
                    showReportSheet = false
                },
                onCancel: { showReportSheet = false }
            )
        }
    }

    private func deleteComment(_ comment: CircleComment) async {
        guard let circleId = circle.id, let postId = post.id, let commentId = comment.id else { return }
        do {
            try await service.deleteComment(circleId: circleId, postId: postId, commentId: commentId)
            comments.removeAll { $0.id == commentId }
        } catch {
            userStore.errorMessage = "Couldn't delete comment. Try again."
        }
    }

    private func reportComment(_ comment: CircleComment, reason: String) async {
        guard let uid = Auth.auth().currentUser?.uid,
              let circleId = circle.id,
              let postId = post.id else { return }
        do {
            try await service.submitReport(reporterId: uid, circleId: circleId, postId: postId, commentId: comment.id, reason: reason)
        } catch {
            userStore.errorMessage = "Couldn't submit report. Try again."
        }
    }

    private func loadComments() async {
        guard let circleId = circle.id, let postId = post.id else { return }
        isLoading = true
        comments = (try? await service.fetchComments(circleId: circleId, postId: postId)) ?? []
        isLoading = false
    }

    private func submitComment() async {
        guard let uid = Auth.auth().currentUser?.uid,
              let circleId = circle.id,
              let postId = post.id else { return }
        let content = newComment.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }
        isPosting = true
        let comment = CircleComment(
            postId: postId,
            circleId: circleId,
            authorId: uid,
            authorName: userStore.displayName,
            content: content,
            isAnonymous: isAnonymous,
            timestamp: Date()
        )
        do {
            try await service.postComment(comment: comment)
            comments.append(comment)
            newComment = ""
        } catch {
            userStore.errorMessage = "Couldn't post comment. Check your connection."
        }
        isPosting = false
    }
}

// MARK: - CommentRow
struct CommentRow: View {
    let comment: CircleComment
    var canModerate: Bool = false
    var onDelete: (() -> Void)? = nil
    var onReport: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                SwiftUI.Circle()
                    .fill(Color("BrandAnchor").opacity(0.1))
                    .frame(width: 30, height: 30)
                Text(comment.isAnonymous ? "?" : String(comment.authorName.prefix(1)).uppercased())
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundColor(Color("BrandAnchor"))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(comment.isAnonymous ? "A brother" : comment.authorName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color("TextSecondary"))
                Text(comment.content)
                    .font(.system(size: 14))
                    .foregroundColor(Color("TextPrimary"))
                    .lineSpacing(3)
                Text(comment.timestamp.timeAgo)
                    .font(.system(size: 11))
                    .foregroundColor(Color("TextSecondary").opacity(0.6))
            }
            Spacer()
            if canModerate || onReport != nil {
                Menu {
                    if canModerate, let onDelete {
                        Button(role: .destructive) { onDelete() } label: {
                            Label("Delete Comment", systemImage: "trash")
                        }
                    }
                    if let onReport {
                        Button { onReport() } label: {
                            Label("Report Comment", systemImage: "flag")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 11))
                        .foregroundColor(Color("TextSecondary").opacity(0.4))
                        .padding(6)
                }
            }
        }
        .padding(.vertical, 6)
    }
}

// MARK: - ReportSheet
struct ReportSheet: View {
    let onSubmit: (String) -> Void
    let onCancel: () -> Void

    @State private var reason = ""
    @FocusState private var focused: Bool

    private let reasons = [
        "Inappropriate or offensive content",
        "Spam or self-promotion",
        "Harassment or bullying",
        "Threatening language",
        "Other"
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Why are you reporting this?")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
                    .padding(.top, 8)

                VStack(spacing: 10) {
                    ForEach(reasons, id: \.self) { r in
                        Button {
                            reason = r
                        } label: {
                            HStack {
                                Text(r)
                                    .font(.system(size: 15))
                                    .foregroundColor(Color("TextPrimary"))
                                Spacer()
                                if reason == r {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color("BrandAnchor"))
                                }
                            }
                            .padding(14)
                            .background(reason == r ? Color("BrandAnchor").opacity(0.08) : Color("CardBackground"))
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)

                Button {
                    onSubmit(reason)
                } label: {
                    Text("Submit Report")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(reason.isEmpty ? Color("TextSecondary").opacity(0.3) : Color("BrandDanger"))
                        .cornerRadius(14)
                }
                .disabled(reason.isEmpty)
                .padding(.horizontal, 20)

                Text("Reports are reviewed by our team. Thank you for helping keep this community safe.")
                    .font(.system(size: 12))
                    .foregroundColor(Color("TextSecondary"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Spacer()
            }
            .background(Color("BackgroundPrimary").ignoresSafeArea())
            .navigationTitle("Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { onCancel() }
                        .foregroundColor(Color("TextSecondary"))
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - CreateCircleView
struct CreateCircleView: View {
    let onCreate: (Circle) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var circleName = ""
    @State private var isPublic = false
    @State private var isCreating = false
    @State private var errorMessage = ""
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Name your circle — something that represents your brotherhood.")
                    .font(.system(size: 15))
                    .foregroundColor(Color("TextSecondary"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 24)

                AuthTextField(icon: "person.3.fill", placeholder: "Circle name (e.g. The Remnant)", text: $circleName)
                    .focused($focused)
                    .padding(.horizontal, 24)

                // Public / Private toggle with explanation
                VStack(spacing: 14) {
                    Toggle(isOn: $isPublic) {
                        HStack(spacing: 10) {
                            Image(systemName: isPublic ? "globe" : "lock.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(isPublic ? Color("BrandArrow") : Color("BrandAnchor"))
                                .frame(width: 22)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(isPublic ? "Public Circle" : "Private Circle")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color("TextPrimary"))
                            }
                        }
                    }
                    .tint(Color("BrandArrow"))

                    // Contextual explanation
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color("TextSecondary").opacity(0.6))
                            .padding(.top, 1)
                        Text(isPublic
                             ? "Anyone can find and join this circle. All users (free or premium) can read posts. Great for open communities."
                             : "Only people with the invite code can join. Best for close accountability groups.")
                            .font(.system(size: 13))
                            .foregroundColor(Color("TextSecondary"))
                            .lineSpacing(3)
                    }
                    .padding(12)
                    .background(Color("CardBackground"))
                    .cornerRadius(10)
                    .animation(.easeInOut(duration: 0.2), value: isPublic)
                }
                .padding(.horizontal, 24)

                if let nameError = circleNameError {
                    Text(nameError)
                        .font(.system(size: 13))
                        .foregroundColor(Color("BrandWarning"))
                        .padding(.horizontal, 24)
                }

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.system(size: 14))
                        .foregroundColor(Color("BrandDanger"))
                }

                Button {
                    Task { await createCircle() }
                } label: {
                    ZStack {
                        if isCreating { ProgressView().tint(.white) }
                        else {
                            Text("Create Circle")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity).frame(height: 52)
                    .background(!isCircleNameValid ? Color("TextSecondary").opacity(0.3) : Color("BrandAnchor"))
                    .cornerRadius(14)
                    .padding(.horizontal, 24)
                }
                .disabled(!isCircleNameValid || isCreating)

                Spacer()
            }
            .background(Color("BackgroundPrimary").ignoresSafeArea())
            .navigationTitle("Create a Circle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundColor(Color("TextSecondary"))
                }
            }
            .onAppear { focused = true }
        }
    }

    private var trimmedCircleName: String { circleName.trimmingCharacters(in: .whitespacesAndNewlines) }

    private var circleNameError: String? {
        let name = trimmedCircleName
        if name.isEmpty { return nil } // don't show error until they type
        if name.count < 3 { return "Name must be at least 3 characters" }
        if name.count > 40 { return "Name must be under 40 characters" }
        return nil
    }

    private var isCircleNameValid: Bool {
        let name = trimmedCircleName
        return name.count >= 3 && name.count <= 40
    }

    private func createCircle() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard isCircleNameValid else { return }
        isCreating = true
        var newCircle = Circle.new(name: trimmedCircleName, creatorId: uid, isPublic: isPublic)
        do {
            let id = try await FirestoreService.shared.createCircle(circle: newCircle)
            // Use the local circle with the Firestore-assigned ID instead of re-fetching,
            // which can fail due to Firestore read rules or propagation delay.
            newCircle.id = id
            onCreate(newCircle)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        isCreating = false
    }
}

// MARK: - JoinCircleView
struct JoinCircleView: View {
    let onJoin: (Circle) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var code = ""
    @State private var isJoining = false
    @State private var errorMessage = ""
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Enter the 6-character invite code shared by a brother.")
                    .font(.system(size: 15))
                    .foregroundColor(Color("TextSecondary"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 24)

                TextField("INVITE CODE", text: $code)
                    .font(.system(size: 26, weight: .heavy, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .padding(20)
                    .background(Color("CardBackground"))
                    .cornerRadius(14)
                    .padding(.horizontal, 24)
                    .focused($focused)
                    .onChange(of: code) { code = String(code.prefix(6).uppercased()) }

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.system(size: 14))
                        .foregroundColor(Color("BrandDanger"))
                }

                Button {
                    Task { await joinCircle() }
                } label: {
                    ZStack {
                        if isJoining { ProgressView().tint(.white) }
                        else {
                            Text("Join Circle")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity).frame(height: 52)
                    .background(code.count < 6 ? Color("TextSecondary").opacity(0.3) : Color("BrandAnchor"))
                    .cornerRadius(14)
                    .padding(.horizontal, 24)
                }
                .disabled(code.count < 6 || isJoining)

                Spacer()
            }
            .background(Color("BackgroundPrimary").ignoresSafeArea())
            .navigationTitle("Join a Circle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundColor(Color("TextSecondary"))
                }
            }
            .onAppear { focused = true }
        }
    }

    private func joinCircle() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isJoining = true
        errorMessage = ""
        do {
            let circle = try await FirestoreService.shared.joinCircle(code: code, uid: uid)
            onJoin(circle)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        isJoining = false
    }
}

// MARK: - NewCirclePostView
struct NewCirclePostView: View {
    let circleId: String
    let preselectedType: PostType?
    let onPost: (CirclePost) -> Void

    @EnvironmentObject var userStore: UserStore
    @Environment(\.dismiss) var dismiss
    @State private var content = ""
    @State private var selectedType: PostType = .general
    @State private var isAnonymous = false
    @State private var isPosting = false
    @FocusState private var focused: Bool

    init(circleId: String, preselectedType: PostType? = nil, onPost: @escaping (CirclePost) -> Void) {
        self.circleId = circleId
        self.preselectedType = preselectedType
        self.onPost = onPost
        _selectedType = State(initialValue: preselectedType ?? .general)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(PostType.allCases, id: \.self) { type in
                            Button { selectedType = type } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: type.icon)
                                    Text(type.displayName)
                                }
                                .font(.system(size: 13, weight: .semibold))
                                .padding(.horizontal, 12).padding(.vertical, 8)
                                .background(selectedType == type ? Color(type.color) : Color("CardBackground"))
                                .foregroundColor(selectedType == type ? .white : Color("TextSecondary"))
                                .cornerRadius(20)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // Contextual nudge for the selected post type
                HStack(spacing: 8) {
                    Image(systemName: selectedType.icon)
                        .font(.system(size: 12))
                        .foregroundColor(Color(selectedType.color))
                    Text(selectedType.postHint)
                        .font(.system(size: 13))
                        .foregroundColor(Color("TextSecondary"))
                        .lineSpacing(2)
                }
                .padding(.horizontal, 20)
                .transition(.opacity.combined(with: .move(edge: .top)))
                .animation(.easeInOut(duration: 0.2), value: selectedType)

                ZStack(alignment: .topLeading) {
                    if content.isEmpty {
                        Text("Share with your brothers...")
                            .font(.system(size: 15))
                            .foregroundColor(Color("TextSecondary").opacity(0.5))
                            .padding(.top, 12).padding(.leading, 5)
                    }
                    TextEditor(text: $content)
                        .font(.system(size: 15))
                        .foregroundColor(Color("TextPrimary"))
                        .scrollContentBackground(.hidden)
                        .focused($focused)
                        .frame(minHeight: 120)
                }
                .padding(14)
                .background(Color("CardBackground"))
                .cornerRadius(14)
                .padding(.horizontal, 20)

                Toggle(isOn: $isAnonymous) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Post anonymously")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color("TextPrimary"))
                        Text("Your name won't be shown")
                            .font(.system(size: 12))
                            .foregroundColor(Color("TextSecondary"))
                    }
                }
                .tint(Color("BrandAnchor"))
                .padding(.horizontal, 20)

                Spacer()
            }
            .padding(.top, 20)
            .background(Color("BackgroundPrimary").ignoresSafeArea())
            .navigationTitle("Share with Circle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundColor(Color("TextSecondary"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") { Task { await submitPost() } }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(content.isEmpty ? Color("TextSecondary") : Color("BrandAnchor"))
                        .disabled(content.isEmpty || isPosting)
                }
            }
            .onAppear { focused = true }
        }
    }

    private func submitPost() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isPosting = true
        let post = CirclePost(
            circleId: circleId,
            authorId: uid,
            authorName: userStore.displayName,
            content: content,
            type: selectedType,
            isAnonymous: isAnonymous,
            timestamp: Date()
        )
        do {
            try await FirestoreService.shared.postToCircle(post: post)
            onPost(post)
            dismiss()
        } catch {
            userStore.errorMessage = "Couldn't share post. Check your connection."
        }
        isPosting = false
    }
}

// MARK: - BrowsePublicCirclesView
struct BrowsePublicCirclesView: View {
    let onJoin: (Circle) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var publicCircles: [Circle] = []
    @State private var isLoading = false
    @State private var joiningCircleId: String?
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    SkeletonCirclesList()
                } else if publicCircles.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "globe")
                            .font(.system(size: 44))
                            .foregroundColor(Color("TextSecondary").opacity(0.4))
                        Text("No Public Circles Yet")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(Color("TextPrimary"))
                        Text("Be the first to create one — tap Create a Circle and set it to Public.")
                            .font(.system(size: 14))
                            .foregroundColor(Color("TextSecondary"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        Spacer()
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            // Explanation banner
                            HStack(spacing: 10) {
                                Image(systemName: "globe")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color("BrandArrow"))
                                Text("Public circles are open to all. Join to read posts, share, and find brotherhood.")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color("TextSecondary"))
                                    .lineSpacing(3)
                            }
                            .padding(14)
                            .background(Color("BrandArrow").opacity(0.08))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)

                            if !errorMessage.isEmpty {
                                Text(errorMessage)
                                    .font(.system(size: 13))
                                    .foregroundColor(Color("BrandDanger"))
                                    .padding(.horizontal, 20)
                            }

                            ForEach(publicCircles) { circle in
                                PublicCircleRow(
                                    circle: circle,
                                    isJoining: joiningCircleId == circle.id,
                                    onJoinTap: { Task { await joinCircle(circle) } }
                                )
                                .padding(.horizontal, 20)
                            }

                            Spacer(minLength: 40)
                        }
                        .padding(.top, 16)
                    }
                }
            }
            .background(Color("BackgroundPrimary").ignoresSafeArea())
            .navigationTitle("Public Circles")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Color("TextSecondary"))
                }
            }
            .task { await loadPublicCircles() }
        }
    }

    private func loadPublicCircles() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        publicCircles = (try? await FirestoreService.shared.fetchPublicCircles(excludingUid: uid)) ?? []
        isLoading = false
    }

    private func joinCircle(_ circle: Circle) async {
        guard let uid = Auth.auth().currentUser?.uid,
              let circleId = circle.id else { return }
        joiningCircleId = circleId
        errorMessage = ""
        do {
            let joined = try await FirestoreService.shared.joinPublicCircle(circleId: circleId, uid: uid)
            onJoin(joined)
            publicCircles.removeAll { $0.id == circleId }
        } catch {
            errorMessage = error.localizedDescription
        }
        joiningCircleId = nil
    }
}

// MARK: - PublicCircleRow
private struct PublicCircleRow: View {
    let circle: Circle
    let isJoining: Bool
    let onJoinTap: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                SwiftUI.Circle()
                    .fill(Color("BrandArrow").opacity(0.15))
                    .frame(width: 48, height: 48)
                Text(String(circle.name.prefix(2)).uppercased())
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundColor(Color("BrandArrow"))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(circle.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
                HStack(spacing: 6) {
                    Label("\(circle.memberCount)/8", systemImage: "person.2.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color("TextSecondary"))
                    if circle.memberCount >= 7 {
                        Text("Almost full")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color("BrandWarning"))
                    }
                }
            }

            Spacer()

            Button(action: onJoinTap) {
                Group {
                    if isJoining {
                        ProgressView()
                            .tint(Color("BrandArrow"))
                    } else {
                        Text("Join")
                            .font(.system(size: 14, weight: .bold))
                    }
                }
                .foregroundColor(Color("BrandArrow"))
                .padding(.horizontal, 18)
                .padding(.vertical, 8)
                .background(Color("BrandArrow").opacity(0.12))
                .cornerRadius(10)
            }
            .disabled(isJoining || circle.memberCount >= 8)
        }
        .padding(14)
        .background(Color("CardBackground"))
        .cornerRadius(14)
    }
}

// MARK: - Date extension
extension Date {
    var timeAgo: String {
        let diff = Date().timeIntervalSince(self)
        if diff < 60 { return "now" }
        if diff < 3600 { return "\(Int(diff / 60))m ago" }
        if diff < 86400 { return "\(Int(diff / 3600))h ago" }
        return "\(Int(diff / 86400))d ago"
    }
}
