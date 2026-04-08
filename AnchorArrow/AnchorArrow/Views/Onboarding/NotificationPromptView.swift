// NotificationPromptView.swift
// Post-signup modal prompting users to enable push notifications

import SwiftUI

struct NotificationPromptView: View {
    @EnvironmentObject var userStore: UserStore
    @StateObject private var notificationManager = NotificationManager()
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Bell icon
            ZStack {
                SwiftUI.Circle()
                    .fill(AATheme.steel.opacity(0.12))
                    .frame(width: 100, height: 100)

                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundColor(AATheme.steel)
            }
            .padding(.bottom, 28)

            // Title
            Text("Stay Anchored")
                .font(AATheme.headlineFont)
                .foregroundColor(AATheme.primaryText)
                .padding(.bottom, AATheme.paddingSmall)

            // Description
            Text("Get daily reminders for your Morning Anchor and Evening Arrow so you never miss a day.")
                .font(.system(size: 16))
                .foregroundColor(AATheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)
                .padding(.bottom, AATheme.paddingSmall)

            // Bullet points
            VStack(alignment: .leading, spacing: 12) {
                NotificationBullet(icon: "sunrise.fill", text: "Morning Anchor reminder at 7 AM")
                NotificationBullet(icon: "moon.stars.fill", text: "Evening Arrow reminder at 8 PM")
                NotificationBullet(icon: "flame.fill", text: "Streak warnings so you don't lose progress")
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 20)

            Spacer()

            // Enable button
            Button {
                Task {
                    await notificationManager.requestPermission()
                    if notificationManager.permissionGranted {
                        await notificationManager.scheduleReminders(morningHour: 7, eveningHour: 20)
                    }
                    isPresented = false
                }
            } label: {
                Text("Enable Notifications")
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
            }
            .buttonStyle(AAPrimaryButtonStyle())
            .padding(.horizontal, AATheme.paddingLarge)

            // Skip button
            Button {
                isPresented = false
            } label: {
                Text("Maybe Later")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AATheme.secondaryText)
            }
            .padding(.top, 14)
            .padding(.bottom, 40)
        }
        .aaScreenBackground()
    }
}

// MARK: - NotificationCheckModifier
/// Re-checks notification permission on each app foreground.
/// If the user granted permission via System Settings after dismissing the prompt,
/// this ensures reminders get scheduled automatically.
struct NotificationCheckModifier: ViewModifier {
    @StateObject private var notificationManager = NotificationManager()
    @Environment(\.scenePhase) private var scenePhase

    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    Task {
                        await notificationManager.checkPermission()
                        if notificationManager.permissionGranted {
                            await notificationManager.scheduleReminders(morningHour: 7, eveningHour: 20)
                        }
                    }
                }
            }
    }
}

extension View {
    func checkNotificationPermission() -> some View {
        modifier(NotificationCheckModifier())
    }
}

// MARK: - Bullet Row
private struct NotificationBullet: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AATheme.steel)
                .frame(width: 24)

            Text(text)
                .font(.system(size: 15))
                .foregroundColor(AATheme.primaryText)
        }
    }
}
