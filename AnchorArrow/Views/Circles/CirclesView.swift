// CirclesView.swift
// Iron Sharpeners – private accountability circles

import SwiftUI
import FirebaseAuth

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
                CircleDetailView(circle: circle)
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
                Button {
                    showCreateCircle = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Create a Circle")
                            .font(.system(size: 17, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color("BrandAnchor"))
                    .cornerRadius(14)
                }

                Button {
                    showJoinCircle = true
                } label: {
                    HStack {
                        Image(systemName: "link")
                        Text("Join with Invite Code")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(Color("BrandAnchor"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
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
                // Free tier notice
                if !userStore.isPremium && circles.count >= 1 {
                    HStack(spacing: 10) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(Color("BrandGold"))
                        Text("Free plan: view-only in circles. Upgrade to post and comment.")
                            .font(.system(size: 13))
                            .foregroundColor(Color("TextSecondary"))
                        Spacer()
                        Button("Upgrade") {
                            showPremiumUpsell = true
                        }
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

    // MARK: - Load
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

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Avatar
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
                    HStack(spacing: 12) {
                        Label("\(circle.memberCount) brothers", systemImage: "person.2.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color("TextSecondary"))
                        Text("Code: \(circle.inviteCode)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color("BrandAnchor"))
                    }
                }

                Spacer()

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

// MARK: - Create Circle View
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
            let id = try await FirestoreService.shared.createCircle(circle: newCircle)
            var created = newCircle
            // Note: @DocumentID won't be set locally; handle in production with fetch
            onCreate(created)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        isCreating = false
    }
}

// MARK: - Join Circle View
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

// MARK: - Circle Detail View
struct CircleDetailView: View {
    let circle: Circle
    @EnvironmentObject var userStore: UserStore
    @Environment(\.dismiss) var dismiss
    @State private var posts: [CirclePost] = []
    @State private var isLoading = false
    @State private var showNewPost = false
    @State private var showPremiumUpsell = false

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                } else if posts.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 44))
                            .foregroundColor(Color("TextSecondary").opacity(0.4))
                        Text("No posts yet. Be the first to share.")
                            .font(.system(size: 15))
                            .foregroundColor(Color("TextSecondary"))
                        if !userStore.isPremium {
                            Text("Premium required to post")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color("BrandGold"))
                        }
                        Spacer()
                    }
                } else {
                    List(posts) { post in
                        CirclePostRow(post: post, canReact: true) {
                            Task {
                                try? await FirestoreService.shared.reactToPost(
                                    circleId: circle.id ?? "",
                                    postId: post.id ?? "",
                                    emoji: "🔥"
                                )
                            }
                        } onBlockUser: {
                            Task { await blockUser(post.authorId) }
                        } onHidePost: {
                            posts.removeAll { $0.id == post.id }
                        }
                        .listRowBackground(Color("CardBackground"))
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                    }
                    .listStyle(.plain)
                }
            }
            .background(Color("BackgroundPrimary").ignoresSafeArea())
            .navigationTitle(circle.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }.foregroundColor(Color("BrandAnchor"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if userStore.isPremium { showNewPost = true }
                        else { showPremiumUpsell = true }
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 17))
                            .foregroundColor(Color("BrandAnchor"))
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
        }
        .task { await loadPosts() }
    }

    private func loadPosts() async {
        guard let circleId = circle.id else { return }
        isLoading = true
        posts = (try? await FirestoreService.shared.fetchCirclePosts(circleId: circleId)) ?? []
        isLoading = false
    }

    private func blockUser(_ userId: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            try await FirestoreService.shared.updateUser(uid: uid, fields: [
                "blockedUserIds": [userId] + (userStore.appUser?.blockedUserIds ?? [])
            ])
            userStore.appUser?.blockedUserIds.append(userId)
            posts.removeAll { $0.authorId == userId }
        } catch {
            userStore.errorMessage = "Couldn't block user. Try again."
        }
    }
}

// MARK: - CirclePostRow
struct CirclePostRow: View {
    let post: CirclePost
    let canReact: Bool
    let onReact: () -> Void
    var isLeader: Bool = false
    var canModerate: Bool = false
    var onReport: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    var onBlockUser: (() -> Void)? = nil
    var onHidePost: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: post.type.icon)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(post.type.color))
                    Text(post.type.displayName)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(post.type.color))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(post.type.color).opacity(0.1))
                .cornerRadius(8)

                Spacer()

                Text(post.timestamp.timeAgo)
                    .font(.system(size: 11))
                    .foregroundColor(Color("TextSecondary"))

                if isLeader || canModerate || onReport != nil || onBlockUser != nil {
                    Menu {
                        if isLeader || canModerate, let onDelete {
                            Button(role: .destructive) { onDelete() } label: {
                                Label("Delete Post", systemImage: "trash")
                            }
                        }
                        if let onHidePost {
                            Button { onHidePost() } label: {
                                Label("Hide Post", systemImage: "eye.slash")
                            }
                        }
                        if let onBlockUser {
                            Button(role: .destructive) { onBlockUser() } label: {
                                Label("Block User", systemImage: "hand.raised")
                            }
                        }
                        if let onReport {
                            Button { onReport() } label: {
                                Label("Report Post", systemImage: "flag")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16))
                            .foregroundColor(Color("TextSecondary"))
                            .padding(6)
                    }
                }
            }

            Text(post.isAnonymous ? "A brother shared:" : post.authorName)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color("TextSecondary"))

            Text(post.content)
                .font(.system(size: 15))
                .foregroundColor(Color("TextPrimary"))
                .lineSpacing(4)

            if canReact {
                Button(action: onReact) {
                    HStack(spacing: 4) {
                        Text("🔥")
                        Text("\(post.reactions["🔥"] ?? 0)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color("TextSecondary"))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
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
                // Type selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(PostType.allCases, id: \.self) { type in
                            Button {
                                selectedType = type
                            } label: {
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

                // Content field
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

                // Anonymous toggle
                Toggle(isOn: $isAnonymous) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Post anonymously")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color("TextPrimary"))
                        Text("Your name won't be shown, only your circle knows it's you")
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
                    Button("Post") {
                        Task { await submitPost() }
                    }
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
