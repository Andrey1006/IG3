
import Foundation

struct MBSlumpSpell: Identifiable, Hashable {
    let isPrimarySide: Bool
    let startTimelineSecond: Int
    let endTimelineSecond: Int
    let startMinuteLabel: String
    let endMinuteLabel: String
    let deepestValue: Double

    var id: String {
        return "\(isPrimarySide)-\(startTimelineSecond)"
    }

    var durationMinutes: Double {
        return Double(endTimelineSecond - startTimelineSecond) / 60
    }
}

struct MBRecoveryRecord: Identifiable, Hashable {
    let id: String
    let concedingIsPrimarySide: Bool
    let goalMinuteLabel: String
    let goalTimelineSecond: Int
    let recoverySeconds: Int?
}

struct MBSubstitutionImpact: Identifiable, Hashable {
    let id: String
    let isPrimarySide: Bool
    let minuteLabel: String
    let outgoingName: String?
    let incomingName: String?
    let beforeAverage: Double?
    let afterAverage: Double?

    var swing: Double? {
        guard let beforeAverage = beforeAverage, let afterAverage = afterAverage else {
            return nil
        }
        return afterAverage - beforeAverage
    }
}

struct MBPlayerStint: Hashable {
    let playerIdentifier: String
    let enteredTimelineSecond: Int
    let leftTimelineSecond: Int
    let averageMomentum: Double?

    var playedSeconds: Int {
        return max(0, leftTimelineSecond - enteredTimelineSecond)
    }
}

struct MBMatchReport {
    static let slumpThreshold = 0.35
    static let slumpMinimumSeconds = 240
    static let initiativeHysteresis = 0.15
    static let substitutionWindowSeconds = 480
    static let substitutionMinimumPoints = 6

    let match: MBMatch
    let wave: [MBWavePoint]
    let primaryControlShare: Double
    let initiativeSwings: Int
    let slumps: [MBSlumpSpell]
    let recoveries: [MBRecoveryRecord]
    let substitutionImpacts: [MBSubstitutionImpact]
    let playerStints: [MBPlayerStint]

    init(match: MBMatch, memoryMinutes: Int, players: [MBPlayer]) {
        let matchWave = MBMomentumEngine.wave(match: match, memoryMinutes: memoryMinutes, toTimelineSecond: max(match.totalPlayedSeconds, 60))
        self.match = match
        self.wave = matchWave
        let controlledPoints = matchWave.filter { wavePoint in
            return wavePoint.value > 0
        }
        self.primaryControlShare = matchWave.isEmpty ? 0.5 : Double(controlledPoints.count) / Double(matchWave.count)
        self.initiativeSwings = MBMatchReport.countSwings(remainingPoints: matchWave[...], currentOwner: 0, swingsSoFar: 0)
        var detectedSlumps: [MBSlumpSpell] = []
        MBMatchReport.detectSlumps(match: match, remainingPoints: matchWave[...], isPrimarySide: true, spellStart: nil, deepestValue: 0, previousPoint: nil, detectedSlumps: &detectedSlumps)
        MBMatchReport.detectSlumps(match: match, remainingPoints: matchWave[...], isPrimarySide: false, spellStart: nil, deepestValue: 0, previousPoint: nil, detectedSlumps: &detectedSlumps)
        self.slumps = detectedSlumps.sorted { firstSpell, secondSpell in
            return firstSpell.startTimelineSecond < secondSpell.startTimelineSecond
        }
        let goalEvents = match.events.filter { matchEvent in
            return matchEvent.kindIdentifier == MBEventKind.goal.identifier
        }
        self.recoveries = goalEvents.map { goalEvent in
            return MBMatchReport.recovery(match: match, wave: matchWave, goalEvent: goalEvent)
        }.sorted { firstRecord, secondRecord in
            return firstRecord.goalTimelineSecond < secondRecord.goalTimelineSecond
        }
        let substitutionEvents = match.events.filter { matchEvent in
            return matchEvent.kindIdentifier == MBEventKind.substitution.identifier
        }.sorted { firstEvent, secondEvent in
            return match.timelineSecond(event: firstEvent) < match.timelineSecond(event: secondEvent)
        }
        self.substitutionImpacts = substitutionEvents.map { substitutionEvent in
            return MBMatchReport.impact(match: match, wave: matchWave, substitutionEvent: substitutionEvent, players: players)
        }
        self.playerStints = MBMatchReport.stints(match: match, wave: matchWave, substitutionEvents: substitutionEvents)
    }

    var primarySlumps: [MBSlumpSpell] {
        return slumps.filter { slumpSpell in
            return slumpSpell.isPrimarySide
        }
    }

