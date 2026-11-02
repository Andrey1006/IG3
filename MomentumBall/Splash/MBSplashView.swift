
import SwiftUI

struct MBSplashStep {
    let startSecond: Double
    let perform: () -> Void
}

struct MBSplashWaveShape: Shape {
    var wavePhase: Double
    var waveAmplitude: CGFloat
    var closesToBaseline: Bool
    private let sampleCount = 72

    func path(in rect: CGRect) -> Path {
        var wavePath = Path()
        wavePath.move(to: CGPoint(x: rect.minX, y: waveHeight(rect: rect, sampleIndex: 0)))
        appendWaveSample(path: &wavePath, rect: rect, sampleIndex: 1)
        if (closesToBaseline) {
            wavePath.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            wavePath.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
            wavePath.closeSubpath()
        }
        return wavePath
    }

    private func appendWaveSample(path: inout Path, rect: CGRect, sampleIndex: Int) {
        if (sampleIndex > sampleCount) {
            return
        }
        let sampleX = rect.minX + rect.width * CGFloat(sampleIndex) / CGFloat(sampleCount)
        path.addLine(to: CGPoint(x: sampleX, y: waveHeight(rect: rect, sampleIndex: sampleIndex)))
        appendWaveSample(path: &path, rect: rect, sampleIndex: sampleIndex + 1)
    }

    private func waveHeight(rect: CGRect, sampleIndex: Int) -> CGFloat {
        let sampleProgress = Double(sampleIndex) / Double(sampleCount)
        let leadingRipple = sin(sampleProgress * Double.pi * 2.8 + wavePhase) * 0.64
        let trailingRipple = sin(sampleProgress * Double.pi * 6.2 - wavePhase * 1.7) * 0.26
        let edgeEnvelope = 0.3 + 0.7 * sin(sampleProgress * Double.pi)
        let momentumValue = (leadingRipple + trailingRipple) * edgeEnvelope
        return rect.midY - CGFloat(momentumValue) * rect.height / 2 * waveAmplitude
    }
}

struct MBSplashHalfShape: Shape {
    let keepsUpperHalf: Bool

    func path(in rect: CGRect) -> Path {
        if (keepsUpperHalf) {
            return Path(CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height / 2))
        } else {
            return Path(CGRect(x: rect.minX, y: rect.midY, width: rect.width, height: rect.height / 2))
        }
    }
}

struct MBSplashView: View {
    var onFinish: () -> Void = {}

    private static let totalDurationSeconds = 3.0
    private static let ballDiameter: CGFloat = 112
    private static let burstOrbitRadius: CGFloat = 132
    private static let burstIntervalSeconds = 0.16
    private static let pulseRingCount = 3

