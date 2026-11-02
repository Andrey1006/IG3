
import SwiftUI

struct MBMatchSetupSheet: View {
    @EnvironmentObject private var ledger: MBLedger
    @Environment(\.dismiss) private var dismiss
    let onStart: (MBMatch) -> Void

    @State private var matchTypeIdentifier: String
    @State private var rivalTeamName = ""
    @State private var broadcastHomeName = ""
    @State private var groundName = ""
    @State private var primarySwatchIdentifier = MBColors.defaultPrimarySwatchIdentifier
    @State private var rivalSwatchIdentifier = MBColors.defaultRivalSwatchIdentifier
    @State private var periodCount = 2
    @State private var periodMinutes = 45
    @State private var lineupIdentifiers: Set<String> = []
    @State private var hasPrefilled = false

    private static let clubMatchType = "club"
    private static let broadcastMatchType = "broadcast"
    private static let typicalLineupSize = 11

    init(startsWithBroadcast: Bool, onStart: @escaping (MBMatch) -> Void) {
        self.onStart = onStart
        _matchTypeIdentifier = State(initialValue: startsWithBroadcast ? MBMatchSetupSheet.broadcastMatchType : MBMatchSetupSheet.clubMatchType)
    }

    private var isClubMatch: Bool {
        return matchTypeIdentifier == MBMatchSetupSheet.clubMatchType
    }