    var averagePrimaryRecoverySeconds: Double? {
        let recoveredSpans = recoveries.compactMap { recoveryRecord in
            return recoveryRecord.concedingIsPrimarySide ? recoveryRecord.recoverySeconds : nil
        }
        if (recoveredSpans.isEmpty) {
            return nil
        }
        return Double(MBPlistList.sum(values: recoveredSpans[...])) / Double(recoveredSpans.count)
    }

    private static func countSwings(remainingPoints: ArraySlice<MBWavePoint>, currentOwner: Int, swingsSoFar: Int) -> Int {
        guard let wavePoint = remainingPoints.first else {
            return swingsSoFar
        }
        var updatedOwner = currentOwner
        var updatedSwings = swingsSoFar
        if (wavePoint.value > initiativeHysteresis && currentOwner != 1) {
            updatedSwings += currentOwner == -1 ? 1 : 0
            updatedOwner = 1
        } else if (wavePoint.value < -initiativeHysteresis && currentOwner != -1) {
            updatedSwings += currentOwner == 1 ? 1 : 0
            updatedOwner = -1
        }
        return countSwings(remainingPoints: remainingPoints.dropFirst(), currentOwner: updatedOwner, swingsSoFar: updatedSwings)
    }

    private static func detectSlumps(match: MBMatch, remainingPoints: ArraySlice<MBWavePoint>, isPrimarySide: Bool, spellStart: MBWavePoint?, deepestValue: Double, previousPoint: MBWavePoint?, detectedSlumps: inout [MBSlumpSpell]) {
        guard let wavePoint = remainingPoints.first else {
            if let spellStart = spellStart, let previousPoint = previousPoint {
                appendSlumpIfLongEnough(match: match, isPrimarySide: isPrimarySide, spellStart: spellStart, spellEnd: previousPoint, deepestValue: deepestValue, detectedSlumps: &detectedSlumps)
            }
            return
        }
        let sideValue = isPrimarySide ? wavePoint.value : -wavePoint.value
        let isSinking = sideValue < -slumpThreshold
        if (isSinking) {
            let openedSpell = spellStart ?? wavePoint
            let updatedDeepest = min(deepestValue, sideValue)
            detectSlumps(match: match, remainingPoints: remainingPoints.dropFirst(), isPrimarySide: isPrimarySide, spellStart: openedSpell, deepestValue: updatedDeepest, previousPoint: wavePoint, detectedSlumps: &detectedSlumps)
        } else {
            if let spellStart = spellStart {
                appendSlumpIfLongEnough(match: match, isPrimarySide: isPrimarySide, spellStart: spellStart, spellEnd: wavePoint, deepestValue: deepestValue, detectedSlumps: &detectedSlumps)
            }
            detectSlumps(match: match, remainingPoints: remainingPoints.dropFirst(), isPrimarySide: isPrimarySide, spellStart: nil, deepestValue: 0, previousPoint: wavePoint, detectedSlumps: &detectedSlumps)
        }
    }

    private static func appendSlumpIfLongEnough(match: MBMatch, isPrimarySide: Bool, spellStart: MBWavePoint, spellEnd: MBWavePoint, deepestValue: Double, detectedSlumps: inout [MBSlumpSpell]) {
        if (spellEnd.timelineSecond - spellStart.timelineSecond < slumpMinimumSeconds) {
            return
        }
        detectedSlumps.append(MBSlumpSpell(isPrimarySide: isPrimarySide, startTimelineSecond: spellStart.timelineSecond, endTimelineSecond: spellEnd.timelineSecond, startMinuteLabel: match.minuteLabel(timelineSecond: spellStart.timelineSecond), endMinuteLabel: match.minuteLabel(timelineSecond: spellEnd.timelineSecond), deepestValue: deepestValue))
    }

    private static func recovery(match: MBMatch, wave: [MBWavePoint], goalEvent: MBMatchEvent) -> MBRecoveryRecord {
        let goalTimeline = match.timelineSecond(event: goalEvent)
        let concedingIsPrimary = goalEvent.isPrimarySide == false
        let recoveryPoint = wave.first { wavePoint in
            let sideValue = concedingIsPrimary ? wavePoint.value : -wavePoint.value
            return wavePoint.timelineSecond > goalTimeline && sideValue >= 0
        }
        let recoverySpan = recoveryPoint.map { wavePoint in
            return wavePoint.timelineSecond - goalTimeline
        }
        return MBRecoveryRecord(id: goalEvent.id, concedingIsPrimarySide: concedingIsPrimary, goalMinuteLabel: match.minuteLabel(event: goalEvent), goalTimelineSecond: goalTimeline, recoverySeconds: recoverySpan)
    }

