import SwiftUI

struct AnchorLabyrinth: View {
    let frame: CGRect
    let progress: CGFloat
    let fingerPoint: CGPoint?
    let glowPhase: Bool

    var body: some View {
        Canvas { context, _ in
            let path = LabyrinthMath.path(in: frame)

            context.stroke(
                path,
                with: .color(.white.opacity(0.14)),
                style: StrokeStyle(lineWidth: 18, lineCap: .round, lineJoin: .round)
            )

            context.stroke(
                path,
                with: .color(Color(red: 1.0, green: 0.91, blue: 0.75).opacity(0.52)),
                style: StrokeStyle(lineWidth: glowPhase ? 8 : 5, lineCap: .round, lineJoin: .round)
            )

            context.stroke(
                path,
                with: .color(Color(red: 1.0, green: 0.97, blue: 0.90)),
                style: StrokeStyle(lineWidth: 2.4, lineCap: .round, lineJoin: .round)
            )

            let traced = path.trimmedPath(from: 0, to: progress)
            context.stroke(
                traced,
                with: .color(.white.opacity(0.95)),
                style: StrokeStyle(lineWidth: 7, lineCap: .round, lineJoin: .round)
            )

            if let fingerPoint {
                let r = CGRect(x: fingerPoint.x - 18, y: fingerPoint.y - 18, width: 36, height: 36)
                context.fill(Path(ellipseIn: r), with: .color(Color(red: 1.0, green: 0.93, blue: 0.80).opacity(0.92)))
            }
        }
        .ignoresSafeArea()
    }
}

enum LabyrinthMath {
    static func path(in frame: CGRect) -> Path {
        let points = sampledPoints(in: frame)
        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: first)
        for point in points.dropFirst() { path.addLine(to: point) }
        return path
    }

    static func closestProgress(to point: CGPoint, in frame: CGRect) -> CGFloat {
        let points = sampledPoints(in: frame)
        var bestIndex = 0
        var bestDistance = CGFloat.greatestFiniteMagnitude

        for (index, candidate) in points.enumerated() {
            let dx = point.x - candidate.x
            let dy = point.y - candidate.y
            let distance = dx * dx + dy * dy
            if distance < bestDistance {
                bestDistance = distance
                bestIndex = index
            }
        }

        return CGFloat(bestIndex) / CGFloat(max(points.count - 1, 1))
    }

    static func sampledPoints(in frame: CGRect) -> [CGPoint] {
        let centre = CGPoint(x: frame.midX, y: frame.midY)
        let outerRadius = min(frame.width, frame.height) * 0.44
        let innerRadius = min(frame.width, frame.height) * 0.045
        let turns: CGFloat = 5.4
        let count = 900

        return (0..<count).map { index in
            let t = CGFloat(index) / CGFloat(count - 1)
            let eased = t * t * (3 - 2 * t)
            let radius = outerRadius + (innerRadius - outerRadius) * eased
            let angle = (.pi / 2) + turns * 2 * .pi * t
            let wave = sin(t * .pi * 8) * frame.width * 0.008

            return CGPoint(
                x: centre.x + cos(angle) * (radius + wave),
                y: centre.y + sin(angle) * (radius + wave)
            )
        }
    }
}
