
import Foundation

struct MBWavePoint: Hashable {
    let timelineSecond: Int
    let nominalSecond: Int
    let value: Double
}

struct MBPressureImpulse {
    let timelineSecond: Int
    let signedWeight: Double
}

struct MBMomentumEngine {
    static let saturationPressure = 6.5
    static let samplingStepSeconds = 15
    static let liveSamplingStepSeconds = 10
    static let forgottenAfterMemorySpans = 6.0

    static func impulses(match: MBMatch) -> [MBPressureImpulse] {
        var collectedImpulses: [MBPressureImpulse] = []
        gatherImpulses(match: match, remainingEvents: match.events[...], collectedImpulses: &collectedImpulses)
        return collectedImpulses.sorted { firstImpulse, secondImpulse in
            return firstImpulse.timelineSecond < secondImpulse.timelineSecond
        }
    }

    private static func gatherImpulses(match: MBMatch, remainingEvents: ArraySlice<MBMatchEvent>, collectedImpulses: inout [MBPressureImpulse]) {
        guard let matchEvent = remainingEvents.first else {
            return
        }
        let eventKind = matchEvent.kind
        if (eventKind.isPressureMoment) {
            let direction = matchEvent.favoursPrimarySide ? 1.0 : -1.0
            collectedImpulses.append(MBPressureImpulse(timelineSecond: match.timelineSecond(event: matchEvent), signedWeight: direction * eventKind.pressureWeight))
        }
        gatherImpulses(match: match, remainingEvents: remainingEvents.dropFirst(), collectedImpulses: &collectedImpulses)
    }

    static func momentum(timelineSecond: Int, impulses: [MBPressureImpulse], memoryMinutes: Int) -> Double {
        let memorySeconds = Double(memoryMinutes * 60)
        let rawPressure = accumulatePressure(timelineSecond: timelineSecond, remainingImpulses: impulses[...], memorySeconds: memorySeconds, runningPressure: 0)
        return tanh(rawPressure / saturationPressure)
    }

    private static func accumulatePressure(timelineSecond: Int, remainingImpulses: ArraySlice<MBPressureImpulse>, memorySeconds: Double, runningPressure: Double) -> Double {
        guard let impulse = remainingImpulses.first, impulse.timelineSecond <= timelineSecond else {
            return runningPressure
        }
        let impulseAge = Double(timelineSecond - impulse.timelineSecond)
        var updatedPressure = runningPressure
        if (impulseAge < memorySeconds * forgottenAfterMemorySpans) {
            updatedPressure += impulse.signedWeight * exp(-impulseAge / memorySeconds)
        }
        return accumulatePressure(timelineSecond: timelineSecond, remainingImpulses: remainingImpulses.dropFirst(), memorySeconds: memorySeconds, runningPressure: updatedPressure)
    }

    static func wave(match: MBMatch, memoryMinutes: Int, fromTimelineSecond: Int = 0, toTimelineSecond: Int? = nil, stepSeconds: Int = MBMomentumEngine.samplingStepSeconds) -> [MBWavePoint] {
        let matchImpulses = impulses(match: match)
        let lastTimelineSecond = toTimelineSecond ?? max(match.totalPlayedSeconds, match.format.nominalMatchSeconds)
        var sampledPoints: [MBWavePoint] = []
        sampleWave(match: match, timelineSecond: max(0, fromTimelineSecond), lastTimelineSecond: lastTimelineSecond, stepSeconds: stepSeconds, impulses: matchImpulses, memoryMinutes: memoryMinutes, sampledPoints: &sampledPoints)
        return sampledPoints
    }

    private static func sampleWave(match: MBMatch, timelineSecond: Int, lastTimelineSecond: Int, stepSeconds: Int, impulses: [MBPressureImpulse], memoryMinutes: Int, sampledPoints: inout [MBWavePoint]) {
        let clampedSecond = min(timelineSecond, lastTimelineSecond)
        let pointValue = momentum(timelineSecond: clampedSecond, impulses: impulses, memoryMinutes: memoryMinutes)
        sampledPoints.append(MBWavePoint(timelineSecond: clampedSecond, nominalSecond: match.nominalSecond(timelineSecond: clampedSecond), value: pointValue))
        if (clampedSecond >= lastTimelineSecond) {
            return
        }
        sampleWave(match: match, timelineSecond: timelineSecond + stepSeconds, lastTimelineSecond: lastTimelineSecond, stepSeconds: stepSeconds, impulses: impulses, memoryMinutes: memoryMinutes, sampledPoints: &sampledPoints)
    }

    static func averageValue(points: ArraySlice<MBWavePoint>, forPrimarySide: Bool) -> Double? {
        if (points.isEmpty) {
            return nil
        }
        let summedValue = sumValues(points: points, runningTotal: 0)
        let primaryAverage = summedValue / Double(points.count)
        return forPrimarySide ? primaryAverage : -primaryAverage
    }

    private static func sumValues(points: ArraySlice<MBWavePoint>, runningTotal: Double) -> Double {
        guard let wavePoint = points.first else {
            return runningTotal
        }
        return sumValues(points: points.dropFirst(), runningTotal: runningTotal + wavePoint.value)
    }

    static func points(wave: [MBWavePoint], fromTimelineSecond: Int, toTimelineSecond: Int) -> ArraySlice<MBWavePoint> {
        let windowPoints = wave.filter { wavePoint in
            return wavePoint.timelineSecond >= fromTimelineSecond && wavePoint.timelineSecond < toTimelineSecond
        }
        return windowPoints[...]
    }
}
