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
    @State private var arrowOffset: CGFloat = 0

    var body: some View {
        ZStack {
            // Ground line
            Rectangle()
                .fill(Color("BrandEarth").opacity(0.3))
                .frame(height: 2)
                .frame(maxWidth: .infinity)
                .offset(y: 60)

            // Root system (anchor = stand firm)
            RootsView(progress: rootsAnimated ? anchorProgress : 0)
                .offset(y: 60)

            // Trunk
            RoundedRectangle(cornerRadius: 5)
                .fill(
                    LinearGradient(
                        colors: [Color("BrandEarth"), Color("BrandEarth").opacity(0.6)],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .frame(width: 12, height: trunkAnimated ? trunkHeight : 0)
                .offset(y: trunkAnimated ? trunkOffsetY : 60)
                .animation(.easeOut(duration: 0.7).delay(0.4), value: trunkAnimated)

            // Canopy (foliage)
            if canopyAnimated {
                CanopyView(size: canopySize)
                    .offset(y: canopyOffsetY)
                    .transition(.scale(scale: 0, anchor: .bottom).combined(with: .opacity))
            }

            // Flying arrows (arrow progress)
            ForEach(0..<arrowCount, id: \.self) { index in
                ArrowProjectile(
                    index: index,
                    total: arrowCount,
                    animated: arrowsAnimated
                )
                .offset(y: canopyOffsetY - 20)
            }

            // Streak number on trunk
            if streak > 0 && trunkAnimated {
                VStack(spacing: 2) {
                    Text("\(streak)")
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundColor(.white)
                    Text("days")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                }
                .offset(y: trunkOffsetY + 8)
                .opacity(canopyAnimated ? 1 : 0)
                .animation(.easeIn(duration: 0.3).delay(1.2), value: canopyAnimated)
            }
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            guard animate else { return }
            withAnimation(.easeOut(duration: 0.8)) { rootsAnimated = true }
            withAnimation(.easeOut(duration: 0.7).delay(0.4)) { trunkAnimated = true }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(1.0)) { canopyAnimated = true }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(1.4)) { arrowsAnimated = true }
        }
        .onChange(of: animate) { newValue in
            if newValue {
                withAnimation(.easeOut(duration: 0.8)) { rootsAnimated = true }
                withAnimation(.easeOut(duration: 0.7).delay(0.4)) { trunkAnimated = true }
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(1.0)) { canopyAnimated = true }
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(1.4)) { arrowsAnimated = true }
            }
        }
    }

    // MARK: - Computed sizes
    private var trunkHeight: CGFloat { 60 + CGFloat(anchorProgress * 40) }
    private var trunkOffsetY: CGFloat { 30 - trunkHeight / 2 }
    private var canopySize: CGFloat { 80 + CGFloat(anchorProgress * 60) }
    private var canopyOffsetY: CGFloat { trunkOffsetY - trunkHeight / 2 - canopySize / 3 }
    private var arrowCount: Int { max(0, Int(arrowProgress * 5)) }  // 0-5 arrows
}

// MARK: - Roots (Anchor visual)
struct RootsView: View {
    let progress: Double

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: 0)
            let rootColor = Color("BrandAnchor")

            // Draw 5 root branches spreading outward and downward
            let roots: [(angle: Double, length: Double)] = [
                (-80, 60), (-50, 80), (-10, 90), (30, 80), (60, 60)
            ]

            for root in roots {
                let endAngle = root.angle * .pi / 180
                let fullLength = root.length * progress

                var path = Path()
                path.move(to: center)

                // Curved root with 2 segments
                let mid = CGPoint(
                    x: center.x + cos(endAngle) * fullLength * 0.5 + (Double.random(in: -8...8)),
                    y: center.y + sin(endAngle.magnitude) * fullLength * 0.4
                )
                let end = CGPoint(
                    x: center.x + cos(endAngle) * fullLength,
                    y: center.y + sin(endAngle.magnitude) * fullLength
                )

                path.addQuadCurve(to: end, control: mid)

                context.stroke(
                    path,
                    with: .color(rootColor),
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                )

                // Tiny taproot at end
                if progress > 0.4 {
                    var tapPath = Path()
                    tapPath.move(to: end)
                    tapPath.addLine(to: CGPoint(x: end.x, y: end.y + 12 * progress))
                    context.stroke(
                        tapPath,
                        with: .color(rootColor.opacity(0.6)),
                        style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
                    )
                }
            }
        }
        .frame(width: 200, height: 100)
        .animation(.easeOut(duration: 0.8), value: progress)
    }
}

// MARK: - Tree Canopy
struct CanopyView: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            // Back layers (darker)
            Circle()
                .fill(Color("BrandEarth").opacity(0.4))
                .frame(width: size * 0.7, height: size * 0.7)
                .offset(x: -size * 0.2, y: size * 0.1)

            Circle()
                .fill(Color("BrandEarth").opacity(0.4))
                .frame(width: size * 0.65, height: size * 0.65)
                .offset(x: size * 0.2, y: size * 0.1)

            // Main canopy
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color("BrandEarth"),
                            Color("BrandEarth").opacity(0.7)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size / 2
                    )
                )
                .frame(width: size, height: size * 0.85)

            // Highlight (light top)
            Ellipse()
                .fill(Color.white.opacity(0.08))
                .frame(width: size * 0.5, height: size * 0.3)
                .offset(y: -size * 0.15)
        }
    }
}

// MARK: - Arrow Projectile
struct ArrowProjectile: View {
    let index: Int
    let total: Int
    let animated: Bool

    @State private var launched = false

    private var angle: Double {
        let angles: [Double] = [-60, -35, -10, 15, 40]
        return angles[safe: index] ?? -20
    }

    private var delay: Double { Double(index) * 0.15 }

    var body: some View {
        Image(systemName: "arrow.up.right")
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(Color("BrandArrow"))
            .rotationEffect(.degrees(angle))
            .offset(
                x: launched ? cos(angle * .pi / 180) * 80 : 0,
                y: launched ? sin(angle * .pi / 180) * -80 : 0
            )
            .opacity(launched ? 0.85 : 0)
            .animation(
                .spring(response: 0.5, dampingFraction: 0.6).delay(delay),
                value: launched
            )
            .onAppear {
                if animated {
                    launched = true
                }
            }
            .onChange(of: animated) { newValue in
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
