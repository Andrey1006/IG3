
import Foundation
import Combine

struct MBLivePhase {
    static let idle = "idle"
    static let awaitingKickoff = "awaiting"
    static let running = "running"
    static let paused = "paused"
}

@MainActor
final class MBLiveSession: ObservableObject {
    @Published private(set) var match: MBMatch?
    @Published private(set) var phaseIdentifier = MBLivePhase.idle
    @Published private(set) var currentPeriodIndex = 0
    @Published private(set) var periodStartedAt: Date?
    @Published private(set) var secondsBankedInPeriod = 0

    private let defaults = UserDefaults.standard
    private let sessionStorageKey = "momentumball.live"

    init() {
        restore()
    }

    var isClockRunning: Bool {
        return phaseIdentifier == MBLivePhase.running
    }

    var hasMatchInProgress: Bool {
        return match != nil
    }

    var isFinalPeriod: Bool {
        guard let match = match else {
            return true
        }
        return currentPeriodIndex >= match.format.periodCount - 1
    }

    var lastPressureOrSubstitutionEvent: MBMatchEvent? {
        return match?.events.last
    }

    func periodSecond(now: Date) -> Int {
        guard let periodStartedAt = periodStartedAt, isClockRunning else {
            return secondsBankedInPeriod
        }
        return secondsBankedInPeriod + max(0, Int(now.timeIntervalSince(periodStartedAt)))
    }

    func timelineSecond(now: Date) -> Int {
        guard let match = match else {
            return 0
        }
        return match.periodStartTimelineSecond(periodIndex: currentPeriodIndex) + periodSecond(now: now)
    }

    func clockLabel(now: Date) -> String {
        guard let match = match else {
            return MBTexts.clockZero
        }
        let elapsedInPeriod = periodSecond(now: now)
        let matchClockSeconds = currentPeriodIndex * match.format.nominalPeriodSeconds + elapsedInPeriod
        return MBTexts.clockFace(minutes: matchClockSeconds / 60, seconds: matchClockSeconds % 60)
    }

    func isInAddedTime(now: Date) -> Bool {
        guard let match = match else {
            return false
        }
        return periodSecond(now: now) >= match.format.nominalPeriodSeconds
    }

    func begin(match newMatch: MBMatch) {
        match = newMatch
        currentPeriodIndex = 0
        secondsBankedInPeriod = 0
        periodStartedAt = nil
        phaseIdentifier = MBLivePhase.awaitingKickoff
        persist()
    }

    func kickOff(now: Date) {
        if (phaseIdentifier != MBLivePhase.awaitingKickoff) {
            return
        }
        secondsBankedInPeriod = 0
        periodStartedAt = now
        phaseIdentifier = MBLivePhase.running
        persist()
    }

    func pause(now: Date) {
        if (phaseIdentifier != MBLivePhase.running) {
            return
        }
        secondsBankedInPeriod = periodSecond(now: now)
        periodStartedAt = nil
        phaseIdentifier = MBLivePhase.paused
        persist()
    }

    func resume(now: Date) {
        if (phaseIdentifier != MBLivePhase.paused) {
            return
        }
        periodStartedAt = now
        phaseIdentifier = MBLivePhase.running
        persist()
    }

    func closePeriod(now: Date) -> Bool {
        guard var updatedMatch = match else {
            return false
        }
        let playedInPeriod = max(periodSecond(now: now), 1)
        updatedMatch.playedSecondsPerPeriod.append(playedInPeriod)
        match = updatedMatch
        periodStartedAt = nil
        secondsBankedInPeriod = 0
        if (currentPeriodIndex >= updatedMatch.format.periodCount - 1) {
            phaseIdentifier = MBLivePhase.paused
            persist()
            return true
        }
        currentPeriodIndex += 1
        phaseIdentifier = MBLivePhase.awaitingKickoff
        persist()
        return false
    }

    func finalWhistle(now: Date) -> MBMatch? {
        guard var finishedMatch = match else {
            return nil
        }
        let periodAlreadyClosed = finishedMatch.playedSecondsPerPeriod.count > currentPeriodIndex
        let currentPeriodHasPlay = phaseIdentifier == MBLivePhase.running || phaseIdentifier == MBLivePhase.paused
        if (periodAlreadyClosed == false && currentPeriodHasPlay) {
            finishedMatch.playedSecondsPerPeriod.append(max(periodSecond(now: now), 1))
        }
        if (finishedMatch.playedSecondsPerPeriod.isEmpty) {
            finishedMatch.playedSecondsPerPeriod = [1]
        }
        return finishedMatch
    }

    func log(kind: MBEventKind, isPrimarySide: Bool, now: Date) -> Bool {
        guard var updatedMatch = match, isClockRunning else {
            return false
        }
        updatedMatch.events.append(MBMatchEvent(kindIdentifier: kind.identifier, isPrimarySide: isPrimarySide, periodIndex: currentPeriodIndex, periodSecond: periodSecond(now: now)))
        match = updatedMatch
        persist()
        return true
    }

    func logSubstitution(isPrimarySide: Bool, outgoingPlayerIdentifier: String?, incomingPlayerIdentifier: String?, now: Date) -> Bool {
        guard var updatedMatch = match, phaseIdentifier != MBLivePhase.idle else {
            return false
        }
        updatedMatch.events.append(MBMatchEvent(kindIdentifier: MBEventKind.substitution.identifier, isPrimarySide: isPrimarySide, periodIndex: currentPeriodIndex, periodSecond: periodSecond(now: now), outgoingPlayerIdentifier: outgoingPlayerIdentifier, incomingPlayerIdentifier: incomingPlayerIdentifier))
        match = updatedMatch
        persist()
        return true
    }

    func undoLastEvent() -> MBMatchEvent? {
        guard var updatedMatch = match, let removedEvent = updatedMatch.events.popLast() else {
            return nil
        }
        match = updatedMatch
        persist()
        return removedEvent
    }

    func discard() {
        match = nil
        phaseIdentifier = MBLivePhase.idle
        currentPeriodIndex = 0
        periodStartedAt = nil
        secondsBankedInPeriod = 0
        defaults.removeObject(forKey: sessionStorageKey)
    }

    private func persist() {
        guard let match = match else {
            defaults.removeObject(forKey: sessionStorageKey)
            return
        }
        var sessionSnapshot: [String: Any] = ["match": match.plistDictionary, "phase": phaseIdentifier, "period": currentPeriodIndex, "banked": secondsBankedInPeriod]
        if let periodStartedAt = periodStartedAt {
            sessionSnapshot["startedAt"] = periodStartedAt.timeIntervalSince1970
        }
        defaults.set(sessionSnapshot, forKey: sessionStorageKey)
    }

    private func restore() {
        guard let sessionSnapshot = defaults.dictionary(forKey: sessionStorageKey), let matchDictionary = sessionSnapshot["match"] as? [String: Any], let restoredMatch = MBMatch(plistDictionary: matchDictionary) else {
            defaults.removeObject(forKey: sessionStorageKey)
            return
        }
        match = restoredMatch
        phaseIdentifier = sessionSnapshot["phase"] as? String ?? MBLivePhase.paused
        currentPeriodIndex = sessionSnapshot["period"] as? Int ?? 0
        secondsBankedInPeriod = sessionSnapshot["banked"] as? Int ?? 0
        if let startedAtStamp = sessionSnapshot["startedAt"] as? Double {
            periodStartedAt = Date(timeIntervalSince1970: startedAtStamp)
        } else if (phaseIdentifier == MBLivePhase.running) {
            phaseIdentifier = MBLivePhase.paused
        }
    }
}