    @State private var hasStartedSequence = false
    @State private var pitchMarkingsVisible = false
    @State private var ballHasDropped = false
    @State private var ballHasLanded = false
    @State private var ballSpinDegrees: Double = 0
    @State private var ballSquashScale: CGFloat = 1
    @State private var pulseRingsExpanded = false
    @State private var waveRevealProgress: CGFloat = 0
    @State private var revealedBurstCount = 0
    @State private var taglineVisible = false
    @State private var countdownSeconds = 3
    @State private var countdownProgress: CGFloat = 0
    @State private var isLeavingSplash = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                ballStage(stageWidth: geometry.size.width)
                    .frame(height: 330)
                waveBand(bandWidth: max(geometry.size.width - 48, 0))
                    .frame(height: 118)
                taglineBlock
                    .padding(.top, 26)
                Spacer(minLength: 0)
                countdownBlock
                    .padding(.horizontal, 40)
                    .padding(.bottom, 28)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .opacity(isLeavingSplash ? 0 : 1)
            .scaleEffect(isLeavingSplash ? 1.08 : 1)
        }
        .background(MBColors.splashBackdrop.ignoresSafeArea())
        .onAppear(perform: startSplashSequence)
    }

    private func ballStage(stageWidth: CGFloat) -> some View {
        ZStack {
            Rectangle()
                .fill(MBColors.splashPitchLine.opacity(0.45))
                .frame(width: stageWidth * (pitchMarkingsVisible ? 1 : 0), height: 2)
            Circle()
                .stroke(MBColors.splashPitchLine.opacity(0.45), lineWidth: 2)
                .frame(width: 250, height: 250)
                .scaleEffect(pitchMarkingsVisible ? 1 : 0.35)
                .opacity(pitchMarkingsVisible ? 1 : 0)
            ForEach(0..<MBSplashView.pulseRingCount, id: \.self) { ringIndex in
                pulseRing(ringIndex: ringIndex)
            }
            ForEach(MBTexts.splashBurstEmojis.indices, id: \.self) { burstIndex in
                burstChip(burstIndex: burstIndex)
            }
            ballSticker
        }
    }

    private var ballSticker: some View {
        Text(MBTexts.splashBallEmoji)
            .font(.system(size: 62))
            .rotationEffect(.degrees(ballSpinDegrees))
            .frame(width: MBSplashView.ballDiameter, height: MBSplashView.ballDiameter)
            .mbSticker(fill: MBColors.splashBall, cornerRadius: MBSplashView.ballDiameter / 2, depth: 5)
            .scaleEffect(x: 2 - ballSquashScale, y: ballSquashScale, anchor: .bottom)
            .offset(y: ballHasDropped ? 0 : -520)
    }

    private func pulseRing(ringIndex: Int) -> some View {
        let ringAnimation = Animation.easeOut(duration: 1.5).repeatForever(autoreverses: false).delay(Double(ringIndex) * 0.5)
        return Circle()
            .stroke(MBColors.splashPulse, lineWidth: 3)
            .frame(width: MBSplashView.ballDiameter, height: MBSplashView.ballDiameter)
            .scaleEffect(pulseRingsExpanded ? 2.7 : 1)
            .opacity(pulseRingsExpanded ? 0 : 0.85)
            .animation(ringAnimation, value: pulseRingsExpanded)
            .opacity(ballHasLanded ? 1 : 0)
    }

    private func burstChip(burstIndex: Int) -> some View {
        let isRevealed = burstIndex < revealedBurstCount
        let orbitAngle = (-90 + Double(burstIndex) * 360 / Double(MBTexts.splashBurstEmojis.count)) * Double.pi / 180
        let orbitDistance = isRevealed ? MBSplashView.burstOrbitRadius : MBSplashView.ballDiameter / 3
        return Text(MBTexts.splashBurstEmojis[burstIndex])
            .font(.system(size: 22))
            .frame(width: 48, height: 48)
            .mbSticker(fill: MBColors.card, cornerRadius: 24, depth: 3)
            .scaleEffect(isRevealed ? 1 : 0.2)
            .opacity(isRevealed ? 1 : 0)
            .offset(x: CGFloat(cos(orbitAngle)) * orbitDistance, y: CGFloat(sin(orbitAngle)) * orbitDistance)
    }

    private func waveBand(bandWidth: CGFloat) -> some View {
        TimelineView(.animation) { timelineContext in
            waveLayers(wavePhase: timelineContext.date.timeIntervalSinceReferenceDate * 2.4)
        }
        .frame(width: bandWidth)
        .mask(alignment: .leading) {
            Rectangle()
                .frame(width: bandWidth * waveRevealProgress)
        }
    }

    private func waveLayers(wavePhase: Double) -> some View {
        let waveStrokeStyle = StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
        return ZStack {
            MBSplashWaveShape(wavePhase: wavePhase, waveAmplitude: 0.92, closesToBaseline: true)
                .fill(MBColors.splashWaveUpper.opacity(0.85))
                .clipShape(MBSplashHalfShape(keepsUpperHalf: true))
            MBSplashWaveShape(wavePhase: wavePhase, waveAmplitude: 0.92, closesToBaseline: true)
                .fill(MBColors.splashWaveLower.opacity(0.85))
                .clipShape(MBSplashHalfShape(keepsUpperHalf: false))
            Rectangle()
                .fill(MBColors.ink.opacity(0.3))
                .frame(height: 1.5)
            MBSplashWaveShape(wavePhase: wavePhase, waveAmplitude: 0.92, closesToBaseline: false)
                .stroke(MBColors.ink, style: waveStrokeStyle)
        }
    }

    private var taglineBlock: some View {
        VStack(spacing: 10) {
            Text(MBTexts.splashTagline)
                .font(MBTypography.poster(40))
                .foregroundColor(MBColors.ink)
                .multilineTextAlignment(.center)
            Text(MBTexts.splashSubline)
                .font(MBTypography.body(15))
                .foregroundColor(MBColors.inkSoft)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
        .opacity(taglineVisible ? 1 : 0)
        .offset(y: taglineVisible ? 0 : 18)
    }

    private var countdownBlock: some View {
        let trackShape = Capsule(style: .continuous)
        return VStack(spacing: 10) {
            MBTagText(text: MBTexts.splashCountdown(seconds: countdownSeconds), color: MBColors.ink, size: 11)
                .contentTransition(.numericText())
            ZStack(alignment: .leading) {
                trackShape
                    .fill(MBColors.splashTrack)
                trackShape
                    .fill(MBColors.splashBall)
                    .scaleEffect(x: max(countdownProgress, 0.001), y: 1, anchor: .leading)
            }
            .frame(height: 14)
            .clipShape(trackShape)
            .overlay(trackShape.stroke(MBColors.outline, lineWidth: 2))
        }
        .frame(maxWidth: 320)
    }

    private func startSplashSequence() {
        if (hasStartedSequence) {
            return
        }
        hasStartedSequence = true
        let splashSteps = assembleSplashSteps()
        scheduleSplashSteps(remainingSteps: splashSteps[...])
    }

    private func assembleSplashSteps() -> [MBSplashStep] {
        var assembledSteps: [MBSplashStep] = []
        assembledSteps.append(MBSplashStep(startSecond: 0, perform: revealPitchMarkings))
        assembledSteps.append(MBSplashStep(startSecond: 0.15, perform: dropBall))
        assembledSteps.append(MBSplashStep(startSecond: 0.62, perform: landBall))
        assembledSteps.append(MBSplashStep(startSecond: 0.8, perform: releaseBallSquash))
        assembledSteps.append(MBSplashStep(startSecond: 0.75, perform: drawWave))
        appendBurstSteps(assembledSteps: &assembledSteps, burstIndex: 0)
        assembledSteps.append(MBSplashStep(startSecond: 1.0, perform: advanceCountdown))
        assembledSteps.append(MBSplashStep(startSecond: 1.35, perform: revealTagline))
        assembledSteps.append(MBSplashStep(startSecond: 2.0, perform: advanceCountdown))
        assembledSteps.append(MBSplashStep(startSecond: MBSplashView.totalDurationSeconds - 0.28, perform: leaveSplash))
        assembledSteps.append(MBSplashStep(startSecond: MBSplashView.totalDurationSeconds, perform: finishSplash))
        return assembledSteps
    }

    private func appendBurstSteps(assembledSteps: inout [MBSplashStep], burstIndex: Int) {
        if (burstIndex >= MBTexts.splashBurstEmojis.count) {
            return
        }
        assembledSteps.append(MBSplashStep(startSecond: 0.95 + Double(burstIndex) * MBSplashView.burstIntervalSeconds, perform: revealNextBurst))
        appendBurstSteps(assembledSteps: &assembledSteps, burstIndex: burstIndex + 1)
    }

    private func scheduleSplashSteps(remainingSteps: ArraySlice<MBSplashStep>) {
        guard let splashStep = remainingSteps.first else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + splashStep.startSecond) {
            splashStep.perform()
        }
        scheduleSplashSteps(remainingSteps: remainingSteps.dropFirst())
    }

    private func revealPitchMarkings() {
        withAnimation(.easeOut(duration: 0.55)) {
            pitchMarkingsVisible = true
        }
        withAnimation(.linear(duration: MBSplashView.totalDurationSeconds)) {
            countdownProgress = 1
        }
    }

    private func dropBall() {
        withAnimation(.easeIn(duration: 0.47)) {
            ballHasDropped = true
            ballSpinDegrees = 300
        }
    }

    private func landBall() {
        MBHaptics.tick()
        ballHasLanded = true
        pulseRingsExpanded = true
        withAnimation(.easeOut(duration: 0.12)) {
            ballSquashScale = 0.82
        }
    }

    private func releaseBallSquash() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.42)) {
            ballSquashScale = 1
            ballSpinDegrees = 360
        }
    }

    private func drawWave() {
        withAnimation(.easeInOut(duration: 1.3)) {
            waveRevealProgress = 1
        }
    }

    private func revealNextBurst() {
        MBHaptics.tick()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.55)) {
            revealedBurstCount += 1
        }
    }

    private func advanceCountdown() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            countdownSeconds = max(countdownSeconds - 1, 1)
        }
    }

    private func revealTagline() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
            taglineVisible = true
        }
    }

    private func leaveSplash() {
        withAnimation(.easeIn(duration: 0.28)) {
            isLeavingSplash = true
        }
    }

    private func finishSplash() {
        onFinish()
    }
}
