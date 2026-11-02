
import SwiftUI

struct MBLivePitch: View {
    @EnvironmentObject private var ledger: MBLedger
    @EnvironmentObject private var liveSession: MBLiveSession
    let onMatchArchived: (String) -> Void

    @State private var isSubstitutionSheetPresented = false
    @State private var isEndDialogPresented = false
    @State private var isEmptyMatchAlertPresented = false
    @State private var pendingEmptyMatch: MBMatch?
    @State private var tickerDragOffset: CGFloat = 0
    @State private var tickerHint: String?
    @State private var goalBannerTeamName: String?
    @State private var lastKnownInitiativeOwner = 0

    static let dividerTravel = 0.15
    static let liveWindowSeconds = 720
    private let waveBandHeight: CGFloat = 58
    private let compactPadThreshold: CGFloat = 150

    var body: some View {
        TimelineView(.periodic(from: Date(), by: 1)) { timelineContext in
            pitchContent(now: timelineContext.date)
        }
        .sheet(isPresented: $isSubstitutionSheetPresented) {
            MBSubstitutionSheet(onConfirm: logPrimarySubstitution)
                .presentationDetents([.large])
        }
        .confirmationDialog(MBTexts.liveEndDialogTitle, isPresented: $isEndDialogPresented, titleVisibility: .visible) {
            Button(MBTexts.liveEndDialogFinish) {
                finishMatch()
            }
            Button(MBTexts.liveEndDialogDiscard, role: .destructive) {
                discardMatch()
            }
            Button(MBTexts.actionCancel, role: .cancel) {
                MBHaptics.tick()
            }
        }
        .alert(MBTexts.liveEmptyAlertTitle, isPresented: $isEmptyMatchAlertPresented) {
            Button(MBTexts.liveEmptyAlertKeep) {
                keepEmptyMatch()
            }
            Button(MBTexts.liveEmptyAlertDiscard, role: .destructive) {
                discardMatch()
            }
        } message: {
            Text(MBTexts.liveEmptyAlertMessage)
        }
    }

