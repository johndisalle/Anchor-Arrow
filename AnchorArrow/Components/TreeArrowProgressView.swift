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
        VStack(spacing: 0) {

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
                .padding(.vertical, 5)

            // Nautical anchor
            Image(systemName: "anchor")
                .renderingMode(.template)
                .font(.system(size: 120, weight: .thin))
                .foregroundStyle(Color("BrandAnchor"))
                .scaleEffect(anchorRevealed ? 1.0 : 0.1)
                .opacity(anchorRevealed ? 1.0 : 0)

            // Streak badge below anchor
            if streak > 0 {
                HStack(spacing: 5) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                    Text("\(streak) day streak")
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color("BrandAnchor"))
                .cornerRadius(10)
                .opacity(anchorRevealed ? 1 : 0)
                .padding(.top, 10)
            }
        }
        .frame(maxWidth: .infinity)
        .onAppear { triggerAnimation() }
        .onChange(of: animate) { if animate { triggerAnimation() } }
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
    var color: Color = Color("BrandArrow")

    var body: some View {
        Canvas { context, size in
            // Arrow 1: bottom-left → top-right (↗)
            CrossedArrowsView.drawArrow(
                &context,
                from: CGPoint(x: size.width * 0.10, y: size.height * 0.90),
                to:   CGPoint(x: size.width * 0.90, y: size.height * 0.10),
                color: color
            )
            // Arrow 2: bottom-right → top-left (↖)
            CrossedArrowsView.drawArrow(
                &context,
                from: CGPoint(x: size.width * 0.90, y: size.height * 0.90),
                to:   CGPoint(x: size.width * 0.10, y: size.height * 0.10),
                color: color
            )
        }
    }

    private static func drawArrow(
        _ context: inout GraphicsContext,
        from tail: CGPoint,
        to tip: CGPoint,
        color: Color
    ) {
        let dx = tip.x - tail.x
        let dy = tip.y - tail.y
        let len = sqrt(dx * dx + dy * dy)
        let ux = dx / len, uy = dy / len   // unit vector toward tip
        let px = -uy,      py =  ux        // perpendicular (left-normal)
        let shading = GraphicsContext.Shading.color(color)

        // Shaft
        var shaft = Path()
        shaft.move(to: tail)
        shaft.addLine(to: tip)
        context.stroke(shaft, with: shading,
                       style: StrokeStyle(lineWidth: 2.5, lineCap: .round))

        // Arrowhead (V at tip)
        let angle     = atan2(dy, dx)
        let headLen:  CGFloat = 13
        let spread:   CGFloat = .pi / 5
        var head = Path()
        head.move(to: tip)
        head.addLine(to: CGPoint(
            x: tip.x - headLen * cos(angle - spread),
            y: tip.y - headLen * sin(angle - spread)))
        head.move(to: tip)
        head.addLine(to: CGPoint(
            x: tip.x - headLen * cos(angle + spread),
            y: tip.y - headLen * sin(angle + spread)))
        context.stroke(head, with: shading,
                       style: StrokeStyle(lineWidth: 2.5, lineCap: .round))

        // Fletching chevrons near tail
        let fletchLen: CGFloat = 7
        for t: CGFloat in [0.08, 0.16] {
            let base = CGPoint(x: tail.x + ux * len * t,
                               y: tail.y + uy * len * t)
            var fletch = Path()
            fletch.move(to: CGPoint(x: base.x + px * fletchLen,
                                    y: base.y + py * fletchLen))
            fletch.addLine(to: base)
            fletch.addLine(to: CGPoint(x: base.x - px * fletchLen,
                                       y: base.y - py * fletchLen))
            context.stroke(fletch, with: .color(color.opacity(0.55)),
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

// MARK: - Single Upward Archery Arrow
struct UpwardArcheryArrowView: View {
    var color: Color = Color("BrandArrow")

    var body: some View {
        Canvas { context, size in
            let cx = size.width / 2
            let tip  = CGPoint(x: cx, y: 0)
            let tail = CGPoint(x: cx, y: size.height)
            let shading = GraphicsContext.Shading.color(color)

            // Shaft
            var shaft = Path()
            shaft.move(to: tail)
            shaft.addLine(to: tip)
            context.stroke(shaft, with: shading,
                           style: StrokeStyle(lineWidth: 2.5, lineCap: .round))

            // Arrowhead (pointing straight up, angle = -π/2)
            let angle: CGFloat = -.pi / 2
            let headLen: CGFloat = 13
            let headSpread: CGFloat = .pi / 5
            var head = Path()
            head.move(to: tip)
            head.addLine(to: CGPoint(
                x: tip.x - headLen * cos(angle - headSpread),
                y: tip.y - headLen * sin(angle - headSpread)))
            head.move(to: tip)
            head.addLine(to: CGPoint(
                x: tip.x - headLen * cos(angle + headSpread),
                y: tip.y - headLen * sin(angle + headSpread)))
            context.stroke(head, with: shading,
                           style: StrokeStyle(lineWidth: 2.5, lineCap: .round))

            // Fletching chevrons at tail (shaft goes upward, so ux=0 uy=-1, perp=rightward)
            let fletchLen: CGFloat = 7
            for offset: CGFloat in [8, 17] {
                // move offset pts toward tip (upward)
                let base = CGPoint(x: cx, y: size.height - offset)
                var fletch = Path()
                fletch.move(to: CGPoint(x: base.x - fletchLen, y: base.y))
                fletch.addLine(to: base)
                fletch.addLine(to: CGPoint(x: base.x + fletchLen, y: base.y))
                context.stroke(fletch, with: .color(color.opacity(0.65)),
                               style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            }
        }
    }
}

// MARK: - Array safe subscript
extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0 && index < count else { return nil }
        return self[index]
    }
}
