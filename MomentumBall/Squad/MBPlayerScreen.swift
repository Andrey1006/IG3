
import SwiftUI

struct MBPlayerAppearance: Identifiable {
    let match: MBMatch
    let stint: MBPlayerStint

    var id: String {
        return match.id
    }
}

struct MBPlayerScreen: View {
    @EnvironmentObject private var ledger: MBLedger
    @Environment(\.dismiss) private var dismiss
    let playerIdentifier: String

    @State private var isEditorPresented = false
    @State private var isRemoveAlertPresented = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    MBBackButton()
                    Spacer()
                }
                if let player = ledger.player(identifier: playerIdentifier) {
                    playerBody(player: player)
                } else {
                    MBEmptyState(artworkName: MBArtworkNames.emptySquad, fallbackEmoji: MBTexts.emojiBench, title: MBTexts.playerMissingTitle, message: MBTexts.playerMissingMessage)
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
        .sheet(isPresented: $isEditorPresented) {
            MBPlayerEditorSheet(editedPlayer: ledger.player(identifier: playerIdentifier))
                .presentationDetents([.medium, .large])
        }
        .alert(MBTexts.playerRemoveAlertTitle, isPresented: $isRemoveAlertPresented) {
            Button(MBTexts.playerRemoveConfirm, role: .destructive) {
                removePlayer()
            }
            Button(MBTexts.actionCancel, role: .cancel) {
                MBHaptics.tick()
            }
        } message: {
            Text(MBTexts.playerRemoveAlertMessage)
        }
    }

    private func playerBody(player: MBPlayer) -> some View {
        let appearances = collectAppearances()
        let seasonLine = MBSeasonDigest(matches: ledger.matches, memoryMinutes: ledger.memoryMinutes, players: ledger.players).playerLine(playerIdentifier: player.id)
        let clubSwatch = ledger.club?.swatch ?? MBColors.teamSwatches[0]
        return VStack(alignment: .leading, spacing: 18) {
            VStack(spacing: 10) {
                Text("\(player.shirtNumber)")
                    .font(MBTypography.poster(64))
                    .foregroundColor(MBColors.onStrong)
                    .frame(width: 120, height: 120)
                    .background(Circle().fill(clubSwatch.strongColor))
                    .overlay(Circle().stroke(MBColors.outline, lineWidth: 3))
                    .background(Circle().fill(MBColors.hardShadow).offset(x: 5, y: 5))
                Text(player.fullName.uppercased())
                    .font(MBTypography.poster(32))
                    .foregroundColor(MBColors.ink)
                    .multilineTextAlignment(.center)
                MBTagText(text: "\(player.role.emoji) \(player.role.title)")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .mbSticker(fill: clubSwatch.paleColor, cornerRadius: 28)
            HStack(spacing: 12) {
                MBStatTile(emoji: MBTexts.emojiShirt, value: "\(seasonLine?.appearances ?? 0)", caption: MBTexts.playerAppearancesCaption)
                MBStatTile(emoji: MBTexts.emojiStopwatch, value: "\(seasonLine?.playedMinutes ?? 0)", caption: MBTexts.playerMinutesCaption)
                MBStatTile(emoji: MBTexts.emojiWave, value: MBTexts.signedMomentum(value: seasonLine?.weightedMomentum), caption: MBTexts.playerMomentumCaption, fill: MBColors.mint)
            }
            .fixedSize(horizontal: false, vertical: true)
            Text(MBTexts.playerMomentumExplainer)
                .font(MBTypography.body(13))
                .foregroundColor(MBColors.inkSoft)
                .fixedSize(horizontal: false, vertical: true)
            MBSectionTitle(title: MBTexts.playerMatchesTitle)
            if (appearances.isEmpty) {
                MBNoteCard(emoji: MBTexts.emojiBench, text: MBTexts.playerNoMatches)
            }
            ForEach(appearances) { appearance in
                NavigationLink(value: MBReportRoute(matchIdentifier: appearance.match.id)) {
                    appearanceRow(appearance: appearance)
                }
                .buttonStyle(MBCardPressStyle())
            }
            HStack(spacing: 12) {
                Button(MBTexts.playerEdit) {
                    MBHaptics.tick()
                    isEditorPresented = true
                }
                .buttonStyle(MBStickerButtonStyle(fillColor: MBColors.card))
                Button(MBTexts.playerRemove) {
                    MBHaptics.tick()
                    isRemoveAlertPresented = true
                }
                .buttonStyle(MBStickerButtonStyle(fillColor: MBColors.alarmPale))
            }
            .padding(.top, 6)
        }
    }

    private func appearanceRow(appearance: MBPlayerAppearance) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                MBTagText(text: MBTexts.matchCardDate(date: appearance.match.kickoffDate), size: 9)
                Text(MBTexts.versusRival(rivalName: appearance.match.rivalTeamName))
                    .font(MBTypography.strong(14))
                    .foregroundColor(MBColors.ink)
                    .lineLimit(1)
                Text(MBTexts.stintLine(fromLabel: appearance.match.minuteLabel(timelineSecond: appearance.stint.enteredTimelineSecond), toLabel: appearance.match.minuteLabel(timelineSecond: appearance.stint.leftTimelineSecond)))
                    .font(MBTypography.body(12))
                    .foregroundColor(MBColors.inkSoft)
            }
            Spacer(minLength: 0)
            MBMomentumNumber(value: appearance.stint.averageMomentum, size: 16)
        }
        .padding(14)
        .mbSticker(fill: MBColors.card, cornerRadius: 18, depth: 3)
    }

    private func collectAppearances() -> [MBPlayerAppearance] {
        let clubMatches = ledger.sortedMatches.filter { match in
            return match.isClubMatch
        }
        var collectedAppearances: [MBPlayerAppearance] = []
        gatherAppearances(remainingMatches: clubMatches[...], collectedAppearances: &collectedAppearances)
        return collectedAppearances
    }

    private func gatherAppearances(remainingMatches: ArraySlice<MBMatch>, collectedAppearances: inout [MBPlayerAppearance]) {
        guard let match = remainingMatches.first else {
            return
        }
        let report = MBMatchReport(match: match, memoryMinutes: ledger.memoryMinutes, players: ledger.players)
        let playerStint = report.playerStints.first { stint in
            return stint.playerIdentifier == playerIdentifier
        }
        if let playerStint = playerStint {
            collectedAppearances.append(MBPlayerAppearance(match: match, stint: playerStint))
        }
        gatherAppearances(remainingMatches: remainingMatches.dropFirst(), collectedAppearances: &collectedAppearances)
    }

    private func removePlayer() {
        MBHaptics.rejected()
        ledger.removePlayer(identifier: playerIdentifier)
        dismiss()
    }
}
