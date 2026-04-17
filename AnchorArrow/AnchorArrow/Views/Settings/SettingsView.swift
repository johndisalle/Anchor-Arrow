// SettingsView.swift
// Profile, preferences, notifications, subscription management

import SwiftUI
import StoreKit
import FirebaseAuth

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var storeKitManager: StoreKitManager
    @EnvironmentObject var notificationManager: NotificationManager

    @State private var showSignOutConfirm = false
    @State private var isEditingName = false
    @State private var editedName = ""
    @State private var showDeleteConfirm = false
    @State private var showPremiumUpsell = false
    @State private var morningTime = Date()
    @State private var eveningTime = Date()
    @State private var showExportSheet = false
    @State private var exportContent = ""
    @State private var isDeleting = false
    @State private var showReauthAlert = false
    @State private var reauthPassword = ""
    @State private var deleteError: String?

    var body: some View {
        NavigationStack {
            List {

                // Profile Section
                Section {
                    profileHeader
                } header: {
                    Text("Profile")
                }

                // Premium Section
                Section {
                    premiumRow
                    redeemOfferCodeRow
                } header: {
                    Text("Subscription")
                }

                // Notifications Section
                Section {
                    notificationRows
                } header: {
                    Text("Reminders")
                }

                // Appearance Section
                Section {
                    themePicker
                } header: {
                    Text("Appearance")
                }

                // Journey Section
                if userStore.appUser?.journeyActive == true {
                    Section {
                        journeyRow
                    } header: {
                        Text("\(userStore.currentJourneySeries.displayName) Journey")
                    }
                }

                // Data Section
                Section {
                    Button {
                        exportData()
                        showExportSheet = true
                    } label: {
                        Label("Export Journal Data", systemImage: "square.and.arrow.up")
                            .foregroundColor(AATheme.primaryText)
                    }
                } header: {
                    Text("Data")
                }

                // Blocked Users Section
                if !(userStore.appUser?.blockedUserIds.isEmpty ?? true) {
                    Section {
                        NavigationLink {
                            BlockedUsersView()
                        } label: {
                            HStack {
                                Label("Blocked Users", systemImage: "hand.raised")
                                    .foregroundColor(AATheme.primaryText)
                                Spacer()
                                Text("\(userStore.appUser?.blockedUserIds.count ?? 0)")
                                    .font(.system(size: 14))
                                    .foregroundColor(AATheme.secondaryText)
                            }
                        }
                    } header: {
                        Text("Privacy")
                    }
                }

                // Admin Panel (only visible to admins)
                if userStore.isAdmin {
                    Section {
                        NavigationLink {
                            AdminView()
                                .environmentObject(userStore)
                        } label: {
                            Label("Admin Panel", systemImage: "shield.lefthalf.filled")
                        }
                    } header: {
                        Text("Administration")
                    }
                }

                // Account Section
                Section {
                    Button(role: .destructive) {
                        showSignOutConfirm = true
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                    .disabled(isDeleting)

                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        HStack {
                            Label("Delete Account", systemImage: "person.crop.circle.badge.minus")
                            if isDeleting {
                                Spacer()
                                ProgressView()
                                    .tint(AATheme.destructive)
                            }
                        }
                    }
                    .disabled(isDeleting)
                } header: {
                    Text("Account")
                }
                
                // Support Section
                Section {
                    Button {
                        if let url = URL(string: "mailto:support@ellasid.com?subject=Report%20Inappropriate%20Content") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Label("Report Inappropriate Content", systemImage: "exclamationmark.bubble")
                            .foregroundColor(AATheme.primaryText)
                    }

                    Button {
                        if let url = URL(string: "mailto:support@ellasid.com") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Label("Contact Us", systemImage: "envelope")
                            .foregroundColor(AATheme.primaryText)
                    }
                } header: {
                    Text("Support")
                }
                
                // Legal Section
                Section {
                    if let url = URL(string: "https://johndisalle.github.io/Anchor-Arrow/terms-of-use.html") {
                        Link(destination: url) {
                            Label("Terms of Use", systemImage: "doc.text")
                                .foregroundColor(AATheme.primaryText)
                        }
                    }
                    if let url = URL(string: "https://johndisalle.github.io/Anchor-Arrow/privacy-policy.html") {
                        Link(destination: url) {
                            Label("Privacy Policy", systemImage: "hand.raised")
                                .foregroundColor(AATheme.primaryText)
                        }
                    }
                    Button {
                        ReviewManager.requestReviewIfAppropriate()
                    } label: {
                        Label("Leave a Review", systemImage: "star.fill")
                            .foregroundColor(AATheme.primaryText)
                    }
                } header: {
                    Text("Legal")
                }

                // About Section
                Section {
                    Button {
                        ReviewManager.requestReviewIfAppropriate()
                    } label: {
                        Label("Rate Anchor & Arrow", systemImage: "star.fill")
                    }
                    LabeledContent("Version", value: appVersionString)
                    LabeledContent("Built on", value: "1 Corinthians 16:13-14")
                } header: {
                    Text("About")
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .aaScreenBackground()
            .navigationTitle("Profile & Settings")
            .navigationBarTitleDisplayMode(.large)
            .confirmationDialog("Sign Out?", isPresented: $showSignOutConfirm, titleVisibility: .visible) {
                Button("Sign Out", role: .destructive) {
                    userStore.clearData()
                    userStore.hasCompletedOnboarding = false
                    UserDefaults.standard.set(false, forKey: "onboardingComplete")
                    try? authManager.signOut()
                }
                Button("Cancel", role: .cancel) {}
            }
            .confirmationDialog(
                "Delete your account?",
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete Permanently", role: .destructive) {
                    Task {
                        isDeleting = true
                        deleteError = nil
                        do {
                            try await authManager.deleteAccount()
                        } catch {
                            let nsError = error as NSError
                            if nsError.code == AuthErrorCode.requiresRecentLogin.rawValue {
                                showReauthAlert = true
                            } else {
                                deleteError = error.localizedDescription
                            }
                        }
                        isDeleting = false
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete your account and all data. This cannot be undone.")
            }
            .alert("Re-enter Password", isPresented: $showReauthAlert) {
                SecureField("Password", text: $reauthPassword)
                Button("Delete Account", role: .destructive) {
                    Task {
                        isDeleting = true
                        do {
                            try await authManager.reauthenticateAndDelete(password: reauthPassword)
                        } catch {
                            deleteError = error.localizedDescription
                        }
                        isDeleting = false
                        reauthPassword = ""
                    }
                }
                Button("Cancel", role: .cancel) { reauthPassword = "" }
            } message: {
                Text("For security, please re-enter your password to delete your account.")
            }
            .sheet(isPresented: $showPremiumUpsell) {
                PremiumUpsellView(reason: nil)
            }
            .sheet(isPresented: $showExportSheet) {
                ShareSheet(content: exportContent)
            }
        }
    }

    // MARK: - Profile Header
    private var profileHeader: some View {
        HStack(spacing: 16) {
            ZStack {
                SwiftUI.Circle()
                    .fill(
                        LinearGradient(
                            colors: [AATheme.steel, AATheme.amber],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                Text(String(userStore.displayName.prefix(2)).uppercased())
                    .font(.system(size: 22, weight: .heavy, design: .serif))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                if isEditingName {
                    HStack {
                        TextField("Display name", text: $editedName)
                            .font(AATheme.subheadlineFont)
                            .textFieldStyle(.roundedBorder)
                        Button("Save") {
                            let trimmed = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmed.isEmpty else { return }
                            Task {
                                guard let uid = Auth.auth().currentUser?.uid else { return }
                                try? await FirestoreService.shared.updateUser(uid: uid, fields: ["displayName": trimmed])
                                userStore.appUser?.displayName = trimmed
                                isEditingName = false
                            }
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AATheme.steel)
                    }
                } else {
                    HStack {
                        Text(userStore.displayName)
                            .font(AATheme.subheadlineFont)
                            .foregroundColor(AATheme.primaryText)
                        Button {
                            editedName = userStore.displayName
                            isEditingName = true
                        } label: {
                            Image(systemName: "pencil")
                                .font(.system(size: 13))
                                .foregroundColor(AATheme.steel)
                        }
                    }
                }
                Text(authManager.userEmail)
                    .font(.system(size: 13))
                    .foregroundColor(AATheme.secondaryText)
                Text("Member since \(userStore.appUser?.memberSince ?? "")")
                    .font(.system(size: 12))
                    .foregroundColor(AATheme.secondaryText)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Premium Row
    // MARK: - Redeem Offer Code
    private var redeemOfferCodeRow: some View {
        Button {
            Task {
                guard let scene = UIApplication.shared.connectedScenes
                    .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
                    print("[Settings] No active window scene available for offer code redemption")
                    return
                }
                do {
                    try await AppStore.presentOfferCodeRedeemSheet(in: scene)
                } catch {
                    print("[Settings] Offer code redemption sheet failed: \(error)")
                }
            }
        } label: {
            HStack {
                AAIcon("gift.fill", size: 17, weight: .semibold, color: AATheme.amber)
                Text("Redeem Offer Code")
                    .foregroundColor(AATheme.primaryText)
                Spacer()
                AAIcon("chevron.right", size: 13, weight: .semibold, color: AATheme.secondaryText)
            }
        }
    }

    // MARK: - App Version String
    /// Reads marketing version + build number from Info.plist so the About
    /// row always reflects whatever MARKETING_VERSION / CURRENT_PROJECT_VERSION
    /// is set in the project. Returns "1.2 (14)" format.
    private var appVersionString: String {
        let info = Bundle.main.infoDictionary
        let marketing = info?["CFBundleShortVersionString"] as? String ?? "—"
        let build = info?["CFBundleVersion"] as? String ?? ""
        return build.isEmpty ? marketing : "\(marketing) (\(build))"
    }

    private var premiumRow: some View {
        Group {
            if userStore.isPremium {
                HStack {
                    Label("Premium Active", systemImage: "crown.fill")
                        .foregroundColor(AATheme.warmGold)
                    Spacer()
                    if let expiry = userStore.appUser?.premiumExpiry {
                        Text("Renews \(expiry.displayShort)")
                            .font(.system(size: 12))
                            .foregroundColor(AATheme.secondaryText)
                    }
                }
                Button("Manage Subscription") {
                    Task {
                        if let scene = UIApplication.shared.connectedScenes
                            .compactMap({ $0 as? UIWindowScene }).first {
                            try? await AppStore.showManageSubscriptions(in: scene)
                        }
                    }
                }
                .foregroundColor(AATheme.steel)
            } else {
                Button {
                    showPremiumUpsell = true
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(AATheme.warmGold)
                                Text("Upgrade to Premium")
                                    .font(.system(size: 16, weight: .bold, design: .serif))
                                    .foregroundColor(AATheme.primaryText)
                            }
                            Text("Circles • Drift Insights • Grace Day • Journeys")
                                .font(.system(size: 12))
                                .foregroundColor(AATheme.secondaryText)
                        }
                        Spacer()
                        Text("$3.99/mo")
                            .font(.system(size: 14, weight: .bold, design: .serif))
                            .foregroundColor(AATheme.warmGold)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Notification Rows
    private var notificationRows: some View {
        Group {
            Toggle(isOn: .init(
                get: { userStore.appUser?.notificationsEnabled ?? true },
                set: { enabled in
                    Task {
                        if enabled {
                            await notificationManager.requestPermission()
                            await notificationManager.scheduleReminders(
                                morningHour: userStore.appUser?.morningReminderHour ?? 7,
                                eveningHour: userStore.appUser?.eveningReminderHour ?? 20
                            )
                        } else {
                            notificationManager.cancelAll()
                        }
                        if let uid = Auth.auth().currentUser?.uid {
                            try? await FirestoreService.shared.updateUser(uid: uid, fields: ["notificationsEnabled": enabled])
                        }
                    }
                }
            )) {
                Label("Daily Reminders", systemImage: "bell.fill")
            }
            .tint(AATheme.steel)

            if userStore.appUser?.notificationsEnabled ?? true {
                DatePicker(
                    "Morning Anchor",
                    selection: $morningTime,
                    displayedComponents: .hourAndMinute
                )
                .onChange(of: morningTime) { _, time in
                    let hour = Calendar.current.component(.hour, from: time)
                    Task {
                        await notificationManager.scheduleReminders(morningHour: hour, eveningHour: userStore.appUser?.eveningReminderHour ?? 20)
                        if let uid = Auth.auth().currentUser?.uid {
                            try? await FirestoreService.shared.updateUser(uid: uid, fields: ["morningReminderHour": hour])
                        }
                    }
                }

                DatePicker(
                    "Evening Arrow",
                    selection: $eveningTime,
                    displayedComponents: .hourAndMinute
                )
                .onChange(of: eveningTime) { _, time in
                    let hour = Calendar.current.component(.hour, from: time)
                    Task {
                        await notificationManager.scheduleReminders(morningHour: userStore.appUser?.morningReminderHour ?? 7, eveningHour: hour)
                        if let uid = Auth.auth().currentUser?.uid {
                            try? await FirestoreService.shared.updateUser(uid: uid, fields: ["eveningReminderHour": hour])
                        }
                    }
                }
            }
        }
        .onAppear { setupTimePickers() }
    }

    // MARK: - Theme Picker
    private var themePicker: some View {
        Picker("App Theme", selection: .init(
            get: { AppTheme(rawValue: userStore.savedTheme) ?? .system },
            set: { theme in
                userStore.savedTheme = theme.rawValue
                userStore.appUser?.theme = theme
                Task {
                    if let uid = Auth.auth().currentUser?.uid {
                        try? await FirestoreService.shared.updateUser(uid: uid, fields: ["theme": theme.rawValue])
                    }
                }
            }
        )) {
            ForEach(AppTheme.allCases, id: \.self) { theme in
                Text(theme.displayName).tag(theme)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Journey Row
    private var journeyRow: some View {
        LabeledContent(
            "Current Day",
            value: "Day \(userStore.appUser?.journeyDay ?? 0) of \(kJourneyDays)"
        )
    }

    // MARK: - Helpers
    private func setupTimePickers() {
        var morningComponents = DateComponents()
        morningComponents.hour = userStore.appUser?.morningReminderHour ?? 7
        morningComponents.minute = 0
        morningTime = Calendar.current.date(from: morningComponents) ?? Date()

        var eveningComponents = DateComponents()
        eveningComponents.hour = userStore.appUser?.eveningReminderHour ?? 20
        eveningComponents.minute = 0
        eveningTime = Calendar.current.date(from: eveningComponents) ?? Date()
    }

    private func exportData() {
        var lines = ["Anchor & Arrow — Journal Export", "Generated: \(Date().displayShort)", ""]
        for entry in userStore.recentEntries.reversed() {
            lines.append("=== \(entry.dateString) ===")
            if entry.anchorCompleted {
                lines.append("ANCHOR: \(entry.anchorReflection)")
                if !entry.anchorTags.isEmpty {
                    lines.append("Drift areas: \(entry.anchorTags.map(\.displayName).joined(separator: ", "))")
                }
            }
            if entry.arrowCompleted {
                lines.append("ARROW (\(entry.arrowRole.displayName)): \(entry.arrowReflection)")
            }
            lines.append("")
        }
        exportContent = lines.joined(separator: "\n")
    }
}

// MARK: - BlockedUsersView
struct BlockedUsersView: View {
    @EnvironmentObject var userStore: UserStore
    @State private var blockedNames: [String: String] = [:]
    @State private var isLoading = true
    @State private var blockedIds: [String] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 1) {
                ForEach(blockedIds, id: \.self) { uid in
                    BlockedUserRow(
                        uid: uid,
                        name: blockedNames[uid],
                        onUnblock: { unblock(uid) }
                    )
                }
            }
        }
        .overlay {
            if isLoading {
                ProgressView()
            } else if blockedIds.isEmpty {
                VStack(spacing: 16) {
                    AAIcon("hand.raised.slash", size: 44, weight: .semibold, color: AATheme.secondaryText.opacity(0.4))
                    Text("No blocked users")
                        .font(.system(size: 15))
                        .foregroundColor(AATheme.secondaryText)
                }
            }
        }
        .aaScreenBackground()
        .navigationTitle("Blocked Users")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadNames() }
    }

    private func unblock(_ uid: String) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        Task {
            userStore.appUser?.blockedUserIds.removeAll { $0 == uid }
            blockedIds.removeAll { $0 == uid }
            let updated = userStore.appUser?.blockedUserIds ?? []
            try? await FirestoreService.shared.updateUser(uid: currentUid, fields: [
                "blockedUserIds": updated
            ])
        }
    }

    private func loadNames() async {
        let ids = userStore.appUser?.blockedUserIds ?? []
        var seen = Set<String>()
        blockedIds = ids.filter { seen.insert($0).inserted }
        guard !ids.isEmpty else { isLoading = false; return }
        blockedNames = (try? await FirestoreService.shared.fetchUserNames(uids: ids)) ?? [:]
        isLoading = false
    }
}

// MARK: - BlockedUserRow
struct BlockedUserRow: View {
    let uid: String
    let name: String?
    let onUnblock: () -> Void

    var body: some View {
        HStack {
            ZStack {
                SwiftUI.Circle()
                    .fill(AATheme.steel.opacity(0.1))
                    .frame(width: 36, height: 36)
                Text(String((name ?? "?").prefix(1)).uppercased())
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundColor(AATheme.steel)
            }
            Text(name ?? "User")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AATheme.primaryText)
            Spacer()
            Button("Unblock", action: onUnblock)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AATheme.steel)
        }
        .padding(16)
        .background(AATheme.cardBackground)
    }
}

// MARK: - ShareSheet (UIActivityViewController wrapper)
struct ShareSheet: UIViewControllerRepresentable {
    let content: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: [content],
            applicationActivities: nil
        )
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