    private static func impact(match: MBMatch, wave: [MBWavePoint], substitutionEvent: MBMatchEvent, players: [MBPlayer]) -> MBSubstitutionImpact {
        let substitutionTimeline = match.timelineSecond(event: substitutionEvent)
        let beforePoints = MBMomentumEngine.points(wave: wave, fromTimelineSecond: substitutionTimeline - substitutionWindowSeconds, toTimelineSecond: substitutionTimeline)
        let afterPoints = MBMomentumEngine.points(wave: wave, fromTimelineSecond: substitutionTimeline + 1, toTimelineSecond: substitutionTimeline + substitutionWindowSeconds + 1)
        let beforeAverage = beforePoints.count >= substitutionMinimumPoints ? MBMomentumEngine.averageValue(points: beforePoints, forPrimarySide: substitutionEvent.isPrimarySide) : nil
        let afterAverage = afterPoints.count >= substitutionMinimumPoints ? MBMomentumEngine.averageValue(points: afterPoints, forPrimarySide: substitutionEvent.isPrimarySide) : nil
        let outgoingPlayer = players.first { player in
            return player.id == substitutionEvent.outgoingPlayerIdentifier
        }
        let incomingPlayer = players.first { player in
            return player.id == substitutionEvent.incomingPlayerIdentifier
        }
        return MBSubstitutionImpact(id: substitutionEvent.id, isPrimarySide: substitutionEvent.isPrimarySide, minuteLabel: match.minuteLabel(event: substitutionEvent), outgoingName: outgoingPlayer?.shortName, incomingName: incomingPlayer?.shortName, beforeAverage: beforeAverage, afterAverage: afterAverage)
    }

    private static func stints(match: MBMatch, wave: [MBWavePoint], substitutionEvents: [MBMatchEvent]) -> [MBPlayerStint] {
        if (match.isClubMatch == false) {
            return []
        }
        let primarySubstitutions = substitutionEvents.filter { substitutionEvent in
            return substitutionEvent.isPrimarySide
        }
        var openedStints: [String: Int] = [:]
        match.startingPlayerIdentifiers.forEach { playerIdentifier in
            openedStints[playerIdentifier] = 0
        }
        var closedStints: [MBPlayerStint] = []
        walkSubstitutions(match: match, wave: wave, remainingSubstitutions: primarySubstitutions[...], openedStints: &openedStints, closedStints: &closedStints)
        let finalWhistle = max(match.totalPlayedSeconds, 60)
        openedStints.forEach { playerIdentifier, enteredSecond in
            closedStints.append(makeStint(wave: wave, playerIdentifier: playerIdentifier, enteredSecond: enteredSecond, leftSecond: finalWhistle))
        }
        return closedStints
    }

    private static func walkSubstitutions(match: MBMatch, wave: [MBWavePoint], remainingSubstitutions: ArraySlice<MBMatchEvent>, openedStints: inout [String: Int], closedStints: inout [MBPlayerStint]) {
        guard let substitutionEvent = remainingSubstitutions.first else {
            return
        }
        let substitutionTimeline = match.timelineSecond(event: substitutionEvent)
        if let outgoingIdentifier = substitutionEvent.outgoingPlayerIdentifier, let enteredSecond = openedStints[outgoingIdentifier] {
            closedStints.append(makeStint(wave: wave, playerIdentifier: outgoingIdentifier, enteredSecond: enteredSecond, leftSecond: substitutionTimeline))
            openedStints[outgoingIdentifier] = nil
        }
        if let incomingIdentifier = substitutionEvent.incomingPlayerIdentifier, openedStints[incomingIdentifier] == nil {
            openedStints[incomingIdentifier] = substitutionTimeline
        }
        walkSubstitutions(match: match, wave: wave, remainingSubstitutions: remainingSubstitutions.dropFirst(), openedStints: &openedStints, closedStints: &closedStints)
    }

    private static func makeStint(wave: [MBWavePoint], playerIdentifier: String, enteredSecond: Int, leftSecond: Int) -> MBPlayerStint {
        let stintPoints = MBMomentumEngine.points(wave: wave, fromTimelineSecond: enteredSecond, toTimelineSecond: leftSecond)
        return MBPlayerStint(playerIdentifier: playerIdentifier, enteredTimelineSecond: enteredSecond, leftTimelineSecond: leftSecond, averageMomentum: MBMomentumEngine.averageValue(points: stintPoints, forPrimarySide: true))
    }
}
