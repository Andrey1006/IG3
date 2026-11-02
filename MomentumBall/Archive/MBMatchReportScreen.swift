
import SwiftUI

struct MBMatchReportScreen: View {
    @EnvironmentObject private var ledger: MBLedger
    @Environment(\.dismiss) private var dismiss
    let matchIdentifier: String

    @State private var isDeleteAlertPresented = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                topBar
                if let match = ledger.match(identifier: matchIdentifier) {
                    reportBody(report: MBMatchReport(match: match, memoryMinutes: ledger.memoryMinutes, players: ledger.players))
                } else {
                    MBEmptyState(artworkName: MBArtworkNames.emptyArchive, fallbackEmoji: MBTexts.emojiArchive, title: MBTexts.reportMissingTitle, message: MBTexts.reportMissingMessage)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 40)
            .mbReadableWidth()
        }
        .mbScreenBackground()
        .toolbar(.hidden, for: .tabBar)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .alert(MBTexts.reportDeleteAlertTitle, isPresented: $isDeleteAlertPresented) {
            Button(MBTexts.reportDeleteConfirm, role: .destructive) {
                deleteMatch()
            }
            Button(MBTexts.actionCancel, role: .cancel) {
                MBHaptics.tick()
            }
        } message: {
            Text(MBTexts.reportDeleteAlertMessage)
        }
    }

    private var topBar: some View {
        HStack {
            MBBackButton()
            Spacer()
            MBTagText(text: MBTexts.reportKicker)
            Spacer()
            Button {
                MBHaptics.tick()
                isDeleteAlertPresented = true
            } label: {
                Image(systemName: MBTexts.symbolTrash)
                    .font(.system(size: 15, weight: .black))
                    .foregroundColor(MBColors.alarmInk)
                    .frame(width: 42, height: 42)
                    .background(Circle().fill(MBColors.card))
                    .overlay(Circle().stroke(MBColors.outline, lineWidth: 2))
                    .background(Circle().fill(MBColors.hardShadow).offset(x: 3, y: 3))
            }
            .buttonStyle(MBCardPressStyle())
            .opacity(ledger.match(identifier: matchIdentifier) == nil ? 0 : 1)
        }
    }

    private func reportBody(report: MBMatchReport) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            heroCard(match: report.match)
            MBWaveScrubber(report: report)
            statTiles(report: report)
            MBSectionTitle(title: MBTexts.reportSlumpsTitle, detail: MBTexts.reportSlumpsRule)
            slumpSection(report: report)
            MBSectionTitle(title: MBTexts.reportRecoveryTitle)
            recoverySection(report: report)
            MBSectionTitle(title: MBTexts.reportSubstitutionsTitle)
            substitutionSection(report: report)
            MBSectionTitle(title: MBTexts.reportTallyTitle)
            tallyTable(match: report.match)
        }
    }

    private func heroCard(match: MBMatch) -> some View {
        VStack(spacing: 12) {
            MBArtworkView(artworkName: MBArtworkNames.fullTime, fallbackEmoji: MBTexts.emojiWhistle, height: 96)
            MBTagText(text: MBTexts.matchCardDate(date: match.kickoffDate), size: 10)
            HStack(alignment: .center, spacing: 10) {
                heroTeam(teamName: match.primaryTeamName, swatch: match.primarySwatch)
                Text(MBTexts.scoreLine(primaryGoals: match.primaryGoals, rivalGoals: match.rivalGoals))
                    .font(MBTypography.scoreboard(44))
                    .foregroundColor(MBColors.ink)
                    .fixedSize()
                heroTeam(teamName: match.rivalTeamName, swatch: match.rivalSwatch)
            }
            if (match.groundName.isEmpty == false) {
                Text(MBTexts.groundLine(ground: match.groundName))
                    .font(MBTypography.body(13))
                    .foregroundColor(MBColors.inkSoft)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .mbSticker(fill: MBColors.card, cornerRadius: 26)
    }

    private func heroTeam(teamName: String, swatch: MBTeamSwatch) -> some View {
        VStack(spacing: 6) {
            Circle()
                .fill(swatch.strongColor)
                .frame(width: 26, height: 26)
                .overlay(Circle().stroke(MBColors.outline, lineWidth: 2))
            Text(teamName)
                .font(MBTypography.strong(14))
                .foregroundColor(MBColors.ink)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }

    private func statTiles(report: MBMatchReport) -> some View {
        let tileColumns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
        let recoveryValue = report.averagePrimaryRecoverySeconds.map { recoverySeconds in
            return MBTexts.minutesValue(minutes: recoverySeconds / 60)
        } ?? MBTexts.valueNotAvailable
        return LazyVGrid(columns: tileColumns, spacing: 12) {
            MBStatTile(emoji: MBTexts.emojiControl, value: MBTexts.percentValue(share: report.primaryControlShare), caption: MBTexts.reportControlCaption(teamName: report.match.primaryTeamName), fill: MBColors.mint)
            MBStatTile(emoji: MBTexts.emojiSwing, value: "\(report.initiativeSwings)", caption: MBTexts.reportSwingsCaption)
            MBStatTile(emoji: MBTexts.emojiSlump, value: "\(report.primarySlumps.count)", caption: MBTexts.reportSlumpsCaption(teamName: report.match.primaryTeamName))
            MBStatTile(emoji: MBTexts.emojiRecovery, value: recoveryValue, caption: MBTexts.reportRecoveryCaption, fill: MBColors.skyPale)
        }
    }

    @ViewBuilder
    private func slumpSection(report: MBMatchReport) -> some View {
        if (report.slumps.isEmpty) {
            MBNoteCard(emoji: MBTexts.emojiStrong, text: MBTexts.reportNoSlumps)
        } else {
            VStack(spacing: 10) {
                ForEach(report.slumps) { slumpSpell in
                    slumpRow(slumpSpell: slumpSpell, match: report.match)
                }
            }
        }
    }

    private func slumpRow(slumpSpell: MBSlumpSpell, match: MBMatch) -> some View {
        let teamName = slumpSpell.isPrimarySide ? match.primaryTeamName : match.rivalTeamName
        let swatch = slumpSpell.isPrimarySide ? match.primarySwatch : match.rivalSwatch
        return HStack(spacing: 12) {
            Text(MBTexts.slumpRange(start: slumpSpell.startMinuteLabel, end: slumpSpell.endMinuteLabel))
                .font(MBTypography.scoreboard(17))
                .foregroundColor(MBColors.ink)
                .frame(minWidth: 86, alignment: .leading)
            VStack(alignment: .leading, spacing: 2) {
                Text(MBTexts.slumpHeadline(teamName: teamName))
                    .font(MBTypography.strong(14))
                    .foregroundColor(MBColors.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(MBTexts.slumpDetail(minutes: slumpSpell.durationMinutes, depth: slumpSpell.deepestValue))
                    .font(MBTypography.body(12))
                    .foregroundColor(MBColors.inkSoft)
            }
            Spacer(minLength: 0)
            Capsule()
                .fill(swatch.strongColor)
                .frame(width: 8, height: 34)
                .overlay(Capsule().stroke(MBColors.outline, lineWidth: 1.5))
        }
        .padding(14)
        .mbSticker(fill: slumpSpell.isPrimarySide ? MBColors.alarmPale : MBColors.card, cornerRadius: 18, depth: 3)
    }

    @ViewBuilder
    private func recoverySection(report: MBMatchReport) -> some View {
        if (report.recoveries.isEmpty) {
            MBNoteCard(emoji: MBTexts.emojiGoal, text: MBTexts.reportNoGoals)
        } else {
            VStack(spacing: 10) {
                ForEach(report.recoveries) { recoveryRecord in
                    recoveryRow(recoveryRecord: recoveryRecord, match: report.match)
                }
            }
        }
    }

    private func recoveryRow(recoveryRecord: MBRecoveryRecord, match: MBMatch) -> some View {
        let concedingName = recoveryRecord.concedingIsPrimarySide ? match.primaryTeamName : match.rivalTeamName
        return HStack(spacing: 12) {
            Text(recoveryRecord.goalMinuteLabel)
                .font(MBTypography.scoreboard(17))
                .foregroundColor(MBColors.ink)
                .frame(minWidth: 52, alignment: .leading)
            VStack(alignment: .leading, spacing: 2) {
                Text(MBTexts.recoveryHeadline(concedingName: concedingName))
                    .font(MBTypography.strong(14))
                    .foregroundColor(MBColors.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(MBTexts.recoveryDetail(seconds: recoveryRecord.recoverySeconds))
                    .font(MBTypography.body(12))
                    .foregroundColor(recoveryRecord.recoverySeconds == nil ? MBColors.alarmInk : MBColors.inkSoft)
            }
            Spacer(minLength: 0)
            Text(recoveryRecord.recoverySeconds == nil ? MBTexts.emojiSlump : MBTexts.emojiRecovery)
                .font(.system(size: 22))
        }
        .padding(14)
        .mbSticker(fill: MBColors.card, cornerRadius: 18, depth: 3)
    }

    @ViewBuilder
    private func substitutionSection(report: MBMatchReport) -> some View {
        if (report.substitutionImpacts.isEmpty) {
            MBNoteCard(emoji: MBTexts.emojiSubstitution, text: MBTexts.reportNoSubstitutions)
        } else {
            VStack(spacing: 10) {
                ForEach(report.substitutionImpacts) { substitutionImpact in
                    substitutionRow(substitutionImpact: substitutionImpact, match: report.match)
                }
            }
        }
    }

    private func substitutionRow(substitutionImpact: MBSubstitutionImpact, match: MBMatch) -> some View {
        let teamName = substitutionImpact.isPrimarySide ? match.primaryTeamName : match.rivalTeamName
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Text(substitutionImpact.minuteLabel)
                    .font(MBTypography.scoreboard(17))
                    .foregroundColor(MBColors.ink)
                VStack(alignment: .leading, spacing: 2) {
                    Text(MBTexts.substitutionLine(outgoingName: substitutionImpact.outgoingName, incomingName: substitutionImpact.incomingName, teamName: teamName))
                        .font(MBTypography.strong(14))
                        .foregroundColor(MBColors.ink)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    Text(MBTexts.substitutionVerdict(swing: substitutionImpact.swing))
                        .font(MBTypography.body(12))
                        .foregroundColor(MBColors.inkSoft)
                }
                Spacer(minLength: 0)
                MBMomentumNumber(value: substitutionImpact.swing, size: 18)
            }
            HStack(spacing: 10) {
                impactBar(caption: MBTexts.substitutionBefore, value: substitutionImpact.beforeAverage)
                impactBar(caption: MBTexts.substitutionAfter, value: substitutionImpact.afterAverage)
            }
        }
        .padding(14)
        .mbSticker(fill: MBColors.card, cornerRadius: 18, depth: 3)
    }

    private func impactBar(caption: String, value: Double?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            MBTagText(text: caption, size: 9)
            GeometryReader { barGeometry in
                ZStack {
                    Capsule()
                        .fill(MBColors.paperDeep)
                    Rectangle()
                        .fill(MBColors.ink.opacity(0.3))
                        .frame(width: 1.5)
                    HStack(spacing: 0) {
                        if ((value ?? 0) >= 0) {
                            Spacer(minLength: barGeometry.size.width / 2)
                            Capsule()
                                .fill(MBColors.grass)
                                .frame(width: barGeometry.size.width / 2 * CGFloat(min(abs(value ?? 0), 1)))
                            Spacer(minLength: 0)
                        } else {
                            Spacer(minLength: 0)
                            Capsule()
                                .fill(MBColors.alarm)
                                .frame(width: barGeometry.size.width / 2 * CGFloat(min(abs(value ?? 0), 1)))
                            Spacer(minLength: barGeometry.size.width / 2)
                        }
                    }
                }
                .overlay(Capsule().stroke(MBColors.outline, lineWidth: 1.5))
            }
            .frame(height: 14)
        }
        .frame(maxWidth: .infinity)
    }

    private func tallyTable(match: MBMatch) -> some View {
        VStack(spacing: 0) {
            HStack {
                MBTagText(text: MBTexts.tallyMoment, size: 10)
                Spacer()
                MBTagText(text: match.primaryTeamName, color: match.primarySwatch.strongColor, size: 10)
                    .frame(width: 90, alignment: .trailing)
                    .lineLimit(1)
                MBTagText(text: match.rivalTeamName, color: match.rivalSwatch.strongColor, size: 10)
                    .frame(width: 90, alignment: .trailing)
                    .lineLimit(1)
            }
            .padding(.bottom, 8)
            ForEach(MBEventKind.everyKind, id: \.self) { eventKind in
                tallyRow(eventKind: eventKind, match: match)
            }
        }
        .padding(16)
        .mbSticker(fill: MBColors.card, cornerRadius: 20)
    }

    private func tallyRow(eventKind: MBEventKind, match: MBMatch) -> some View {
        let primaryCount = match.countEvents(kindIdentifier: eventKind.identifier, isPrimarySide: true, remainingEvents: match.events[...])
        let rivalCount = match.countEvents(kindIdentifier: eventKind.identifier, isPrimarySide: false, remainingEvents: match.events[...])
        return VStack(spacing: 0) {
            Rectangle()
                .fill(MBColors.ink.opacity(0.12))
                .frame(height: 1)
            HStack {
                Text("\(eventKind.emoji)  \(eventKind.title)")
                    .font(MBTypography.strong(14))
                    .foregroundColor(MBColors.ink)
                Spacer()
                Text("\(primaryCount)")
                    .font(MBTypography.scoreboard(16))
                    .foregroundColor(primaryCount >= rivalCount ? MBColors.ink : MBColors.inkFaint)
                    .frame(width: 90, alignment: .trailing)
                Text("\(rivalCount)")
                    .font(MBTypography.scoreboard(16))
                    .foregroundColor(rivalCount >= primaryCount ? MBColors.ink : MBColors.inkFaint)
                    .frame(width: 90, alignment: .trailing)
            }
            .padding(.vertical, 9)
        }
    }

    private func deleteMatch() {
        MBHaptics.rejected()
        ledger.removeMatch(identifier: matchIdentifier)
        dismiss()
    }
}

struct MBNoteCard: View {
    let emoji: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Text(emoji)
                .font(.system(size: 22))
            Text(text)
                .font(MBTypography.body(14))
                .foregroundColor(MBColors.inkSoft)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(14)
        .mbSticker(fill: MBColors.paperDeep, cornerRadius: 18, depth: 2)
    }
}
