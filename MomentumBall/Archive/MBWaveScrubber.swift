
import SwiftUI

struct MBWaveScrubber: View {
    let report: MBMatchReport

    @State private var scrubIndex: Int?
    @State private var lastFeltIndex: Int?

    private let chartHeight: CGFloat = 190
    private let nearbyEventSeconds = 45

    private var lastTimelineSecond: Int {
        return max(report.wave.last?.timelineSecond ?? 60, 60)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            readout
            GeometryReader { chartGeometry in
                chartLayer(chartSize: chartGeometry.size)
            }
            .frame(height: chartHeight)
            HStack {
                MBTagText(text: MBTexts.minuteMark(minute: 0), size: 9)
                Spacer()
                MBTagText(text: MBTexts.scrubberAxisHint, size: 9)
                Spacer()
                MBTagText(text: report.match.minuteLabel(timelineSecond: lastTimelineSecond), size: 9)
            }
        }
        .padding(16)
        .mbSticker(fill: MBColors.card, cornerRadius: 24)
    }

    @ViewBuilder
    private var readout: some View {
        if let scrubIndex = scrubIndex, scrubIndex < report.wave.count {
            let wavePoint = report.wave[scrubIndex]
            HStack(alignment: .center, spacing: 12) {
                Text(report.match.minuteLabel(timelineSecond: wavePoint.timelineSecond))
                    .font(MBTypography.scoreboard(26))
                    .foregroundColor(MBColors.ink)
                    .frame(minWidth: 58, alignment: .leading)
                VStack(alignment: .leading, spacing: 2) {
                    Text(pressingCaption(value: wavePoint.value))
                        .font(MBTypography.strong(14))
                        .foregroundColor(MBColors.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(nearbyEventsLine(timelineSecond: wavePoint.timelineSecond))
                        .font(MBTypography.body(13))
                        .foregroundColor(MBColors.inkSoft)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                MBMomentumNumber(value: wavePoint.value, size: 20)
            }
            .frame(height: 44)
        } else {
            HStack(spacing: 10) {
                Text(MBTexts.emojiPointer)
                    .font(.system(size: 22))
                Text(MBTexts.scrubberIdle)
                    .font(MBTypography.body(14))
                    .foregroundColor(MBColors.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            .frame(height: 44)
        }
    }

    private func chartLayer(chartSize: CGSize) -> some View {
        ZStack(alignment: .topLeading) {
            sideLabels
            ForEach(Array(periodBoundaries.enumerated()), id: \.offset) { boundaryEntry in
                periodDivider(timelineSecond: boundaryEntry.element, chartSize: chartSize)
            }
            MBWaveChart(wavePoints: report.wave, firstTimelineSecond: 0, lastTimelineSecond: lastTimelineSecond, primaryColor: report.match.primarySwatch.strongColor, rivalColor: report.match.rivalSwatch.strongColor)
            ForEach(markerEvents) { markerEvent in
                eventMarker(markerEvent: markerEvent, chartSize: chartSize)
            }
            if let scrubIndex = scrubIndex, scrubIndex < report.wave.count {
                playhead(wavePoint: report.wave[scrubIndex], chartSize: chartSize)
            }
        }
        .frame(width: chartSize.width, height: chartSize.height)
        .contentShape(Rectangle())
        .gesture(scrubGesture(chartWidth: chartSize.width))
    }

    private var sideLabels: some View {
        VStack {
            HStack {
                MBTagText(text: MBTexts.scrubberSideLabel(teamName: report.match.primaryTeamName), color: report.match.primarySwatch.strongColor, size: 9)
                Spacer()
            }
            Spacer()
            HStack {
                MBTagText(text: MBTexts.scrubberSideLabel(teamName: report.match.rivalTeamName), color: report.match.rivalSwatch.strongColor, size: 9)
                Spacer()
            }
        }
        .allowsHitTesting(false)
    }

    private var periodBoundaries: [Int] {
        if (report.match.playedSecondsPerPeriod.count < 2) {
            return []
        }
        return (1..<report.match.playedSecondsPerPeriod.count).map { periodIndex in
            return report.match.periodStartTimelineSecond(periodIndex: periodIndex)
        }
    }

    private var markerEvents: [MBMatchEvent] {
        return report.match.events.filter { matchEvent in
            return matchEvent.kindIdentifier == MBEventKind.goal.identifier || matchEvent.kindIdentifier == MBEventKind.substitution.identifier
        }
    }

    private func horizontalPosition(timelineSecond: Int, chartWidth: CGFloat) -> CGFloat {
        return CGFloat(timelineSecond) / CGFloat(lastTimelineSecond) * chartWidth
    }

    private func verticalPosition(value: Double, chartHeight: CGFloat) -> CGFloat {
        return chartHeight / 2 - CGFloat(value) * chartHeight / 2 * 0.92
    }

    private func periodDivider(timelineSecond: Int, chartSize: CGSize) -> some View {
        let dividerX = horizontalPosition(timelineSecond: timelineSecond, chartWidth: chartSize.width)
        return Path { dividerPath in
            dividerPath.move(to: CGPoint(x: dividerX, y: 0))
            dividerPath.addLine(to: CGPoint(x: dividerX, y: chartSize.height))
        }
        .stroke(MBColors.ink.opacity(0.4), style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
    }

    private func eventMarker(markerEvent: MBMatchEvent, chartSize: CGSize) -> some View {
        let eventTimeline = report.match.timelineSecond(event: markerEvent)
        let markerX = horizontalPosition(timelineSecond: eventTimeline, chartWidth: chartSize.width)
        let isGoal = markerEvent.kindIdentifier == MBEventKind.goal.identifier
        let nearestValue = nearestPoint(timelineSecond: eventTimeline)?.value ?? 0
        let markerY = isGoal ? verticalPosition(value: nearestValue, chartHeight: chartSize.height) : (markerEvent.isPrimarySide ? 10 : chartSize.height - 10)
        return Text(markerEvent.kind.emoji)
            .font(.system(size: isGoal ? 17 : 11))
            .padding(isGoal ? 2 : 1)
            .background(Circle().fill(MBColors.card))
            .overlay(Circle().stroke(MBColors.outline, lineWidth: isGoal ? 1.5 : 1))
            .position(x: markerX, y: markerY)
            .allowsHitTesting(false)
    }

    private func playhead(wavePoint: MBWavePoint, chartSize: CGSize) -> some View {
        let headX = horizontalPosition(timelineSecond: wavePoint.timelineSecond, chartWidth: chartSize.width)
        let headY = verticalPosition(value: wavePoint.value, chartHeight: chartSize.height)
        return ZStack {
            Path { headPath in
                headPath.move(to: CGPoint(x: headX, y: 0))
                headPath.addLine(to: CGPoint(x: headX, y: chartSize.height))
            }
            .stroke(MBColors.ink, lineWidth: 2)
            Circle()
                .fill(MBColors.accent)
                .frame(width: 16, height: 16)
                .overlay(Circle().stroke(MBColors.outline, lineWidth: 2))
                .position(x: headX, y: headY)
        }
        .allowsHitTesting(false)
    }

    private func scrubGesture(chartWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { dragValue in
                moveScrub(locationX: dragValue.location.x, chartWidth: chartWidth)
            }
    }

    private func moveScrub(locationX: CGFloat, chartWidth: CGFloat) {
        if (report.wave.isEmpty || chartWidth <= 0) {
            return
        }
        let clampedShare = min(max(locationX / chartWidth, 0), 1)
        let targetTimeline = Int(clampedShare * CGFloat(lastTimelineSecond))
        let pointIndex = nearestIndex(timelineSecond: targetTimeline)
        if (pointIndex == scrubIndex) {
            return
        }
        feelPassage(fromIndex: lastFeltIndex, toIndex: pointIndex)
        lastFeltIndex = pointIndex
        scrubIndex = pointIndex
    }

    private func feelPassage(fromIndex: Int?, toIndex: Int) {
        guard let fromIndex = fromIndex else {
            MBHaptics.tick()
            return
        }
        let previousValue = report.wave[fromIndex].value
        let currentValue = report.wave[toIndex].value
        let lowerSecond = min(report.wave[fromIndex].timelineSecond, report.wave[toIndex].timelineSecond)
        let upperSecond = max(report.wave[fromIndex].timelineSecond, report.wave[toIndex].timelineSecond)
        let passedEvents = report.match.events.filter { matchEvent in
            let eventTimeline = report.match.timelineSecond(event: matchEvent)
            return eventTimeline > lowerSecond && eventTimeline <= upperSecond
        }
        let passedGoal = passedEvents.contains { matchEvent in
            return matchEvent.kindIdentifier == MBEventKind.goal.identifier
        }
        if (passedGoal) {
            MBHaptics.goal()
        } else if ((previousValue >= 0) != (currentValue >= 0)) {
            MBHaptics.initiativeFlip()
        } else if (passedEvents.isEmpty == false) {
            MBHaptics.tick()
        }
    }

    private func nearestIndex(timelineSecond: Int) -> Int {
        let stepSeconds = max(1, MBMomentumEngine.samplingStepSeconds)
        let estimatedIndex = Int((Double(timelineSecond) / Double(stepSeconds)).rounded())
        return min(max(estimatedIndex, 0), report.wave.count - 1)
    }

    private func nearestPoint(timelineSecond: Int) -> MBWavePoint? {
        if (report.wave.isEmpty) {
            return nil
        }
        return report.wave[nearestIndex(timelineSecond: timelineSecond)]
    }

    private func pressingCaption(value: Double) -> String {
        if (value > MBMatchReport.initiativeHysteresis) {
            return MBTexts.scrubberPressing(teamName: report.match.primaryTeamName)
        } else if (value < -MBMatchReport.initiativeHysteresis) {
            return MBTexts.scrubberPressing(teamName: report.match.rivalTeamName)
        }
        return MBTexts.scrubberBalanced
    }

    private func nearbyEventsLine(timelineSecond: Int) -> String {
        let nearbyEvents = report.match.events.filter { matchEvent in
            return abs(report.match.timelineSecond(event: matchEvent) - timelineSecond) <= nearbyEventSeconds
        }
        if (nearbyEvents.isEmpty) {
            return MBTexts.scrubberQuiet
        }
        return nearbyEvents.map { matchEvent in
            return matchEvent.kind.emoji
        }.joined(separator: " ")
    }
}
