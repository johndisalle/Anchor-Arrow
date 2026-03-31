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
        if !userStore.hasAcceptedTerms {
            TermsAcceptanceView()
        } else {
            circlesContent
        }
    }

    private var circlesContent: some View {
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
            .aaScreenBackground()
            .navigationTitle("Iron Sharpeners")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AATheme.background, for: .navigationBar)
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
                            .foregroundColor(AATheme.steel)
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
                .foregroundColor(AATheme.steel.opacity(0.5))
            VStack(spacing: 10) {
                Text("No Circles Yet")
                    .font(AATheme.headlineFont)
                    .foregroundColor(AATheme.primaryText)
                Text("\"As iron sharpens iron, so one person sharpens another.\" — Proverbs 27:17")
                    .font(.system(size: 15, weight: .medium, design: .serif))
                    .italic()
                    .foregroundColor(AATheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, 32)
                Text("Start or join a circle of 3–8 brothers to share wins, struggles, and accountability.")
                    .font(.system(size: 14))
                    .foregroundColor(AATheme.secondaryText)
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
                    .background(AATheme.steel)
                    .cornerRadius(AATheme.cornerRadius)
                }
                Button { showJoinCircle = true } label: {
                    HStack {
                        Image(systemName: "link")
                        Text("Join with Invite Code")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(AATheme.steel)
                    .frame(maxWidth: .infinity).frame(height: 52)
                    .background(AATheme.steel.opacity(0.1))
                    .cornerRadius(AATheme.cornerRadius)
                }
                Button { showBrowsePublic = true } label: {
                    HStack {
                        Image(systemName: "globe")
                        Text("Browse Public Circles")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(AATheme.amber)
                    .frame(maxWidth: .infinity).frame(height: 52)
                    .background(AATheme.amber.opacity(0.1))
                    .cornerRadius(AATheme.cornerRadius)
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
                            .foregroundColor(AATheme.warmGold)
                        Text("Free plan: react only. Upgrade to post and comment.")
                            .font(.system(size: 13))
                            .foregroundColor(AATheme.secondaryText)
                        Spacer()
                        Button("Upgrade") { showPremiumUpsell = true }
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AATheme.warmGold)
                    }
                    .padding(14)
                    .background(AATheme.warmGold.opacity(0.1))
                    .cornerRadius(AATheme.cornerRadiusSmall)
                    .padding(.horizontal, AATheme.paddingLarge)
                }
                ForEach(circles) { circle in
                    CircleCard(circle: circle,
                               activeThisWeek: circleActivity[circle.id ?? ""]) {
                        selectedCircle = circle
                    }
                    .padding(.horizontal, AATheme.paddingLarge)
                }
                Spacer(minLength: 100)
            }
            .padding(.top, 16)
        }
    }

    private func loadCircles() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isLoading = true

        // Ensure user is in the Global Brotherhood before fetching circles
        _ = await firestoreService.ensureGlobalCircleMembership(uid: uid)

        // Seed today's devotional into Global Brotherhood if not already posted
        await firestoreService.seedGlobalBrotherhoodPost()

        circles = (try? await firestoreService.fetchUserCircles(uid: uid)) ?? []

        // Ensure Global Brotherhood appears first
        circles.sort { a, b in
            if a.id == FirestoreService.globalCircleId { return true }
            if b.id == FirestoreService.globalCircleId { return false }
            return false
        }

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
                        .fill(AATheme.steel.opacity(0.15))
                        .frame(width: 52, height: 52)
                    Text(String(circle.name.prefix(2)).uppercased())
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(AATheme.steel)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(circle.name)
                        .font(AATheme.subheadlineFont)
                        .foregroundColor(AATheme.primaryText)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        Label("\(circle.memberCount) \(circle.memberCount == 1 ? "brother" : "brothers")", systemImage: "person.2.fill")
                            .font(.system(size: 12))
                            .foregroundColor(AATheme.secondaryText)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)

                        // Public/Private badge
                        HStack(spacing: 3) {
                            Image(systemName: circle.isPublic ? "globe" : "lock.fill")
                                .font(.system(size: 9, weight: .semibold))
                            Text(circle.isPublic ? "Public" : "Private")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(circle.isPublic ? AATheme.amber : AATheme.secondaryText)
                        .fixedSize(horizontal: true, vertical: false)

                        // Weekly health badge
                        if let active = activeThisWeek {
                            HStack(spacing: 3) {
                                SwiftUI.Circle()
                                    .fill(active == circle.memberCount ? AATheme.amber : AATheme.warning)
                                    .frame(width: 6, height: 6)
                                Text("\(active)/\(circle.memberCount) active")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(active == circle.memberCount
                                                     ? AATheme.amber : AATheme.warning)
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
                    .foregroundColor(showCopiedToast ? AATheme.amber : AATheme.steel)
                    .padding(.horizontal, 8).padding(.vertical, 5)
                    .background(AATheme.steel.opacity(0.1))
                    .cornerRadius(AATheme.cornerRadiusSmall)
                }
                .buttonStyle(.plain)
                .fixedSize(horizontal: true, vertical: false)
                .accessibilityLabel(showCopiedToast ? "Invite code copied" : "Copy invite code \(circle.inviteCode)")

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AATheme.secondaryText)
            }
            .padding(AATheme.paddingMedium)
            .background(AATheme.cardBackground)
            .cornerRadius(AATheme.cornerRadius)
            .shadow(color: AATheme.cardShadow, radius: AATheme.cardShadowRadius, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(circle.name), \(circle.memberCount) \(circle.memberCount == 1 ? "brother" : "brothers"), \(circle.isPublic ? "public" : "private") circle")
        .accessibilityHint("Double tap to open this circle")
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
    @State private var userToBlock: String?
    @State private var showBlockConfirm = false

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

                                // Prayer Wall — pinned above feed (exclude blocked)
                                let blocked = userStore.blockedUserIds
                                let prayerPosts = posts.filter { $0.type == .prayer && !blocked.contains($0.authorId) }
                                if !prayerPosts.isEmpty {
                                    PrayerWallSection(
                                        posts: prayerPosts,
                                        onPray: { post in Task { await react(to: post, emoji: "🙏") } },
                                        onMarkAnswered: { post in Task { await markAnswered(post: post) } }
                                    )
                                    .padding(.horizontal, 20)
                                }

                                // Regular post feed (excludes prayer — shown above, and blocked users)
                                let feedPosts = posts.filter { $0.type != .prayer && !blocked.contains($0.authorId) }
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
                                            },
                                            onBlock: post.authorId != Auth.auth().currentUser?.uid ? {
                                                userToBlock = post.authorId
                                                showBlockConfirm = true
                                            } : nil
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
                                    colors: [AATheme.warning, AATheme.warning.opacity(0.8)],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .cornerRadius(28)
                            .shadow(color: AATheme.warning.opacity(0.4), radius: 10, y: 4)
                        }
                        .buttonStyle(.plain)
                        .padding(.bottom, 20)
                    }
                }
            }
            .aaScreenBackground()
            .navigationTitle(circle.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }.foregroundColor(AATheme.steel)
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    ShareLink(
                        item: URL(string: "anchorarrow://join?code=\(circle.inviteCode)") ?? URL(string: "https://johndisalle.github.io/Anchor-Arrow/")!,
                        subject: Text("Join \(circle.name) on Anchor & Arrow"),
                        message: Text("Join my circle \"\(circle.name)\" on Anchor & Arrow! Use code \(circle.inviteCode) or tap this link.")
                    ) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16))
                            .foregroundColor(AATheme.steel)
                    }
                    Button { showMemberList = true } label: {
                        Image(systemName: "person.2")
                            .font(.system(size: 16))
                            .foregroundColor(AATheme.steel)
                    }
                    Button {
                        if canPost { showNewPost = true }
                        else { showPremiumUpsell = true }
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 17))
                            .foregroundColor(AATheme.steel)
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
                            .foregroundColor(AATheme.secondaryText)
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
            .alert("Block User?", isPresented: $showBlockConfirm) {
                Button("Block", role: .destructive) {
                    if let uid = userToBlock {
                        Task { await userStore.blockUser(uid) }
                    }
                }
                Button("Cancel", role: .cancel) { userToBlock = nil }
            } message: {
                Text("You won't see their posts or comments in any circle. You can unblock them in Settings.")
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
                    .foregroundColor(AATheme.warmGold)
                Text("TODAY'S CIRCLE PROMPT")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundColor(AATheme.warmGold)
                    .tracking(0.5)
                Spacer()
            }
            Text(dailyPrompt)
                .font(.system(size: 15, weight: .medium, design: .serif))
                .foregroundColor(AATheme.primaryText)
                .lineSpacing(4)
        }
        .padding(AATheme.paddingMedium)
        .background(AATheme.warmGold.opacity(0.08))
        .cornerRadius(AATheme.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AATheme.cornerRadius)
                .stroke(AATheme.warmGold.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Empty Posts State
    private var emptyPostsState: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 60)
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 44))
                .foregroundColor(AATheme.secondaryText.opacity(0.4))
            Text("No posts yet. Be the first to share.")
                .font(.system(size: 15))
                .foregroundColor(AATheme.secondaryText)
            if !canPost {
                Button { showPremiumUpsell = true } label: {
                    Text("Upgrade to Post")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20).padding(.vertical, 10)
                        .background(AATheme.warmGold)
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
                                      ? AATheme.steel
                                      : AATheme.steel.opacity(0.15))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    SwiftUI.Circle()
                                        .stroke(profile?.isActiveToday == true ? AATheme.warmGold : Color.clear,
                                                lineWidth: 2)
                                )
                            Text(String(name.prefix(1)).uppercased())
                                .font(.system(size: 16, weight: .heavy))
                                .foregroundColor(profile?.isActiveToday == true ? .white : AATheme.steel)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(name)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(AATheme.primaryText)
                            if uid == circle.creatorId {
                                Text("Circle Leader")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(AATheme.warmGold)
                            } else if profile?.isActiveToday == true {
                                Text("Active today")
                                    .font(.system(size: 11))
                                    .foregroundColor(AATheme.steel)
                            } else if let days = profile?.daysSinceActive, days >= 2 {
                                Text("Last seen \(days) day\(days == 1 ? "" : "s") ago")
                                    .font(.system(size: 11))
                                    .foregroundColor(AATheme.warning)
                            }
                        }
                        Spacer()
                        if let streak = profile?.currentStreak, streak > 0 {
                            HStack(spacing: 3) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 11))
                                    .foregroundColor(profile?.isStreakAlive == true ? AATheme.warmGold : AATheme.secondaryText.opacity(0.4))
                                Text("\(streak)")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(profile?.isStreakAlive == true ? AATheme.warmGold : AATheme.secondaryText.opacity(0.4))
                            }
                        }
                    }
                    .listRowBackground(AATheme.cardBackground)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .aaScreenBackground()
            .navigationTitle("Brothers (\(circle.memberCount))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }.foregroundColor(AATheme.steel)
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
                    .foregroundColor(AATheme.steel)
                Text("BATTLE FORMATION")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundColor(AATheme.steel)
                    .tracking(0.5)
                Spacer()
                Text("\(activeToday)/\(memberIds.count) active today")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(activeToday == memberIds.count ? AATheme.warmGold : AATheme.secondaryText)
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
                        .foregroundColor(AATheme.warning)
                        .padding(.top, 1)
                    Text(isolated.count == 1
                         ? "\(isolated[0].displayName) hasn't checked in — your brother may need a call."
                         : "\(isolated.count) brothers haven't checked in. The lion circles the isolated.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AATheme.warning)
                        .lineSpacing(3)
                }
                .padding(AATheme.cornerRadiusSmall)
                .background(AATheme.warning.opacity(0.08))
                .cornerRadius(AATheme.cornerRadiusSmall)
            }
        }
        .padding(AATheme.paddingMedium)
        .background(AATheme.cardBackground)
        .cornerRadius(AATheme.cornerRadius)
        .shadow(color: AATheme.cardShadow, radius: AATheme.cardShadowRadius, x: 0, y: 2)
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
                            .stroke(profile?.isActiveToday == true ? AATheme.warmGold : Color.clear,
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
                        .foregroundColor(p.isStreakAlive ? AATheme.warmGold : AATheme.secondaryText.opacity(0.4))
                    Text("\(p.currentStreak)")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundColor(p.isStreakAlive ? AATheme.warmGold : AATheme.secondaryText.opacity(0.4))
                }
            } else {
                // Placeholder so all dots align
                Text(" ")
                    .font(.system(size: 9))
            }
        }
    }

    private func dotFill(_ profile: MemberProfile?) -> Color {
        guard let p = profile else { return AATheme.secondaryText.opacity(0.25) }
        if p.isActiveToday   { return AATheme.steel }
        if p.isStreakAlive   { return AATheme.steel.opacity(0.45) }
        if p.daysSinceActive < 7 { return AATheme.warning.opacity(0.55) }
        return AATheme.secondaryText.opacity(0.25)
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
                    .foregroundColor(AATheme.warmGold)
                Text("PRAYER WALL")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundColor(AATheme.warmGold)
                    .tracking(0.5)
                Spacer()
                if !answered.isEmpty {
                    Label("\(answered.count) answered", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AATheme.amber)
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
                                .foregroundColor(AATheme.amber)
                            Text(post.content)
                                .font(.system(size: 13))
                                .foregroundColor(AATheme.secondaryText)
                                .lineLimit(2)
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding(AATheme.paddingMedium)
        .background(AATheme.warmGold.opacity(0.05))
        .cornerRadius(AATheme.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AATheme.cornerRadius)
                .stroke(AATheme.warmGold.opacity(0.2), lineWidth: 1)
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
                .foregroundColor(AATheme.secondaryText)

            Text(post.content)
                .font(.system(size: 14))
                .foregroundColor(AATheme.primaryText)
                .lineSpacing(4)

            HStack(spacing: 8) {
                Button(action: onPray) {
                    HStack(spacing: 6) {
                        Text("🙏")
                        Text(prayingCount > 0 ? "\(prayingCount) praying" : "I'm praying for this")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(AATheme.warmGold)
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(AATheme.warmGold.opacity(0.12))
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
                    .foregroundColor(AATheme.amber)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(AATheme.cardBackground)
        .cornerRadius(AATheme.cornerRadiusSmall)
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
    var onBlock: (() -> Void)? = nil

    private let reactionEmojis = ["\u{1F525}", "\u{1F64F}", "\u{1F64C}", "\u{1F4AA}"]

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
                .foregroundColor(AATheme.warmGold)
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background(AATheme.warmGold.opacity(0.12))
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
                    .foregroundColor(AATheme.secondaryText)

                // Post actions menu
                if isLeader || canModerate || onReport != nil || onBlock != nil {
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
                        if let onBlock {
                            Button(role: .destructive) { onBlock() } label: {
                                Label("Block User", systemImage: "hand.raised")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 13))
                            .foregroundColor(AATheme.secondaryText)
                            .padding(.leading, 4)
                    }
                }
            }
            // Author
            Text(post.isAnonymous ? "A brother shared:" : post.authorName)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(AATheme.secondaryText)
            // Content
            Text(post.content)
                .font(.system(size: 15))
                .foregroundColor(AATheme.primaryText)
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
                                    .foregroundColor(AATheme.secondaryText)
                            }
                        }
                        .padding(.horizontal, 9).padding(.vertical, 5)
                        .background(AATheme.background)
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
                    .foregroundColor(AATheme.steel)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(AATheme.background)
                    .cornerRadius(20)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(AATheme.cardBackground)
        .cornerRadius(AATheme.cornerRadius)
        .shadow(color: AATheme.cardShadow, radius: AATheme.cardShadowRadius, x: 0, y: 2)
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
    @State private var userToBlock: String?
    @State private var showBlockConfirm = false
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
                                .foregroundColor(AATheme.secondaryText)
                            Text(post.content)
                                .font(.system(size: 15))
                                .foregroundColor(AATheme.primaryText)
                                .lineSpacing(4)
                        }
                        .padding(14)
                        .background(AATheme.steel.opacity(0.06))
                        .cornerRadius(AATheme.cornerRadiusSmall)
                        .overlay(
                            RoundedRectangle(cornerRadius: AATheme.cornerRadiusSmall)
                                .stroke(AATheme.steel.opacity(0.15), lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 16)

                        if isLoading {
                            ProgressView().padding(.top, 24).frame(maxWidth: .infinity)
                        } else if comments.isEmpty {
                            Text("No replies yet. Encourage your brother.")
                                .font(.system(size: 14))
                                .foregroundColor(AATheme.secondaryText)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 24)
                        } else {
                            let blocked = userStore.blockedUserIds
                            ForEach(comments.filter { !blocked.contains($0.authorId) }) { comment in
                                CommentRow(
                                    comment: comment,
                                    canModerate: canModerate,
                                    onDelete: canModerate ? {
                                        Task { await deleteComment(comment) }
                                    } : nil,
                                    onReport: {
                                        commentToReport = comment
                                        showReportSheet = true
                                    },
                                    onBlock: comment.authorId != Auth.auth().currentUser?.uid ? {
                                        userToBlock = comment.authorId
                                        showBlockConfirm = true
                                    } : nil
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
                                .foregroundColor(AATheme.secondaryText)
                        }
                        .tint(AATheme.steel)

                        HStack(spacing: 10) {
                            TextField("Reply to your brother...", text: $newComment, axis: .vertical)
                                .font(.system(size: 14))
                                .focused($focused)
                                .lineLimit(1...4)
                                .padding(10)
                                .background(AATheme.cardBackground)
                                .cornerRadius(AATheme.cornerRadiusSmall)

                            Button { Task { await submitComment() } } label: {
                                Image(systemName: isPosting ? "hourglass" : "arrow.up.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(newComment.trimmingCharacters(in: .whitespaces).isEmpty
                                        ? AATheme.secondaryText.opacity(0.3)
                                        : AATheme.steel)
                            }
                            .disabled(newComment.trimmingCharacters(in: .whitespaces).isEmpty || isPosting)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(AATheme.background)
                }
            }
            .aaScreenBackground()
            .navigationTitle("Replies")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }.foregroundColor(AATheme.steel)
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
        .alert("Block User?", isPresented: $showBlockConfirm) {
            Button("Block", role: .destructive) {
                if let uid = userToBlock {
                    Task { await userStore.blockUser(uid) }
                }
            }
            Button("Cancel", role: .cancel) { userToBlock = nil }
        } message: {
            Text("You won't see their posts or comments in any circle. You can unblock them in Settings.")
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
    var onBlock: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                SwiftUI.Circle()
                    .fill(AATheme.steel.opacity(0.1))
                    .frame(width: 30, height: 30)
                Text(comment.isAnonymous ? "?" : String(comment.authorName.prefix(1)).uppercased())
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundColor(AATheme.steel)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(comment.isAnonymous ? "A brother" : comment.authorName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AATheme.secondaryText)
                Text(comment.content)
                    .font(.system(size: 14))
                    .foregroundColor(AATheme.primaryText)
                    .lineSpacing(3)
                Text(comment.timestamp.timeAgo)
                    .font(.system(size: 11))
                    .foregroundColor(AATheme.secondaryText.opacity(0.6))
            }
            Spacer()
            if canModerate || onReport != nil || onBlock != nil {
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
                    if let onBlock {
                        Button(role: .destructive) { onBlock() } label: {
                            Label("Block User", systemImage: "hand.raised")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 11))
                        .foregroundColor(AATheme.secondaryText.opacity(0.4))
                        .padding(6)
                }
            }
        }
        .padding(.vertical, 6)
    }
}

