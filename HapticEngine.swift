import Foundation
import CoreHaptics
import UIKit

final class HapticEngine: ObservableObject {
    private var engine: CHHapticEngine?

    func prepare() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
            engine?.resetHandler = { [weak self] in try? self?.engine?.start() }
        } catch {
            engine = nil
        }
    }

    func softTick() { play(intensity: 0.28, sharpness: 0.18, duration: 0.018) }

    func centrePulse() {
        playPattern([
            (0.00, 0.48, 0.12, 0.05),
            (0.09, 0.30, 0.06, 0.10),
            (0.20, 0.55, 0.10, 0.08)
        ])
    }

    func outerPulse() {
        playPattern([
            (0.00, 0.34, 0.10, 0.04),
            (0.08, 0.22, 0.05, 0.06)
        ])
    }

    private func play(intensity: Float, sharpness: Float, duration: TimeInterval) {
        guard let engine else {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            return
        }

        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ],
            relativeTime: 0,
            duration: duration
        )

        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
    }

    private func playPattern(_ values: [(TimeInterval, Float, Float, TimeInterval)]) {
        guard let engine else {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            return
        }

        let events = values.map { time, intensity, sharpness, duration in
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
                ],
                relativeTime: time,
                duration: duration
            )
        }

        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
}
