
import SwiftUI

struct MBOnboardingFlow: View {
    @EnvironmentObject private var ledger: MBLedger
    @State private var stepIndex = 0
    @State private var trackingModeIdentifier = MBTrackingMode.both.identifier
    @State private var clubName = MBDemoSeason.demoClubName
    @State private var clubSwatchIdentifier = MBDemoSeason.demoSwatchIdentifier
    @State private var periodCount = 2
    @State private var periodMinutes = 45
    @State private var draftSquad = MBDemoSeason.demoSquad
    @State private var includesSampleSeason = true
    @State private var newPlayerName = ""
    @State private var newPlayerRoleIdentifier = MBPlayerRole.midfielder.identifier
    @State private var stepsMovingForward = true

    private let finalStepIndex = 3

    var body: some View {
        VStack(spacing: 0) {
            progressRail
                .padding(.horizontal, 20)
                .padding(.top, 12)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    stepContent
                        .id(stepIndex)
                        .transition(.asymmetric(insertion: .move(edge: stepsMovingForward ? .trailing : .leading).combined(with: .opacity), removal: .move(edge: stepsMovingForward ? .leading : .trailing).combined(with: .opacity)))
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 32)
                .mbReadableWidth()
            }
            .scrollDismissesKeyboard(.interactively)
            footerButtons
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                .mbReadableWidth()
        }
        .mbScreenBackground()
    }

    private var progressRail: some View {
        HStack(spacing: 8) {
            ForEach(0...finalStepIndex, id: \.self) { railIndex in
                Capsule()
                    .fill(railIndex <= stepIndex ? MBColors.ink : MBColors.paperDeep)
                    .frame(height: 8)
                    .overlay(Capsule().stroke(MBColors.outline, lineWidth: 1.5))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: stepIndex)
    }

    @ViewBuilder
    private var stepContent: some View {
        if (stepIndex == 0) {
            modeStep
        } else if (stepIndex == 1) {
            clubStep
        } else if (stepIndex == 2) {
            formatStep
        } else {
            squadStep
        }
    }

    private var modeStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            MBArtworkView(artworkName: MBArtworkNames.onboardingMode, fallbackEmoji: MBTexts.emojiWelcome, height: 170)
                .frame(maxWidth: .infinity)
            stepTitle(kicker: MBTexts.onboardingStepOneKicker, title: MBTexts.onboardingModeTitle, message: MBTexts.onboardingModeMessage)
            ForEach(MBTrackingMode.everyMode) { trackingMode in
                modeCard(trackingMode: trackingMode)
            }
        }
    }

    private func modeCard(trackingMode: MBTrackingMode) -> some View {
        let isSelected = trackingMode.identifier == trackingModeIdentifier
        return Button {
            MBHaptics.tick()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                trackingModeIdentifier = trackingMode.identifier
            }
        } label: {
            HStack(spacing: 14) {
                MBEmojiBadge(emoji: trackingMode.emoji, fill: isSelected ? MBColors.card : MBColors.paperDeep, diameter: 48)
                VStack(alignment: .leading, spacing: 4) {
                    Text(trackingMode.title)
                        .font(MBTypography.strong(17))
                        .foregroundColor(MBColors.ink)
                    Text(trackingMode.detail)
                        .font(MBTypography.body(13))
                        .foregroundColor(MBColors.inkSoft)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            .padding(14)
            .mbSticker(fill: isSelected ? MBColors.accent : MBColors.card, cornerRadius: 20, depth: isSelected ? 1 : 4)
            .offset(x: isSelected ? 3 : 0, y: isSelected ? 3 : 0)
        }
        .buttonStyle(.plain)
    }

    private var clubStep: some View {
        VStack(alignment: .leading, spacing: 18) {
            MBArtworkView(artworkName: MBArtworkNames.onboardingClub, fallbackEmoji: MBTexts.emojiCrest, height: 150)
                .frame(maxWidth: .infinity)
            stepTitle(kicker: MBTexts.onboardingStepTwoKicker, title: MBTexts.onboardingClubTitle, message: MBTexts.onboardingClubMessage)
            MBTextField(caption: MBTexts.fieldClubName, placeholder: MBTexts.fieldClubNamePlaceholder, text: $clubName)
            MBTagText(text: MBTexts.fieldKitColour)
            MBSwatchPicker(selectedIdentifier: $clubSwatchIdentifier)
                .padding(14)
                .mbSticker(fill: MBColors.card, cornerRadius: 18, depth: 3)
            kitPreview
        }
    }

    private var kitPreview: some View {
        let swatch = MBTeamSwatch.resolve(identifier: clubSwatchIdentifier)
        let previewName = clubName.trimmingCharacters(in: .whitespacesAndNewlines)
        return HStack(spacing: 12) {
            Text(MBTexts.emojiShirt)
                .font(.system(size: 30))
            Text(previewName.isEmpty ? MBTexts.fieldClubNamePlaceholder : previewName)
                .font(MBTypography.poster(24))
                .foregroundColor(swatch.strongColor)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Spacer()
        }
        .padding(16)
        .mbSticker(fill: swatch.paleColor, cornerRadius: 20)
    }

    private var formatStep: some View {
        VStack(alignment: .leading, spacing: 18) {
            MBArtworkView(artworkName: MBArtworkNames.onboardingFormat, fallbackEmoji: MBTexts.emojiStopwatch, height: 150)
                .frame(maxWidth: .infinity)
            stepTitle(kicker: MBTexts.onboardingStepThreeKicker, title: MBTexts.onboardingFormatTitle, message: MBTexts.onboardingFormatMessage)
            let presetColumns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
            LazyVGrid(columns: presetColumns, spacing: 12) {
                ForEach(MBMatchFormat.presets, id: \.self) { presetFormat in
                    presetChip(presetFormat: presetFormat)
                }
            }
            MBStepperDial(caption: MBTexts.fieldPeriods, valueLabel: "\(periodCount)", canDecrease: periodCount > 1, canIncrease: periodCount < 4, onDecrease: decreasePeriodCount, onIncrease: increasePeriodCount)
            MBStepperDial(caption: MBTexts.fieldPeriodLength, valueLabel: MBTexts.minuteMark(minute: periodMinutes), canDecrease: periodMinutes > MBMatchFormat.shortestPeriodMinutes, canIncrease: periodMinutes < MBMatchFormat.longestPeriodMinutes, onDecrease: decreasePeriodMinutes, onIncrease: increasePeriodMinutes)
            Text(MBTexts.onboardingFormatHint(totalMinutes: periodCount * periodMinutes))
                .font(MBTypography.body(13))
                .foregroundColor(MBColors.inkSoft)
        }
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

    private func presetChip(presetFormat: MBMatchFormat) -> some View {
        let isSelected = presetFormat.periodCount == periodCount && presetFormat.periodMinutes == periodMinutes
        return Button {
            MBHaptics.tick()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                periodCount = presetFormat.periodCount
                periodMinutes = presetFormat.periodMinutes
            }
        } label: {
            Text(presetFormat.title)
                .font(MBTypography.scoreboard(17))
                .foregroundColor(MBColors.ink)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .mbSticker(fill: isSelected ? MBColors.accent : MBColors.card, cornerRadius: 16, depth: isSelected ? 0 : 3)
                .offset(x: isSelected ? 3 : 0, y: isSelected ? 3 : 0)
        }
        .buttonStyle(.plain)
    }

    private var squadStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            MBArtworkView(artworkName: MBArtworkNames.onboardingSquad, fallbackEmoji: MBTexts.emojiSquad, height: 140)
                .frame(maxWidth: .infinity)
            stepTitle(kicker: MBTexts.onboardingStepFourKicker, title: MBTexts.onboardingSquadTitle, message: MBTexts.onboardingSquadMessage)
            VStack(spacing: 10) {
                MBTextField(caption: MBTexts.fieldPlayerName, placeholder: MBTexts.fieldPlayerNamePlaceholder, text: $newPlayerName)
                MBChipRow(options: roleOptions, selectedIdentifier: $newPlayerRoleIdentifier, fillsWidth: false)
                Button(MBTexts.actionAddPlayer) {
                    addDraftPlayer()
                }
                .buttonStyle(MBStickerButtonStyle(fillColor: MBColors.card, verticalPadding: 12))
            }
            MBSectionTitle(title: MBTexts.onboardingSquadListTitle, detail: MBTexts.playerCount(count: draftSquad.count))
            if (draftSquad.isEmpty) {
                Text(MBTexts.onboardingSquadEmpty)
                    .font(MBTypography.body(14))
                    .foregroundColor(MBColors.inkSoft)
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .mbSticker(fill: MBColors.paperDeep, cornerRadius: 18, depth: 2)
            }
            ForEach(draftSquad) { draftPlayer in
                draftPlayerRow(draftPlayer: draftPlayer)
            }
            sampleSeasonCard
        }
    }

    private var roleOptions: [MBChipOption] {
        return MBPlayerRole.everyRole.map { playerRole in
            return MBChipOption(identifier: playerRole.identifier, title: "\(playerRole.emoji) \(playerRole.title)")
        }
    }

    private func draftPlayerRow(draftPlayer: MBPlayer) -> some View {
        HStack(spacing: 12) {
            Text("\(draftPlayer.shirtNumber)")
                .font(MBTypography.scoreboard(15))
                .foregroundColor(MBColors.onStrong)
                .frame(width: 34, height: 34)
                .background(Circle().fill(MBTeamSwatch.resolve(identifier: clubSwatchIdentifier).strongColor))
                .overlay(Circle().stroke(MBColors.outline, lineWidth: 2))
            Text(draftPlayer.fullName)
                .font(MBTypography.strong(15))
                .foregroundColor(MBColors.ink)
            Spacer()
            Text(draftPlayer.role.emoji)
            Button {
                MBHaptics.tick()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    draftSquad.removeAll { candidatePlayer in
                        return candidatePlayer.id == draftPlayer.id
                    }
                }
            } label: {
                Image(systemName: MBTexts.symbolClose)
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(MBColors.inkSoft)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(MBColors.paperDeep))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .mbSticker(fill: MBColors.card, cornerRadius: 16, depth: 2)
    }

    private var sampleSeasonCard: some View {
        HStack(spacing: 14) {
            Text(MBTexts.emojiSample)
                .font(.system(size: 28))
            VStack(alignment: .leading, spacing: 4) {
                Text(MBTexts.onboardingSampleTitle)
                    .font(MBTypography.strong(16))
                    .foregroundColor(MBColors.ink)
                Text(MBTexts.onboardingSampleDetail)
                    .font(MBTypography.body(13))
                    .foregroundColor(MBColors.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            MBToggleSwitch(isOn: $includesSampleSeason)
        }
        .padding(16)
        .mbSticker(fill: MBColors.mint, cornerRadius: 20)
        .padding(.top, 8)
    }

    private func stepTitle(kicker: String, title: String, message: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            MBTagText(text: kicker, color: MBColors.alarmInk)
            Text(title.uppercased())
                .font(MBTypography.poster(36))
                .foregroundColor(MBColors.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(message)
                .font(MBTypography.body(15))
                .foregroundColor(MBColors.inkSoft)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var footerButtons: some View {
        HStack(spacing: 12) {
            if (stepIndex > 0) {
                Button {
                    moveStep(forward: false)
                } label: {
                    Image(systemName: MBTexts.symbolBack)
                }
                .buttonStyle(MBStickerButtonStyle(fillColor: MBColors.card, expandsHorizontally: false))
            }
            Button(stepIndex == finalStepIndex ? MBTexts.onboardingFinish : MBTexts.onboardingNext) {
                advance()
            }
            .buttonStyle(MBStickerButtonStyle())
        }
    }

    private var trimmedClubName: String {
        return clubName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func moveStep(forward: Bool) {
        MBHaptics.tick()
        stepsMovingForward = forward
        withAnimation(.spring(response: 0.42, dampingFraction: 0.85)) {
            stepIndex = forward ? min(stepIndex + 1, finalStepIndex) : max(stepIndex - 1, 0)
        }
    }

    private func advance() {
        if (stepIndex == 1 && trimmedClubName.isEmpty) {
            MBHaptics.rejected()
            return
        }
        if (stepIndex < finalStepIndex) {
            moveStep(forward: true)
            return
        }
        let newClub = MBClub(name: trimmedClubName, swatchIdentifier: clubSwatchIdentifier, format: MBMatchFormat(periodCount: periodCount, periodMinutes: periodMinutes), trackingModeIdentifier: trackingModeIdentifier)
        MBHaptics.confirmed()
        withAnimation(.easeInOut(duration: 0.35)) {
            ledger.completeOnboarding(club: newClub, players: draftSquad, includeSampleSeason: includesSampleSeason)
        }
    }

    private func addDraftPlayer() {
        let trimmedName = newPlayerName.trimmingCharacters(in: .whitespacesAndNewlines)
        if (trimmedName.isEmpty) {
            MBHaptics.rejected()
            return
        }
        let usedShirtNumbers = draftSquad.map { draftPlayer in
            return draftPlayer.shirtNumber
        }
        let nextShirtNumber = (usedShirtNumbers.max() ?? 0) + 1
        MBHaptics.confirmed()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            draftSquad.insert(MBPlayer(fullName: trimmedName, shirtNumber: nextShirtNumber, roleIdentifier: newPlayerRoleIdentifier), at: 0)
        }
        newPlayerName = ""
    }
}