// MARK: - TermsAcceptanceView
/// Shown once before a user can access circles/UGC (Apple Guideline 1.2)
struct TermsAcceptanceView: View {
    @EnvironmentObject var userStore: UserStore
    @State private var isAccepting = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AATheme.paddingLarge) {
                    Spacer().frame(height: AATheme.paddingMedium)

                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 48))
                        .foregroundColor(AATheme.steel)

                    Text("Community Guidelines")
                        .font(AATheme.headlineFont)
                        .foregroundColor(AATheme.primaryText)

                    Text("Before joining Iron Sharpeners circles, please review and accept our Terms of Use.")
                        .font(.system(size: 15))
                        .foregroundColor(AATheme.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AATheme.paddingXLarge)

                    VStack(alignment: .leading, spacing: 14) {
                        guidelineRow(icon: "checkmark.shield.fill",
                                     text: "No objectionable, offensive, or abusive content")
                        guidelineRow(icon: "hand.raised.fill",
                                     text: "Users who violate these terms will be removed")
                        guidelineRow(icon: "flag.fill",
                                     text: "Report inappropriate content — we review within 24 hours")
                        guidelineRow(icon: "person.crop.circle.badge.minus",
                                     text: "Block users to instantly hide their content from your feed")
                    }
                    .padding(AATheme.paddingMedium)
                    .background(AATheme.cardBackground)
                    .cornerRadius(AATheme.cornerRadius)
                    .shadow(color: AATheme.cardShadow, radius: AATheme.cardShadowRadius, x: 0, y: 2)
                    .padding(.horizontal, AATheme.paddingLarge)

                    if let url = URL(string: "https://johndisalle.github.io/Anchor-Arrow/terms-of-use.html") {
                        Link(destination: url) {
                            HStack(spacing: 6) {
                                Text("Read Full Terms of Use")
                                    .font(.system(size: 14, weight: .semibold))
                                Image(systemName: "arrow.up.right.square")
                                    .font(.system(size: 13))
                            }
                            .foregroundColor(AATheme.steel)
                        }
                    }

                    Button {
                        isAccepting = true
                        Task {
                            await userStore.acceptTerms()
                            isAccepting = false
                        }
                    } label: {
                        if isAccepting {
                            ProgressView().tint(.white)
                        } else {
                            Text("I Agree to the Terms of Use")
                        }
                    }
                    .buttonStyle(AAPrimaryButtonStyle())
                    .disabled(isAccepting)
                    .padding(.horizontal, AATheme.paddingLarge)

                    Text("By tapping above, you agree to abide by the community guidelines and Terms of Use. Violations may result in removal from circles.")
                        .font(.system(size: 11))
                        .foregroundColor(AATheme.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AATheme.paddingXLarge)

                    Spacer(minLength: 40)
                }
            }
            .aaScreenBackground()
            .navigationTitle("Iron Sharpeners")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func guidelineRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(AATheme.steel)
                .frame(width: 22)
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(AATheme.primaryText)
                .lineSpacing(3)
        }
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
                    .font(AATheme.subheadlineFont)
                    .foregroundColor(AATheme.primaryText)
                    .padding(.top, 8)

                VStack(spacing: 10) {
                    ForEach(reasons, id: \.self) { r in
                        Button {
                            reason = r
                        } label: {
                            HStack {
                                Text(r)
                                    .font(.system(size: 15))
                                    .foregroundColor(AATheme.primaryText)
                                Spacer()
                                if reason == r {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(AATheme.steel)
                                }
                            }
                            .padding(14)
                            .background(reason == r ? AATheme.steel.opacity(0.08) : AATheme.cardBackground)
                            .cornerRadius(AATheme.cornerRadiusSmall)
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
                        .background(reason.isEmpty ? AATheme.secondaryText.opacity(0.3) : AATheme.destructive)
                        .cornerRadius(AATheme.cornerRadius)
                }
                .disabled(reason.isEmpty)
                .padding(.horizontal, 20)

                Text("Reports are reviewed by our team. Thank you for helping keep this community safe.")
                    .font(.system(size: 12))
                    .foregroundColor(AATheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Spacer()
            }
            .aaScreenBackground()
            .navigationTitle("Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { onCancel() }
                        .foregroundColor(AATheme.secondaryText)
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
                    .foregroundColor(AATheme.secondaryText)
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
                                .foregroundColor(isPublic ? AATheme.amber : AATheme.steel)
                                .frame(width: 22)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(isPublic ? "Public Circle" : "Private Circle")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(AATheme.primaryText)
                            }
                        }
                    }
                    .tint(AATheme.amber)

                    // Contextual explanation
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(AATheme.secondaryText.opacity(0.6))
                            .padding(.top, 1)
                        Text(isPublic
                             ? "Anyone can find and join this circle. All users (free or premium) can read posts. Great for open communities."
                             : "Only people with the invite code can join. Best for close accountability groups.")
                            .font(.system(size: 13))
                            .foregroundColor(AATheme.secondaryText)
                            .lineSpacing(3)
                    }
                    .padding(12)
                    .background(AATheme.cardBackground)
                    .cornerRadius(AATheme.cornerRadiusSmall)
                    .animation(.easeInOut(duration: 0.2), value: isPublic)
                }
                .padding(.horizontal, 24)

                if let nameError = circleNameError {
                    Text(nameError)
                        .font(.system(size: 13))
                        .foregroundColor(AATheme.warning)
                        .padding(.horizontal, 24)
                }

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.system(size: 14))
                        .foregroundColor(AATheme.destructive)
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
                    .background(!isCircleNameValid ? AATheme.secondaryText.opacity(0.3) : AATheme.steel)
                    .cornerRadius(AATheme.cornerRadius)
                    .padding(.horizontal, 24)
                }
                .disabled(!isCircleNameValid || isCreating)

                Spacer()
            }
            .aaScreenBackground()
            .navigationTitle("Create a Circle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundColor(AATheme.secondaryText)
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
                    .foregroundColor(AATheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 24)

                TextField("INVITE CODE", text: $code)
                    .font(.system(size: 26, weight: .heavy, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .padding(20)
                    .background(AATheme.cardBackground)
                    .cornerRadius(AATheme.cornerRadius)
                    .padding(.horizontal, 24)
                    .focused($focused)
                    .onChange(of: code) { code = String(code.prefix(6).uppercased()) }

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.system(size: 14))
                        .foregroundColor(AATheme.destructive)
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
                    .background(code.count < 6 ? AATheme.secondaryText.opacity(0.3) : AATheme.steel)
                    .cornerRadius(AATheme.cornerRadius)
                    .padding(.horizontal, 24)
                }
                .disabled(code.count < 6 || isJoining)

                Spacer()
            }
            .aaScreenBackground()
            .navigationTitle("Join a Circle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundColor(AATheme.secondaryText)
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
                                .background(selectedType == type ? Color(type.color) : AATheme.cardBackground)
                                .foregroundColor(selectedType == type ? .white : AATheme.secondaryText)
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
                        .foregroundColor(AATheme.secondaryText)
                        .lineSpacing(2)
                }
                .padding(.horizontal, 20)
                .transition(.opacity.combined(with: .move(edge: .top)))
                .animation(.easeInOut(duration: 0.2), value: selectedType)

                ZStack(alignment: .topLeading) {
                    if content.isEmpty {
                        Text("Share with your brothers...")
                            .font(.system(size: 15))
                            .foregroundColor(AATheme.secondaryText.opacity(0.5))
                            .padding(.top, 12).padding(.leading, 5)
                    }
                    TextEditor(text: $content)
                        .font(.system(size: 15))
                        .foregroundColor(AATheme.primaryText)
                        .scrollContentBackground(.hidden)
                        .focused($focused)
                        .frame(minHeight: 120)
                }
                .padding(14)
                .background(AATheme.cardBackground)
                .cornerRadius(AATheme.cornerRadius)
                .padding(.horizontal, 20)

                Toggle(isOn: $isAnonymous) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Post anonymously")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AATheme.primaryText)
                        Text("Your name won't be shown")
                            .font(.system(size: 12))
                            .foregroundColor(AATheme.secondaryText)
                    }
                }
                .tint(AATheme.steel)
                .padding(.horizontal, 20)

                Spacer()
            }
            .padding(.top, 20)
            .aaScreenBackground()
            .navigationTitle("Share with Circle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundColor(AATheme.secondaryText)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") { Task { await submitPost() } }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(content.isEmpty ? AATheme.secondaryText : AATheme.steel)
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
                            .foregroundColor(AATheme.secondaryText.opacity(0.4))
                        Text("No Public Circles Yet")
                            .font(AATheme.headlineFont)
                            .foregroundColor(AATheme.primaryText)
                        Text("Be the first to create one — tap Create a Circle and set it to Public.")
                            .font(.system(size: 14))
                            .foregroundColor(AATheme.secondaryText)
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
                                    .foregroundColor(AATheme.amber)
                                Text("Public circles are open to all. Join to read posts, share, and find brotherhood.")
                                    .font(.system(size: 13))
                                    .foregroundColor(AATheme.secondaryText)
                                    .lineSpacing(3)
                            }
                            .padding(14)
                            .background(AATheme.amber.opacity(0.08))
                            .cornerRadius(AATheme.cornerRadiusSmall)
                            .padding(.horizontal, 20)

                            if !errorMessage.isEmpty {
                                Text(errorMessage)
                                    .font(.system(size: 13))
                                    .foregroundColor(AATheme.destructive)
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
            .aaScreenBackground()
            .navigationTitle("Public Circles")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AATheme.secondaryText)
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
                    .fill(AATheme.amber.opacity(0.15))
                    .frame(width: 48, height: 48)
                Text(String(circle.name.prefix(2)).uppercased())
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundColor(AATheme.amber)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(circle.name)
                    .font(AATheme.subheadlineFont)
                    .foregroundColor(AATheme.primaryText)
                HStack(spacing: 6) {
                    Label("\(circle.memberCount)/8", systemImage: "person.2.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AATheme.secondaryText)
                    if circle.memberCount >= 7 {
                        Text("Almost full")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(AATheme.warning)
                    }
                }
            }

            Spacer()

            Button(action: onJoinTap) {
                Group {
                    if isJoining {
                        ProgressView()
                            .tint(AATheme.amber)
                    } else {
                        Text("Join")
                            .font(.system(size: 14, weight: .bold))
                    }
                }
                .foregroundColor(AATheme.amber)
                .padding(.horizontal, 18)
                .padding(.vertical, 8)
                .background(AATheme.amber.opacity(0.12))
                .cornerRadius(AATheme.cornerRadiusSmall)
            }
            .disabled(isJoining || circle.memberCount >= 8)
        }
        .padding(14)
        .background(AATheme.cardBackground)
        .cornerRadius(AATheme.cornerRadius)
        .shadow(color: AATheme.cardShadow, radius: AATheme.cardShadowRadius, x: 0, y: 2)
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
