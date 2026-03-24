// WelcomeGuideView.swift
// Post-signup "what to do first" guide shown once after account creation

import SwiftUI

struct WelcomeGuideView: View {
    @Binding var isPresented: Bool
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Header
            VStack(spacing: 14) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 52, weight: .medium))
                    .foregroundColor(Color("BrandAnchor"))
                    .scaleEffect(appeared ? 1.0 : 0.5)
                    .opacity(appeared ? 1.0 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: appeared)

                Text("You're In, Brother.")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(Color("TextPrimary"))

                Text("Here's how to make your first day count:")
                    .font(.system(size: 15))
                    .foregroundColor(Color("TextSecondary"))
            }
            .padding(.bottom, 28)
            .opacity(appeared ? 1.0 : 0)
            .animation(.easeOut(duration: 0.4).delay(0.1), value: appeared)

            // Steps
            VStack(spacing: 0) {
                GuideStep(
                    number: "1",
                    color: "BrandAnchor",
                    icon: "anchor",
                    title: "Complete Your Morning Anchor",
                    description: "Read the scripture prompt, reflect, and anchor yourself in Christ."
                )

                GuideConnector()

                GuideStep(
                    number: "2",
                    color: "BrandArrow",
                    icon: "arrow.up.right",
                    title: "Log Your Evening Arrow",
                    description: "Record one kingdom action you took today — serve, speak truth, or pray."
                )

                GuideConnector()

                GuideStep(
                    number: "3",
                    color: "BrandGold",
                    icon: "person.3.fill",
                    title: "Join or Create a Circle",
                    description: "Find brothers to sharpen you. Accountability changes everything."
                )
            }
            .padding(.horizontal, 28)
            .opacity(appeared ? 1.0 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(.easeOut(duration: 0.5).delay(0.3), value: appeared)

            Spacer()

            // CTA
            Button {
                isPresented = false
            } label: {
                HStack {
                    Text("Let's Go")
                        .font(.system(size: 17, weight: .bold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    LinearGradient(
                        colors: [Color("BrandAnchor"), Color("BrandArrow")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(14)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            .opacity(appeared ? 1.0 : 0)
            .animation(.easeOut(duration: 0.4).delay(0.5), value: appeared)
        }
        .background(Color("BackgroundPrimary").ignoresSafeArea())
        .onAppear { appeared = true }
    }
}

// MARK: - Guide Step
private struct GuideStep: View {
    let number: String
    let color: String
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                SwiftUI.Circle()
                    .fill(Color(color).opacity(0.15))
                    .frame(width: 42, height: 42)
                Text(number)
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundColor(Color(color))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(Color("TextSecondary"))
                    .lineSpacing(3)
            }
            .padding(.top, 2)
        }
    }
}

// MARK: - Connector Line
private struct GuideConnector: View {
    var body: some View {
        HStack {
            Rectangle()
                .fill(Color("TextSecondary").opacity(0.2))
                .frame(width: 2, height: 20)
                .padding(.leading, 20)
            Spacer()
        }
    }
}
