import SwiftUI

struct AnchorView: View {
    @StateObject private var haptics = HapticEngine()
    @State private var fingerPoint: CGPoint?
    @State private var progress: CGFloat = 0
    @State private var lastPulseProgress: CGFloat = 0
    @State private var reachedCentre = false
    @State private var returningOutward = false
    @State private var glowPhase = false

    private let pulseSpacing: CGFloat = 0.035

    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height) * 0.86
            let frame = CGRect(
                x: (proxy.size.width - size) / 2,
                y: (proxy.size.height - size) / 2,
                width: size,
                height: size
            )

            ZStack {
                Color.black.ignoresSafeArea()

                AnchorLabyrinth(
                    frame: frame,
                    progress: progress,
                    fingerPoint: fingerPoint,
                    glowPhase: glowPhase
                )

                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                fingerPoint = value.location
                                updateTracing(at: value.location, in: frame)
                            }
                            .onEnded { _ in fingerPoint = nil }
                    )
            }
            .onAppear {
                haptics.prepare()
                withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                    glowPhase.toggle()
                }
            }
        }
        .persistentSystemOverlays(.hidden)
        .statusBarHidden(true)
    }

    private func updateTracing(at point: CGPoint, in frame: CGRect) {
        let newProgress = LabyrinthMath.closestProgress(to: point, in: frame)
        progress = newProgress

        if abs(newProgress - lastPulseProgress) >= pulseSpacing {
            haptics.softTick()
            lastPulseProgress = newProgress
        }

        if newProgress > 0.965 && !reachedCentre {
            reachedCentre = true
            returningOutward = true
            haptics.centrePulse()
        }

        if returningOutward && newProgress < 0.035 {
            returningOutward = false
            reachedCentre = false
            haptics.outerPulse()
        }
    }
}