    var body: some View {
        VStack(spacing: 0) {
            MBSheetHandleHeader(title: MBTexts.setupTitle, onClose: closeSheet)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 12)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    MBChipRow(options: matchTypeOptions, selectedIdentifier: $matchTypeIdentifier)
                    if (isClubMatch) {
                        clubFields
                    } else {
                        broadcastFields
                    }
                    MBTextField(caption: MBTexts.fieldGround, placeholder: MBTexts.fieldGroundPlaceholder, text: $groundName)
                    formatFields
                    if (isClubMatch && ledger.players.isEmpty == false) {
                        lineupFields
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                .padding(.top, 4)
            }
            .scrollDismissesKeyboard(.interactively)
            Button(MBTexts.setupStart) {
                startMatch()
            }
            .buttonStyle(MBStickerButtonStyle())
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            .padding(.top, 8)
        }
        .mbScreenBackground()
        .onAppear {
            prefillFromClub()
        }
    }

    private var matchTypeOptions: [MBChipOption] {
        var typeOptions: [MBChipOption] = []
        typeOptions.append(MBChipOption(identifier: MBMatchSetupSheet.clubMatchType, title: MBTexts.setupTypeClub))
        typeOptions.append(MBChipOption(identifier: MBMatchSetupSheet.broadcastMatchType, title: MBTexts.setupTypeBroadcast))
        return typeOptions
    }

    private var clubFields: some View {
        VStack(alignment: .leading, spacing: 14) {
            MBTextField(caption: MBTexts.fieldOpponent, placeholder: MBTexts.fieldOpponentPlaceholder, text: $rivalTeamName)
            MBTagText(text: MBTexts.fieldOpponentColour)
            MBSwatchPicker(selectedIdentifier: $rivalSwatchIdentifier, blockedIdentifier: ledger.club?.swatchIdentifier)
                .padding(14)
                .mbSticker(fill: MBColors.card, cornerRadius: 18, depth: 3)
        }
    }

    private var broadcastFields: some View {
        VStack(alignment: .leading, spacing: 14) {
            MBTextField(caption: MBTexts.fieldHomeTeam, placeholder: MBTexts.fieldHomeTeamPlaceholder, text: $broadcastHomeName)
            MBSwatchPicker(selectedIdentifier: $primarySwatchIdentifier, blockedIdentifier: rivalSwatchIdentifier)
                .padding(14)
                .mbSticker(fill: MBColors.card, cornerRadius: 18, depth: 3)
            MBTextField(caption: MBTexts.fieldAwayTeam, placeholder: MBTexts.fieldAwayTeamPlaceholder, text: $rivalTeamName)
            MBSwatchPicker(selectedIdentifier: $rivalSwatchIdentifier, blockedIdentifier: primarySwatchIdentifier)
                .padding(14)
                .mbSticker(fill: MBColors.card, cornerRadius: 18, depth: 3)
        }
    }

    private var formatFields: some View {
        VStack(alignment: .leading, spacing: 10) {
            MBTagText(text: MBTexts.fieldFormat)
            MBStepperDial(caption: MBTexts.fieldPeriods, valueLabel: "\(periodCount)", canDecrease: periodCount > 1, canIncrease: periodCount < 4, onDecrease: decreasePeriodCount, onIncrease: increasePeriodCount)
            MBStepperDial(caption: MBTexts.fieldPeriodLength, valueLabel: MBTexts.minuteMark(minute: periodMinutes), canDecrease: periodMinutes > MBMatchFormat.shortestPeriodMinutes, canIncrease: periodMinutes < MBMatchFormat.longestPeriodMinutes, onDecrease: decreasePeriodMinutes, onIncrease: increasePeriodMinutes)
        }
    }

    private var lineupFields: some View {
        let lineupColumns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]
        return VStack(alignment: .leading, spacing: 10) {
            MBSectionTitle(title: MBTexts.setupLineupTitle, detail: MBTexts.setupLineupCount(count: lineupIdentifiers.count))
            Text(MBTexts.setupLineupMessage)
                .font(MBTypography.body(13))
                .foregroundColor(MBColors.inkSoft)
            LazyVGrid(columns: lineupColumns, spacing: 8) {
                ForEach(ledger.playersSortedForSheet()) { player in
                    lineupChip(player: player)
                }
            }
        }
    }

    private func lineupChip(player: MBPlayer) -> some View {
        let isStarting = lineupIdentifiers.contains(player.id)
        return Button {
            MBHaptics.tick()
            if (isStarting) {
                lineupIdentifiers.remove(player.id)
            } else {
                lineupIdentifiers.insert(player.id)
            }
        } label: {
            HStack(spacing: 6) {
                Text("\(player.shirtNumber)")
                    .font(MBTypography.scoreboard(13))
                    .foregroundColor(MBColors.ink)
                    .frame(width: 24)
                Text(player.shortName)
                    .font(MBTypography.strong(13))
                    .foregroundColor(MBColors.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer(minLength: 0)
                Text(player.role.emoji)
                    .font(.system(size: 12))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .mbSticker(fill: isStarting ? MBColors.mint : MBColors.card, cornerRadius: 12, depth: isStarting ? 0 : 2)
        }
        .buttonStyle(.plain)
    }

    private func decreasePeriodCount() {
        periodCount -= 1
    }

    private func increasePeriodCount() {
        periodCount += 1
    }

    private func decreasePeriodMinutes() {
        periodMinutes -= 1
    }

    private func increasePeriodMinutes() {
        periodMinutes += 1
    }

    private func closeSheet() {
        dismiss()
    }

    private func prefillFromClub() {
        if (hasPrefilled) {
            return
        }
        hasPrefilled = true
        guard let club = ledger.club else {
            return
        }
        periodCount = club.format.periodCount
        periodMinutes = club.format.periodMinutes
        primarySwatchIdentifier = club.swatchIdentifier
        if (rivalSwatchIdentifier == club.swatchIdentifier) {
            let alternativeSwatch = MBColors.teamSwatches.first { swatch in
                return swatch.identifier != club.swatchIdentifier
            }
            rivalSwatchIdentifier = alternativeSwatch?.identifier ?? rivalSwatchIdentifier
        }
        let startingPlayers = ledger.playersSortedForSheet().prefix(MBMatchSetupSheet.typicalLineupSize)
        let startingIdentifiers = startingPlayers.map { player in
            return player.id
        }
        lineupIdentifiers = Set(startingIdentifiers)
    }

    private func startMatch() {
        let trimmedRival = rivalTeamName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedHome = broadcastHomeName.trimmingCharacters(in: .whitespacesAndNewlines)
        let clubName = ledger.club?.name ?? MBTexts.fallbackClubName
        if (trimmedRival.isEmpty || (isClubMatch == false && trimmedHome.isEmpty)) {
            MBHaptics.rejected()
            return
        }
        let chosenFormat = MBMatchFormat(periodCount: periodCount, periodMinutes: periodMinutes)
        let orderedLineup = ledger.playersSortedForSheet().map { player in
            return player.id
        }.filter { playerIdentifier in
            return lineupIdentifiers.contains(playerIdentifier)
        }
        let primaryName = isClubMatch ? clubName : trimmedHome
        let primarySwatch = isClubMatch ? (ledger.club?.swatchIdentifier ?? primarySwatchIdentifier) : primarySwatchIdentifier
        let newMatch = MBMatch(kickoffDate: Date(), isClubMatch: isClubMatch, primaryTeamName: primaryName, rivalTeamName: trimmedRival, primarySwatchIdentifier: primarySwatch, rivalSwatchIdentifier: rivalSwatchIdentifier, groundName: groundName.trimmingCharacters(in: .whitespacesAndNewlines), format: chosenFormat, startingPlayerIdentifiers: isClubMatch ? orderedLineup : [])
        MBHaptics.confirmed()
        onStart(newMatch)
        dismiss()
    }
}
