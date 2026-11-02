
import SwiftUI

struct MBWaveAreaShape: Shape {
    let wavePoints: [MBWavePoint]
    let firstTimelineSecond: Int
    let lastTimelineSecond: Int
    let closesToBaseline: Bool
    var amplitudeShare: CGFloat = 0.92

    func path(in rect: CGRect) -> Path {
        var wavePath = Path()
        guard let firstPoint = wavePoints.first, wavePoints.count > 1 else {
            return wavePath
        }
        let firstLocation = location(point: firstPoint, rect: rect)
        if (closesToBaseline) {
            wavePath.move(to: CGPoint(x: firstLocation.x, y: rect.midY))
            wavePath.addLine(to: firstLocation)
        } else {
            wavePath.move(to: firstLocation)
        }
        traceCurve(wavePath: &wavePath, previousLocation: firstLocation, remainingPoints: wavePoints.dropFirst(), rect: rect)
        if (closesToBaseline) {
            let lastLocation = location(point: wavePoints[wavePoints.count - 1], rect: rect)
            wavePath.addLine(to: CGPoint(x: lastLocation.x, y: rect.midY))
            wavePath.closeSubpath()
        }
        return wavePath
    }

    private func traceCurve(wavePath: inout Path, previousLocation: CGPoint, remainingPoints: ArraySlice<MBWavePoint>, rect: CGRect) {
        guard let wavePoint = remainingPoints.first else {
            wavePath.addLine(to: previousLocation)
            return
        }
        let currentLocation = location(point: wavePoint, rect: rect)
        let midwayLocation = CGPoint(x: (previousLocation.x + currentLocation.x) / 2, y: (previousLocation.y + currentLocation.y) / 2)
        wavePath.addQuadCurve(to: midwayLocation, control: previousLocation)
        traceCurve(wavePath: &wavePath, previousLocation: currentLocation, remainingPoints: remainingPoints.dropFirst(), rect: rect)
    }

    private func location(point: MBWavePoint, rect: CGRect) -> CGPoint {
        let timelineSpan = max(1, lastTimelineSecond - firstTimelineSecond)
        let horizontalShare = CGFloat(point.timelineSecond - firstTimelineSecond) / CGFloat(timelineSpan)
        let verticalReach = rect.height / 2 * amplitudeShare
        return CGPoint(x: rect.minX + horizontalShare * rect.width, y: rect.midY - CGFloat(point.value) * verticalReach)
    }
}

struct MBWaveChart: View {
    let wavePoints: [MBWavePoint]
    let firstTimelineSecond: Int
    let lastTimelineSecond: Int
    let primaryColor: Color
    let rivalColor: Color
    var lineWidth: CGFloat = 2
    var showsBaseline = true

    var body: some View {
        ZStack {
            if (showsBaseline) {
                Rectangle()
                    .fill(MBColors.ink.opacity(0.35))
                    .frame(height: 1.5)
            }
            MBWaveAreaShape(wavePoints: wavePoints, firstTimelineSecond: firstTimelineSecond, lastTimelineSecond: lastTimelineSecond, closesToBaseline: true)
                .fill(primaryColor.opacity(0.85))
                .mask(halfMask(keepsUpperHalf: true))
            MBWaveAreaShape(wavePoints: wavePoints, firstTimelineSecond: firstTimelineSecond, lastTimelineSecond: lastTimelineSecond, closesToBaseline: true)
                .fill(rivalColor.opacity(0.85))
                .mask(halfMask(keepsUpperHalf: false))
            MBWaveAreaShape(wavePoints: wavePoints, firstTimelineSecond: firstTimelineSecond, lastTimelineSecond: lastTimelineSecond, closesToBaseline: false)
                .stroke(MBColors.ink, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
        }
    }

    private func halfMask(keepsUpperHalf: Bool) -> some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.black.opacity(keepsUpperHalf ? 1 : 0))
            Rectangle()
                .fill(Color.black.opacity(keepsUpperHalf ? 0 : 1))
        }
    }
}

struct MBWaveSparkline: View {
    let match: MBMatch
    let memoryMinutes: Int

    var body: some View {
        let sparkWave = MBMomentumEngine.wave(match: match, memoryMinutes: memoryMinutes, toTimelineSecond: max(match.totalPlayedSeconds, 60), stepSeconds: 45)
        return MBWaveChart(wavePoints: sparkWave, firstTimelineSecond: 0, lastTimelineSecond: max(match.totalPlayedSeconds, 60), primaryColor: match.primarySwatch.strongColor, rivalColor: match.rivalSwatch.strongColor, lineWidth: 1.4)
    }
}
