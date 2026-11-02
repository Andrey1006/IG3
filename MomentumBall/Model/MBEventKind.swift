
import Foundation

struct MBEventKind: Hashable {
    let identifier: String
    let pressureWeight: Double
    let emoji: String
    let title: String
    let swingsToOpponent: Bool
    let needsHoldToConfirm: Bool

    static let attack = MBEventKind(identifier: "attack", pressureWeight: 1.0, emoji: MBTexts.emojiAttack, title: MBTexts.eventAttack, swingsToOpponent: false, needsHoldToConfirm: false)
    static let shot = MBEventKind(identifier: "shot", pressureWeight: 2.0, emoji: MBTexts.emojiShot, title: MBTexts.eventShot, swingsToOpponent: false, needsHoldToConfirm: false)
    static let corner = MBEventKind(identifier: "corner", pressureWeight: 1.5, emoji: MBTexts.emojiCorner, title: MBTexts.eventCorner, swingsToOpponent: false, needsHoldToConfirm: false)
    static let danger = MBEventKind(identifier: "danger", pressureWeight: 3.0, emoji: MBTexts.emojiDanger, title: MBTexts.eventDanger, swingsToOpponent: false, needsHoldToConfirm: false)
    static let loss = MBEventKind(identifier: "loss", pressureWeight: 0.8, emoji: MBTexts.emojiLoss, title: MBTexts.eventLoss, swingsToOpponent: true, needsHoldToConfirm: false)
    static let goal = MBEventKind(identifier: "goal", pressureWeight: 5.0, emoji: MBTexts.emojiGoal, title: MBTexts.eventGoal, swingsToOpponent: false, needsHoldToConfirm: true)
    static let substitution = MBEventKind(identifier: "substitution", pressureWeight: 0, emoji: MBTexts.emojiSubstitution, title: MBTexts.eventSubstitution, swingsToOpponent: false, needsHoldToConfirm: false)

    static let padKinds: [MBEventKind] = [attack, shot, corner, danger, loss, goal]
    static let everyKind: [MBEventKind] = [attack, shot, corner, danger, loss, goal, substitution]

    var isPressureMoment: Bool {
        return pressureWeight > 0
    }

    static func resolve(identifier: String) -> MBEventKind {
        return findKind(identifier: identifier, remainingKinds: everyKind[...])
    }

    private static func findKind(identifier: String, remainingKinds: ArraySlice<MBEventKind>) -> MBEventKind {
        guard let candidateKind = remainingKinds.first else {
            return attack
        }
        if (candidateKind.identifier == identifier) {
            return candidateKind
        }
        return findKind(identifier: identifier, remainingKinds: remainingKinds.dropFirst())
    }
}
