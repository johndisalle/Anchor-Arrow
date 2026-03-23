// CirclesView.swift
// Iron Sharpeners – private accountability circles

import SwiftUI
import FirebaseAuth

// MARK: - CirclesView
struct CirclesView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var storeKitManager: StoreKitManager
    @State private var circles: [Circle] = []
    @State private var showCreateCircle = false
    @State private var showJoinCircle = false
    @State private var showPremiumUpsell = false
    @State private var isLoading = false
    @State private var selectedCircle: Circle?

    private let firestoreService = FirestoreService.shared

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading circles...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if circles.isEmpty {
                    emptyState
                } else {
                    circlesList
                }
            }
            .background(Color("BackgroundPrimary").ignoresSafeArea())
            .navigationTitle("Iron Sharpeners")
            .navigationBarTitleDisplayMode(.large)
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
                Text("Start or join a private circle of 3–8 brothers to share wins, struggles, and accountability.")
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
                        Text("Free plan: read-only. Upgrade to post and comment.")
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
                    CircleCard(circle: circle) {
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
    }
}

// MARK: - CircleCard
struct CircleCard: View {
    let circle: Circle
    let onTap: () -> Void
    @State private var showCopiedToast = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
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
                    Label("\(circle.memberCount) brothers", systemImage: "person.2.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color("TextSecondary"))
                }
                Spacer()
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
    @State private var showPremiumUpsell = false
    @State private var showMemberList = false
    @State private var memberNames: [String: String] = [:]
    @State private var showLeaveAlert = false
    @State private var selectedPostForComments: CirclePost?
    @State private var codeCopied = false

    private let service = FirestoreService.shared
    private let dailyPrompt = PromptLibrary.circlePromptForToday()

    var canPost: Bool { userStore.isPremium }

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            dailyPromptBanner
                                .padding(.horizontal, 20)
                                .padding(.top, 16)
                                .padding(.bottom, 8)

                            if posts.isEmpty {
                                emptyPostsState
                            } else {
                                ForEach(posts) { post in
                                    CirclePostRow(
                                        post: post,
                                        onReact: { emoji in
                                            Task { await react(to: post, emoji: emoji) }
                                        },
                                        onComment: {
                                            if canPost {
                                                selectedPostForComments = post
                                            } else {
                                                showPremiumUpsell = true
                                            }
                                        }
                                    )
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 6)
                                }
                            }
                            Spacer(minLength: 120)
                        }
                    }
                    .refreshable { await loadPosts() }
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
                    Button {
                        UIPasteboard.general.string = circle.inviteCode
                        codeCopied = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { codeCopied = false }
                    } label: {
                        Image(systemName: codeCopied ? "checkmark" : "link")
                            .font(.system(size: 16))
                            .foregroundColor(codeCopied ? Color("BrandArrow") : Color("BrandAnchor"))
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
                        Button(role: .destructive) { showLeaveAlert = true } label: {
                            Label("Leave Circle", systemImage: "arrow.right.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16))
                            .foregroundColor(Color("TextSecondary"))
                    }
                }
            }
            .sheet(isPresented: $showNewPost) {
                NewCirclePostView(circleId: circle.id ?? "") { newPost in
                    posts.insert(newPost, at: 0)
                }
            }
            .sheet(isPresented: $showPremiumUpsell) {
                PremiumUpsellView(reason: "Post and comment in Iron Sharpeners circles")
            }
            .sheet(isPresented: $showMemberList) {
                MemberListSheet(circle: circle, memberNames: memberNames)
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

    // MARK: - Actions
    private func loadData() async {
        guard let circleId = circle.id else { return }
        isLoading = true
        async let fetchedPosts = service.fetchCirclePosts(circleId: circleId)
        async let fetchedNames = service.fetchMemberNames(memberIds: circle.memberIds)
        posts = (try? await fetchedPosts) ?? []
        memberNames = (try? await fetchedNames) ?? [:]
        isLoading = false
    }

    private func loadPosts() async {
        guard let circleId = circle.id else { return }
        posts = (try? await service.fetchCirclePosts(circleId: circleId)) ?? []
    }

    private func react(to post: CirclePost, emoji: String) async {
        guard let circleId = circle.id, let postId = post.id else { return }
        try? await service.reactToPost(circleId: circleId, postId: postId, emoji: emoji)
        // Optimistic local update
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            let current = posts[index].reactions[emoji] ?? 0
            posts[index].reactions[emoji] = current + 1
        }
    }

    private func leaveCircle() async {
        guard let circleId = circle.id,
              let uid = Auth.auth().currentUser?.uid else { return }
        do {
            try await service.leaveCircle(circleId: circleId, uid: uid)
            onLeave()
            dismiss()
        } catch { }
    }
}

// MARK: - MemberListSheet
struct MemberListSheet: View {
    let circle: Circle
    let memberNames: [String: String]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(circle.memberIds, id: \.self) { uid in
                    let name = memberNames[uid] ?? "A Brother"
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(Color("BrandAnchor").opacity(0.15))
                                .frame(width: 40, height: 40)
                            Text(String(name.prefix(1)).uppercased())
                                .font(.system(size: 16, weight: .heavy))
                                .foregroundColor(Color("BrandAnchor"))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(name)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color("TextPrimary"))
                            if uid == circle.creatorId {
                                Text("Circle Leader")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color("BrandGold"))
                            }
                        }
                        Spacer()
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

// MARK: - CirclePostRow
struct CirclePostRow: View {
    let post: CirclePost
    let onReact: (String) -> Void
    let onComment: () -> Void

    private let reactionEmojis = ["🔥", "🙏", "🙌", "💪"]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Type badge + time
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
    @FocusState private var focused: Bool

    private let service = FirestoreService.shared

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
                                CommentRow(comment: comment)
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
        } catch { }
        isPosting = false
    }
}

// MARK: - CommentRow
struct CommentRow: View {
    let comment: CircleComment

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                Circle()
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
        }
        .padding(.vertical, 6)
    }
}

// MARK: - CreateCircleView
struct CreateCircleView: View {
    let onCreate: (Circle) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var circleName = ""
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
                    .background(circleName.isEmpty ? Color("TextSecondary").opacity(0.3) : Color("BrandAnchor"))
                    .cornerRadius(14)
                    .padding(.horizontal, 24)
                }
                .disabled(circleName.isEmpty || isCreating)

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

    private func createCircle() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isCreating = true
        let newCircle = Circle.new(name: circleName, creatorId: uid)
        do {
            // Fix: fetch back from Firestore so @DocumentID is populated
            let id = try await FirestoreService.shared.createCircle(circle: newCircle)
            let saved = try await FirestoreService.shared.fetchCircle(circleId: id)
            onCreate(saved)
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
                    .onChange(of: code) { code = String($0.prefix(6).uppercased()) }

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
    let onPost: (CirclePost) -> Void

    @EnvironmentObject var userStore: UserStore
    @Environment(\.dismiss) var dismiss
    @State private var content = ""
    @State private var selectedType: PostType = .general
    @State private var isAnonymous = false
    @State private var isPosting = false
    @FocusState private var focused: Bool

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
        } catch { }
        isPosting = false
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
