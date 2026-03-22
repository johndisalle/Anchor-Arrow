// TreeArrowProgressView.swift
// Animated rooted tree with arrows — central visual of the app

import SwiftUI

// MARK: - Main Tree + Arrow Progress View
struct TreeArrowProgressView: View {
    let anchorProgress: Double    // 0.0 – 1.0 (drives root depth)
    let arrowProgress: Double     // 0.0 – 1.0 (drives number of arrows)
    let streak: Int
    let animate: Bool

    @State private var rootsAnimated = false
    @State private var trunkAnimated = false
    @State private var canopyAnimated = false
    @State private var arrowsAnimated = false

    var body: some View {
        ZStack {
            // Ground line
            Rectangle()
                .fill(Color("BrandEarth").opacity(0.25))
                .frame(height: 1.5)
                .frame(maxWidth: .infinity)
                .offset(y: 60)

            // Root system
            RootsView(progress: rootsAnimated ? max(0.3, anchorProgress) : 0)
                .offset(y: 60)

            // Trunk
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    LinearGradient(
                        colors: [Color("BrandEarth"), Color("BrandEarth").opacity(0.55)],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .frame(width: 14, height: trunkAnimated ? trunkHeight : 0)
                .offset(y: trunkAnimated ? trunkOffsetY : 60)
                .animation(.easeOut(duration: 0.7).delay(0.4), value: trunkAnimated)

            // Canopy (3-tier tree crown)
            if canopyAnimated {
                CanopyView(size: canopySize)
                    .offset(y: canopyOffsetY)
                    .transition(.scale(scale: 0, anchor: .bottom).combined(with: .opacity))
            }

            // Arrows flying from canopy
            ForEach(0..<displayArrowCount, id: \.self) { index in
                ArrowProjectile(
                    index: index,
                    total: displayArrowCount,
                    animated: arrowsAnimated,
                    isEarned: index < earnedArrowCount
                )
                .offset(y: canopyOffsetY - 10)
            }

            // Anchor icon at base (always visible after trunk)
            if trunkAnimated {
                Image(systemName: "anchor")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("BrandAnchor").opacity(0.5))
                    .offset(y: 68)
                    .opacity(canopyAnimated ? 1 : 0)
                    .animation(.easeIn(duration: 0.3).delay(1.2), value: canopyAnimated)
            }

            // Streak on trunk
            if streak > 0 && canopyAnimated {
                VStack(spacing: 1) {
                    Text("\(streak)")
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundColor(.white)
                    Text("days")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                }
                .offset(y: trunkOffsetY + 4)
                .animation(.easeIn(duration: 0.3).delay(1.2), value: canopyAnimated)
            }
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            guard animate else { return }
            triggerAnimations()
        }
        .onChange(of: animate) { _, newValue in
            if newValue { triggerAnimations() }
        }
    }

    private func triggerAnimations() {
        withAnimation(.easeOut(duration: 0.8)) { rootsAnimated = true }
        withAnimation(.easeOut(duration: 0.7).delay(0.4)) { trunkAnimated = true }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(1.0)) { canopyAnimated = true }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(1.4)) { arrowsAnimated = true }
    }

    // MARK: - Computed sizes
    private var trunkHeight: CGFloat { 70 + CGFloat(anchorProgress * 50) }
    private var trunkOffsetY: CGFloat { 30 - trunkHeight / 2 }
    private var canopySize: CGFloat { 90 + CGFloat(anchorProgress * 60) }
    private var canopyOffsetY: CGFloat { trunkOffsetY - trunkHeight / 2 - canopySize * 0.28 }

    // Always show 3 arrow slots so user understands the concept; earned ones are bright
    private var displayArrowCount: Int { 3 }
    private var earnedArrowCount: Int { max(0, Int(arrowProgress * 5)) }
}

