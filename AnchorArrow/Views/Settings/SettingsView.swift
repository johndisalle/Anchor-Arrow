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
    @State private var showDeleteConfirm = false
    @State private var showPremiumUpsell = false
    @State private var morningTime = Date()
    @State private var eveningTime = Date()
    @State private var showExportSheet = false
    @State private var exportContent = ""
    @State private var isDeleting = false

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
                            .foregroundColor(Color("TextPrimary"))
                    }
                } header: {
                    Text("Data")
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
                                    .tint(Color("BrandDanger"))
                            }
                        }
                    }
                    .disabled(isDeleting)
                } header: {
                    Text("Account")
                }

                // Legal Section
                Section {
                    Link(destination: URL(string: "https://johndisalle.github.io/Anchor-Arrow/terms-of-use.html")!) {
                        Label("Terms of Use", systemImage: "doc.text")
                            .foregroundColor(Color("TextPrimary"))
                    }
                    Link(destination: URL(string: "https://johndisalle.github.io/Anchor-Arrow/privacy-policy.html")!) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                            .foregroundColor(Color("TextPrimary"))
                    }
                } header: {
                    Text("Legal")
                }

                // About Section
                Section {
                    LabeledContent("Version", value: "1.0.0 (MVP)")
                    LabeledContent("Built on", value: "1 Corinthians 16:13-14")
                } header: {
                    Text("About")
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color("BackgroundPrimary").ignoresSafeArea())
            .navigationTitle("Profile & Settings")
            .navigationBarTitleDisplayMode(.large)
            .confirmationDialog("Sign Out?", isPresented: $showSignOutConfirm, titleVisibility: .visible) {
                Button("Sign Out", role: .destructive) {
                    try? authManager.signOut()
                    userStore.hasCompletedOnboarding = false
                    UserDefaults.standard.set(false, forKey: "onboardingComplete")
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
                        try? await authManager.deleteAccount()
                        isDeleting = false
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete your account and all data. This cannot be undone.")
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
                            colors: [Color("BrandAnchor"), Color("BrandArrow")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                Text(String(userStore.displayName.prefix(2)).uppercased())
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(userStore.displayName)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
                Text(authManager.userEmail)
                    .font(.system(size: 13))
                    .foregroundColor(Color("TextSecondary"))
                Text("Member since \(userStore.appUser?.memberSince ?? "")")
                    .font(.system(size: 12))
                    .foregroundColor(Color("TextSecondary"))
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Premium Row
    private var premiumRow: some View {
        Group {
            if userStore.isPremium {
                HStack {
                    Label("Premium Active", systemImage: "crown.fill")
                        .foregroundColor(Color("BrandGold"))
                    Spacer()
                    if let expiry = userStore.appUser?.premiumExpiry {
                        Text("Renews \(expiry.displayShort)")
                            .font(.system(size: 12))
                            .foregroundColor(Color("TextSecondary"))
                    }
                }
                Button("Manage Subscription") {
                    if let url = URL(string: "itms-apps://apps.apple.com/account/subscriptions") {
                        UIApplication.shared.open(url)
                    }
                }
                .foregroundColor(Color("BrandAnchor"))
            } else {
                Button {
                    showPremiumUpsell = true
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(Color("BrandGold"))
                                Text("Upgrade to Premium")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color("TextPrimary"))
                            }
                            Text("Circles • Drift Insights • Grace Day • Journeys")
                                .font(.system(size: 12))
                                .foregroundColor(Color("TextSecondary"))
                        }
                        Spacer()
                        Text("$6.99/mo")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color("BrandGold"))
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
            .tint(Color("BrandAnchor"))

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
                // Write to @AppStorage for instant local switch
                userStore.savedTheme = theme.rawValue
                userStore.appUser?.theme = theme
                // Persist to Firestore for cross-device sync
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
            value: "Day \(userStore.appUser?.journeyDay ?? 0) of 30"
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