    private func pitchContent(now: Date) -> some View {
        let initiativeOwner = currentInitiativeOwner(now: now)
        return VStack(spacing: 10) {
            scoreboard(now: now)
            tickerStrip(now: now)
            GeometryReader { pitchGeometry in
                padStack(pitchSize: pitchGeometry.size, now: now)
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 6)
        .padding(.bottom, 96)
        .mbReadableWidth()
        .onChange(of: initiativeOwner) { newOwner in
            reactToInitiative(newOwner: newOwner)
        }
    }

    private func scoreboard(now: Date) -> some View {
        let liveMatch = liveSession.match
        let primarySwatch = liveMatch?.primarySwatch ?? MBColors.teamSwatches[0]
        let rivalSwatch = liveMatch?.rivalSwatch ?? MBColors.teamSwatches[1]
        return VStack(spacing: 10) {
            HStack(alignment: .center, spacing: 8) {
                scoreColumn(teamName: liveMatch?.primaryTeamName ?? "", goals: liveMatch?.primaryGoals ?? 0, swatch: primarySwatch)
                VStack(spacing: 2) {
                    Text(liveSession.clockLabel(now: now))
                        .font(MBTypography.scoreboard(30))
                        .foregroundColor(MBColors.ink)
                        .contentTransition(.numericText())
                    HStack(spacing: 4) {
                        if (liveSession.isInAddedTime(now: now)) {
                            MBTagText(text: MBTexts.liveAddedTime, color: MBColors.alarmInk, size: 10)
                        }
                        MBTagText(text: phaseCaption, color: liveSession.isClockRunning ? MBColors.grassInk : MBColors.inkSoft, size: 10)
                    }
                }
                .frame(minWidth: 110)
                scoreColumn(teamName: liveMatch?.rivalTeamName ?? "", goals: liveMatch?.rivalGoals ?? 0, swatch: rivalSwatch)
            }
            controlRow(now: now)
        }
        .padding(12)
        .mbSticker(fill: MBColors.card, cornerRadius: 22)
    }

    private func scoreColumn(teamName: String, goals: Int, swatch: MBTeamSwatch) -> some View {
        VStack(spacing: 4) {
            Text("\(goals)")
                .font(MBTypography.scoreboard(34))
                .foregroundColor(swatch.strongColor)
                .contentTransition(.numericText())
            Text(teamName)
                .font(MBTypography.tag(11))
                .foregroundColor(MBColors.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }

    private var phaseCaption: String {
        guard let liveMatch = liveSession.match else {
            return ""
        }
        let periodName = liveMatch.format.periodTitle(periodIndex: liveSession.currentPeriodIndex)
        if (liveSession.phaseIdentifier == MBLivePhase.awaitingKickoff) {
            return MBTexts.liveWaitingCaption(periodName: periodName)
        } else if (liveSession.phaseIdentifier == MBLivePhase.paused) {
            return MBTexts.livePausedCaption(periodName: periodName)
        }
        return periodName
    }

    private func controlRow(now: Date) -> some View {
        HStack(spacing: 10) {
            if (liveSession.phaseIdentifier == MBLivePhase.awaitingKickoff) {
                Button(liveSession.currentPeriodIndex == 0 ? MBTexts.liveKickOff : MBTexts.liveStartPeriod) {
                    MBHaptics.whistle()
                    liveSession.kickOff(now: Date())
                }
                .buttonStyle(MBStickerButtonStyle(fillColor: MBColors.grass, textColor: MBColors.onStrong, verticalPadding: 11))
            } else if (liveSession.phaseIdentifier == MBLivePhase.running) {
                Button(MBTexts.livePause) {
                    MBHaptics.tick()
                    liveSession.pause(now: Date())
                }
                .buttonStyle(MBStickerButtonStyle(fillColor: MBColors.card, verticalPadding: 11))
                periodEndButton
            } else {
                Button(MBTexts.liveResume) {
                    MBHaptics.tick()
                    liveSession.resume(now: Date())
                }
                .buttonStyle(MBStickerButtonStyle(fillColor: MBColors.grass, textColor: MBColors.onStrong, verticalPadding: 11))
                periodEndButton
            }
            Button {
                MBHaptics.tick()
                isEndDialogPresented = true
            } label: {
                Image(systemName: MBTexts.symbolMore)
            }
            .buttonStyle(MBStickerButtonStyle(fillColor: MBColors.paperDeep, verticalPadding: 11, expandsHorizontally: false))
        }
    }

    private var periodEndButton: some View {
        Button(liveSession.isFinalPeriod ? MBTexts.liveFullTime : MBTexts.liveHalfTime) {
            if (liveSession.isFinalPeriod) {
                finishMatch()
            } else {
                MBHaptics.whistle()
                _ = liveSession.closePeriod(now: Date())
            }
        }
        .buttonStyle(MBStickerButtonStyle(fillColor: MBColors.accent, verticalPadding: 11))
    }

    private func tickerStrip(now: Date) -> some View {
        let lastEvent = liveSession.lastPressureOrSubstitutionEvent
        return HStack(spacing: 10) {
            if let tickerHint = tickerHint {
                Text(MBTexts.emojiWarning)
                Text(tickerHint)
                    .font(MBTypography.strong(13))
                    .foregroundColor(MBColors.alarmInk)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer(minLength: 0)
            } else if let lastEvent = lastEvent, let liveMatch = liveSession.match {
                Text(lastEvent.kind.emoji)
                Text(MBTexts.tickerLine(kindTitle: lastEvent.kind.title, teamName: lastEvent.isPrimarySide ? liveMatch.primaryTeamName : liveMatch.rivalTeamName, minuteLabel: liveMatch.minuteLabel(event: lastEvent)))
                    .font(MBTypography.strong(13))
                    .foregroundColor(MBColors.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer(minLength: 0)
                MBTagText(text: MBTexts.tickerSwipeHint, size: 9)
            } else {
                Text(MBTexts.emojiPointer)
                Text(MBTexts.tickerEmpty)
                    .font(MBTypography.body(13))
                    .foregroundColor(MBColors.inkSoft)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .mbSticker(fill: tickerHint == nil ? MBColors.paperDeep : MBColors.alarmPale, cornerRadius: 16, depth: 2)
        .offset(x: tickerDragOffset)
        .opacity(Double(1 - min(abs(tickerDragOffset) / 220, 0.6)))
        .gesture(tickerGesture)
    }

    private var tickerGesture: some Gesture {
        DragGesture(minimumDistance: 12)
            .onChanged { dragValue in
                if (liveSession.lastPressureOrSubstitutionEvent != nil) {
                    tickerDragOffset = dragValue.translation.width
                }
            }
            .onEnded { dragValue in
                if (abs(dragValue.translation.width) > 90) {
                    undoLastMoment()
                }
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    tickerDragOffset = 0
                }
            }
    }

    private func padStack(pitchSize: CGSize, now: Date) -> some View {
        let liveMatch = liveSession.match
        let momentumNow = currentMomentum(now: now)
        let padsHeight = max(0, pitchSize.height - waveBandHeight - 16)
        let primaryShare = 0.5 + momentumNow * MBLivePitch.dividerTravel
        let primaryHeight = padsHeight * CGFloat(primaryShare)
        let rivalHeight = padsHeight - primaryHeight
        let usesCompactPads = min(primaryHeight, rivalHeight) < compactPadThreshold
        return ZStack {
            VStack(spacing: 8) {
                MBTeamPad(teamName: liveMatch?.rivalTeamName ?? "", swatch: liveMatch?.rivalSwatch ?? MBColors.teamSwatches[1], goals: liveMatch?.rivalGoals ?? 0, isPrimarySide: false, compactLayout: usesCompactPads, onMoment: logMoment, onSubstitution: requestSubstitution)
                    .frame(height: rivalHeight)
                waveBand(now: now, momentumNow: momentumNow)
                    .frame(height: waveBandHeight)
                MBTeamPad(teamName: liveMatch?.primaryTeamName ?? "", swatch: liveMatch?.primarySwatch ?? MBColors.teamSwatches[0], goals: liveMatch?.primaryGoals ?? 0, isPrimarySide: true, compactLayout: usesCompactPads, onMoment: logMoment, onSubstitution: requestSubstitution)
                    .frame(height: primaryHeight)
            }
            .animation(.spring(response: 0.9, dampingFraction: 0.78), value: primaryShare)
            if let goalBannerTeamName = goalBannerTeamName {
                goalBanner(teamName: goalBannerTeamName)
                    .transition(.scale(scale: 0.4).combined(with: .opacity))
            }
        }
    }

    private func waveBand(now: Date, momentumNow: Double) -> some View {
        let nowTimeline = liveSession.timelineSecond(now: now)
        let windowStart = max(0, nowTimeline - MBLivePitch.liveWindowSeconds)
        let liveWave = liveWavePoints(windowStart: windowStart, nowTimeline: nowTimeline)
        let liveMatch = liveSession.match
        return HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 0) {
                MBTagText(text: MBTexts.liveWaveCaption, size: 9)
                MBMomentumNumber(value: momentumNow, size: 18)
            }
            .frame(width: 70, alignment: .leading)
            MBWaveChart(wavePoints: liveWave, firstTimelineSecond: windowStart, lastTimelineSecond: max(nowTimeline, windowStart + 60), primaryColor: liveMatch?.primarySwatch.strongColor ?? MBColors.ink, rivalColor: liveMatch?.rivalSwatch.strongColor ?? MBColors.ink, lineWidth: 1.6)
                .padding(.vertical, 4)
        }
        .padding(.horizontal, 12)
        .mbSticker(fill: MBColors.card, cornerRadius: 18, depth: 3)
    }

    private func goalBanner(teamName: String) -> some View {
        VStack(spacing: 2) {
            Text(MBTexts.liveGoalBanner)
                .font(MBTypography.poster(54))
                .foregroundColor(MBColors.ink)
            Text(teamName.uppercased())
                .font(MBTypography.tag(13))
                .foregroundColor(MBColors.ink)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 14)
        .mbSticker(fill: MBColors.accent, cornerRadius: 24, depth: 6)
        .rotationEffect(.degrees(-6))
        .allowsHitTesting(false)
    }

    private func liveWavePoints(windowStart: Int, nowTimeline: Int) -> [MBWavePoint] {
        guard let liveMatch = liveSession.match, nowTimeline > windowStart else {
            return []
        }
        return MBMomentumEngine.wave(match: liveMatch, memoryMinutes: ledger.memoryMinutes, fromTimelineSecond: windowStart, toTimelineSecond: nowTimeline, stepSeconds: MBMomentumEngine.liveSamplingStepSeconds)
    }

    private func currentMomentum(now: Date) -> Double {
        guard let liveMatch = liveSession.match else {
            return 0
        }
        let liveImpulses = MBMomentumEngine.impulses(match: liveMatch)
        return MBMomentumEngine.momentum(timelineSecond: liveSession.timelineSecond(now: now), impulses: liveImpulses, memoryMinutes: ledger.memoryMinutes)
    }

    private func currentInitiativeOwner(now: Date) -> Int {
        let momentumNow = currentMomentum(now: now)
        if (momentumNow > MBMatchReport.initiativeHysteresis) {
            return 1
        } else if (momentumNow < -MBMatchReport.initiativeHysteresis) {
            return -1
        }
        return 0
    }

    private func reactToInitiative(newOwner: Int) {
        if (newOwner == 0) {
            return
        }
        if (lastKnownInitiativeOwner != 0 && lastKnownInitiativeOwner != newOwner) {
            MBHaptics.initiativeFlip()
        }
        lastKnownInitiativeOwner = newOwner
    }

    private func logMoment(eventKind: MBEventKind, isPrimarySide: Bool) -> Bool {
        let accepted = liveSession.log(kind: eventKind, isPrimarySide: isPrimarySide, now: Date())
        if (accepted == false) {
            MBHaptics.rejected()
            flashHint(MBTexts.tickerClockStopped)
            return false
        }
        if (eventKind.identifier == MBEventKind.goal.identifier) {
            MBHaptics.goal()
            let scoringName = isPrimarySide ? liveSession.match?.primaryTeamName : liveSession.match?.rivalTeamName
            withAnimation(.spring(response: 0.4, dampingFraction: 0.55)) {
                goalBannerTeamName = scoringName ?? ""
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                withAnimation(.easeIn(duration: 0.25)) {
                    goalBannerTeamName = nil
                }
            }
        } else {
            MBHaptics.momentLogged(weight: eventKind.pressureWeight)
        }
        return true
    }

    private func requestSubstitution(isPrimarySide: Bool) {
        guard let liveMatch = liveSession.match else {
            return
        }
        if (isPrimarySide && liveMatch.isClubMatch && ledger.players.isEmpty == false) {
            MBHaptics.tick()
            isSubstitutionSheetPresented = true
            return
        }
        if (liveSession.logSubstitution(isPrimarySide: isPrimarySide, outgoingPlayerIdentifier: nil, incomingPlayerIdentifier: nil, now: Date())) {
            MBHaptics.confirmed()
        } else {
            MBHaptics.rejected()
        }
    }

    private func logPrimarySubstitution(outgoingPlayerIdentifier: String?, incomingPlayerIdentifier: String?) {
        if (liveSession.logSubstitution(isPrimarySide: true, outgoingPlayerIdentifier: outgoingPlayerIdentifier, incomingPlayerIdentifier: incomingPlayerIdentifier, now: Date())) {
            MBHaptics.confirmed()
        }
    }

    private func undoLastMoment() {
        if (liveSession.undoLastEvent() != nil) {
            MBHaptics.initiativeFlip()
        } else {
            MBHaptics.rejected()
        }
    }

    private func flashHint(_ hintText: String) {
        withAnimation(.easeOut(duration: 0.2)) {
            tickerHint = hintText
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeIn(duration: 0.2)) {
                tickerHint = nil
            }
        }
    }

    private func finishMatch() {
        guard let finishedMatch = liveSession.finalWhistle(now: Date()) else {
            return
        }
        if (finishedMatch.pressureMomentCount == 0) {
            MBHaptics.rejected()
            pendingEmptyMatch = finishedMatch
            isEmptyMatchAlertPresented = true
            return
        }
        archive(finishedMatch: finishedMatch)
    }

    private func keepEmptyMatch() {
        if let pendingEmptyMatch = pendingEmptyMatch {
            archive(finishedMatch: pendingEmptyMatch)
        }
        pendingEmptyMatch = nil
    }

    private func archive(finishedMatch: MBMatch) {
        MBHaptics.whistle()
        ledger.archiveMatch(finishedMatch)
        liveSession.discard()
        onMatchArchived(finishedMatch.id)
    }

    private func discardMatch() {
        MBHaptics.rejected()
        pendingEmptyMatch = nil
        liveSession.discard()
    }
}
