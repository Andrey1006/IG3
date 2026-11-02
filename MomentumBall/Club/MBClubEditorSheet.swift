
import SwiftUI

struct MBClubEditorSheet: View {
    @EnvironmentObject private var ledger: MBLedger
    @Environment(\.dismiss) private var dismiss

    @State private var clubName = ""
    @State private var swatchIdentifier = MBColors.defaultPrimarySwatchIdentifier
    @State private var periodCount = 2
    @State private var periodMinutes = 45
    @State private var trackingModeIdentifier = MBTrackingMode.both.identifier
    @State private var hasPrefilled = false

    var body: some View {
        VStack(spacing: 0) {
            MBSheetHandleHeader(title: MBTexts.clubEditorTitle, onClose: closeSheet)
                .padding(20)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    MBTextField(caption: MBTexts.fieldClubName, placeholder: MBTexts.fieldClubNamePlaceholder, text: $clubName)
                    MBTagText(text: MBTexts.fieldKitColour)
                    MBSwatchPicker(selectedIdentifier: $swatchIdentifier)
                        .padding(14)
                        .mbSticker(fill: MBColors.card, cornerRadius: 18, depth: 3)
                    MBTagText(text: MBTexts.fieldFormat)
                    MBStepperDial(caption: MBTexts.fieldPeriods, valueLabel: "\(periodCount)", canDecrease: periodCount > 1, canIncrease: periodCount < 4, onDecrease: decreasePeriodCount, onIncrease: increasePeriodCount)
                    MBStepperDial(caption: MBTexts.fieldPeriodLength, valueLabel: MBTexts.minuteMark(minute: periodMinutes), canDecrease: periodMinutes > MBMatchFormat.shortestPeriodMinutes, canIncrease: periodMinutes < MBMatchFormat.longestPeriodMinutes, onDecrease: decreasePeriodMinutes, onIncrease: increasePeriodMinutes)
                    MBTagText(text: MBTexts.fieldTrackingMode)
                    MBChipRow(options: modeOptions, selectedIdentifier: $trackingModeIdentifier, fillsWidth: false)
                    Text(MBTexts.clubEditorNote)
                        .font(MBTypography.body(12))
                        .foregroundColor(MBColors.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .scrollDismissesKeyboard(.interactively)
            Button(MBTexts.editorSave) {
                saveClub()
            }
            .buttonStyle(MBStickerButtonStyle())
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .mbScreenBackground()
        .onAppear {
            prefill()
        }
    }

    private var modeOptions: [MBChipOption] {
        return MBTrackingMode.everyMode.map { trackingMode in
            return MBChipOption(identifier: trackingMode.identifier, title: "\(trackingMode.emoji) \(trackingMode.title)")
        }
    }

    private func prefill() {
        if (hasPrefilled) {
            return
        }
        hasPrefilled = true
        guard let club = ledger.club else {
            return
        }
        clubName = club.name
        swatchIdentifier = club.swatchIdentifier
        periodCount = club.format.periodCount
        periodMinutes = club.format.periodMinutes
        trackingModeIdentifier = club.trackingModeIdentifier
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

    private func saveClub() {
        let trimmedName = clubName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard var updatedClub = ledger.club, trimmedName.isEmpty == false else {
            MBHaptics.rejected()
            return
        }
        updatedClub.name = trimmedName
        updatedClub.swatchIdentifier = swatchIdentifier
        updatedClub.format = MBMatchFormat(periodCount: periodCount, periodMinutes: periodMinutes)
        updatedClub.trackingModeIdentifier = trackingModeIdentifier
        ledger.updateClub(updatedClub)
        MBHaptics.confirmed()
        dismiss()
    }
}
