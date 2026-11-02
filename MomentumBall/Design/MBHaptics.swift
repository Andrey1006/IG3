
import UIKit

struct MBHaptics {
    static var isEnabled = true

    static func tick() {
        if (isEnabled) {
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }

    static func momentLogged(weight: Double) {
        guard isEnabled else {
            return
        }
        let impactIntensity = min(1.0, 0.45 + weight * 0.12)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: CGFloat(impactIntensity))
    }

    static func goal() {
        if (isEnabled == false) {
            return
        }
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred(intensity: 1.0)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func initiativeFlip() {
        if (isEnabled) {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.9)
        }
    }

    static func rejected() {
        if (isEnabled) {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }

    static func confirmed() {
        if (isEnabled) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    static func whistle() {
        if (isEnabled) {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 1.0)
        }
    }
}
