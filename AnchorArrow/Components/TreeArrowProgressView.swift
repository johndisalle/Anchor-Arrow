// TreeArrowProgressView.swift
// Home screen hero visual — nautical anchor + crossed archery arrows

import SwiftUI

// MARK: - Hero View (anchor + arrows)
struct TreeArrowProgressView: View {
    let anchorProgress: Double
    let arrowProgress: Double
    let streak: Int
    let animate: Bool

    @State private var anchorRevealed = false
    @State private var arrowsRevealed = false

    var body: some View {
        VStack(spacing: 4) {

            // Crossed archery arrows
            CrossedArrowsView()
                .frame(width: 140, height: 88)
                .scaleEffect(arrowsRevealed ? 1.0 : 0.15)
                .opacity(arrowsRevealed ? 1.0 : 0)

            // Ground line
            Rectangle()
                .fill(Color("BrandEarth").opacity(0.25))
                .frame(height: 1.5)
                .frame(maxWidth: 200)

            // Nautical anchor
            ZStack(alignment: .bottom) {
                Image(systemName: "anchor")
                    .font(.system(size: 86, weight: .thin))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color("BrandAnchor"), Color("BrandAnchor").opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(anchorRevealed ? 1.0 : 0.1)
                    .opacity(anchorRevealed ? 1.0 : 0)

                // Streak badge below anchor
                if streak > 0 {
                    VStack(spacing: 1) {
                        Text("\(streak)")
                            .font(.system(size: 14, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                        Text("days")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color("BrandAnchor"))
                    .cornerRadius(8)
                    .offset(y: 28)
                    .opacity(anchorRevealed ? 1 : 0)
                }
            }
            .padding(.bottom, streak > 0 ? 28 : 0)
        }
        .frame(maxWidth: .infinity)
        .onAppear { triggerAnimation() }
        .onChange(of: animate) { newValue in if newValue { triggerAnimation() } }
    }

    private func triggerAnimation() {
        guard animate else { return }
        withAnimation(.spring(response: 0.9, dampingFraction: 0.65).delay(0.2)) {
            anchorRevealed = true
        }
        withAnimation(.spring(response: 0.7, dampingFraction: 0.65).delay(1.0)) {
            arrowsRevealed = true
        }
    }
}

// MARK: - Crossed Archery Arrows
struct CrossedArrowsView: View {
    var body: some View {
        Canvas { context, size in
            let cx = size.width / 2
            let cy = size.height / 2

            // Arrow 1: tip at top-left, tail at bottom-right
            drawArcheryArrow(
                in: context,
                tip: CGPoint(x: cx - 52, y: cy - 30),
                tail: CGPoint(x: cx + 52, y: cy + 30),
                color: Color("BrandArrow")
            )

            // Arrow 2: tip at top-right, tail at bottom-left
            drawArcheryArrow(
                in: context,
                tip: CGPoint(x: cx + 52, y: cy - 30),
                tail: CGPoint(x: cx - 52, y: cy + 30),
                color: Color("BrandArrow")
            )
        }
    }

    private func drawArcheryArrow(in context: GraphicsContext, tip: CGPoint, tail: CGPoint, color: Color) {
        let shading = GraphicsContext.Shading.color(color)

        // Shaft
        var shaft = Path()
        shaft.move(to: tail)
        shaft.addLine(to: tip)
        context.stroke(shaft, with: shading, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))

        // Arrowhead at tip
        let angle = atan2(tip.y - tail.y, tip.x - tail.x)
        let headLen: CGFloat = 13
        let headSpread: CGFloat = .pi / 5

        var head = Path()
        head.move(to: tip)
        head.addLine(to: CGPoint(
            x: tip.x - headLen * cos(angle - headSpread),
            y: tip.y - headLen * sin(angle - headSpread)
        ))
        head.move(to: tip)
        head.addLine(to: CGPoint(
            x: tip.x - headLen * cos(angle + headSpread),
            y: tip.y - headLen * sin(angle + headSpread)
        ))
        context.stroke(head, with: shading, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))

        // Fletching chevrons at tail (2 marks)
        let dx = tip.x - tail.x
        let dy = tip.y - tail.y
        let len = sqrt(dx * dx + dy * dy)
        let ux = dx / len  // unit vector toward tip
        let uy = dy / len
        let px = -uy    // perpendicular
        let py = ux
        let fletchLen: CGFloat = 7

        for offset: CGFloat in [8, 17] {
            let base = CGPoint(x: tail.x + offset * ux, y: tail.y + offset * uy)
            var fletch = Path()
            fletch.move(to: CGPoint(x: base.x - fletchLen * px, y: base.y - fletchLen * py))
            fletch.addLine(to: base)
            fletch.addLine(to: CGPoint(x: base.x + fletchLen * px, y: base.y + fletchLen * py))
            context.stroke(fletch, with: .color(color.opacity(0.65)),
                           style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        }
    }
}

// MARK: - Anchor Roots Shape (used by SplashView)
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