// MARK: - Roots (Anchor visual)
struct RootsView: View {
    let progress: Double

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: 0)
            let rootColor = Color("BrandAnchor")

            let roots: [(angle: Double, length: Double)] = [
                (-75, 55), (-45, 72), (-10, 82), (25, 72), (55, 55)
            ]

            for root in roots {
                let endAngle = root.angle * .pi / 180
                let fullLength = root.length * progress

                var path = Path()
                path.move(to: center)

                let mid = CGPoint(
                    x: center.x + cos(endAngle) * fullLength * 0.5,
                    y: center.y + sin(endAngle.magnitude) * fullLength * 0.4
                )
                let end = CGPoint(
                    x: center.x + cos(endAngle) * fullLength,
                    y: center.y + sin(endAngle.magnitude) * fullLength
                )

                path.addQuadCurve(to: end, control: mid)
                context.stroke(path, with: .color(rootColor.opacity(0.7)),
                               style: StrokeStyle(lineWidth: 2.5, lineCap: .round))

                if progress > 0.4 {
                    var tapPath = Path()
                    tapPath.move(to: end)
                    tapPath.addLine(to: CGPoint(x: end.x, y: end.y + 10 * progress))
                    context.stroke(tapPath, with: .color(rootColor.opacity(0.4)),
                                   style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                }
            }
        }
        .frame(width: 200, height: 100)
        .animation(.easeOut(duration: 0.8), value: progress)
    }
}

// MARK: - Tree Canopy (3-tier layered crown)
struct CanopyView: View {
    let size: CGFloat

    private let darkGreen  = Color(red: 0.18, green: 0.45, blue: 0.22)
    private let midGreen   = Color(red: 0.24, green: 0.54, blue: 0.28)
    private let lightGreen = Color(red: 0.30, green: 0.62, blue: 0.33)

    var body: some View {
        ZStack {
            // Tier 1 — bottom / widest
            Ellipse()
                .fill(darkGreen.opacity(0.85))
                .frame(width: size, height: size * 0.45)
                .offset(y: size * 0.18)

            // Tier 2 — middle
            Ellipse()
                .fill(midGreen.opacity(0.9))
                .frame(width: size * 0.78, height: size * 0.46)
                .offset(y: -size * 0.02)

            // Tier 3 — top / narrowest
            Ellipse()
                .fill(lightGreen)
                .frame(width: size * 0.54, height: size * 0.44)
                .offset(y: -size * 0.20)

            // Top highlight
            Ellipse()
                .fill(Color.white.opacity(0.10))
                .frame(width: size * 0.28, height: size * 0.16)
                .offset(y: -size * 0.28)
        }
    }
}

// MARK: - Arrow Projectile
struct ArrowProjectile: View {
    let index: Int
    let total: Int
    let animated: Bool
    let isEarned: Bool      // earned = bright + launched; unearned = faint hint

    @State private var launched = false

    private var angle: Double {
        let angles: [Double] = [-50, -10, 30]
        return angles[safe: index] ?? -10
    }

    private var delay: Double { Double(index) * 0.15 }

    var body: some View {
        Image(systemName: "arrow.up.right")
            .font(.system(size: isEarned ? 20 : 16, weight: .bold))
            .foregroundColor(
                isEarned
                    ? Color("BrandArrow")
                    : Color("BrandArrow").opacity(0.25)
            )
            .rotationEffect(.degrees(angle))
            .offset(
                x: launched ? cos(angle * .pi / 180) * 75 : 0,
                y: launched ? sin(angle * .pi / 180) * -75 : 0
            )
            .opacity(launched ? (isEarned ? 0.9 : 0.4) : 0)
            .animation(
                .spring(response: 0.5, dampingFraction: 0.6).delay(delay),
                value: launched
            )
            .onAppear {
                if animated { launched = true }
            }
            .onChange(of: animated) { _, newValue in
                launched = newValue
            }
    }
}

// MARK: - Anchor Roots Shape (for splash screen)
struct AnchorRootsShape: Shape {
    var progress: Double

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.minY)

        let branches: [(dx: CGFloat, dy: CGFloat)] = [
            (-50, 70), (-25, 80), (0, 85), (25, 80), (50, 70)
        ]

        for branch in branches {
            path.move(to: center)
            let end = CGPoint(
                x: center.x + branch.dx * CGFloat(progress),
                y: center.y + branch.dy * CGFloat(progress)
            )
            let control = CGPoint(
                x: (center.x + end.x) / 2,
                y: center.y + branch.dy * 0.4 * CGFloat(progress)
            )
            path.addQuadCurve(to: end, control: control)
        }

        return path
    }
}

// MARK: - Array safe subscript
extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0 && index < count else { return nil }
        return self[index]
    }
}
