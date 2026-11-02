
import SwiftUI

struct MBPlayerEditorSheet: View {
    @EnvironmentObject private var ledger: MBLedger
    @Environment(\.dismiss) private var dismiss
    let editedPlayer: MBPlayer?

    @State private var fullName: String
    @State private var shirtNumberText: String
    @State private var roleIdentifier: String

    init(editedPlayer: MBPlayer?) {
        self.editedPlayer = editedPlayer
        _fullName = State(initialValue: editedPlayer?.fullName ?? "")
        let initialNumberText = editedPlayer == nil ? "" : "\(editedPlayer?.shirtNumber ?? 0)"
        _shirtNumberText = State(initialValue: initialNumberText)
        _roleIdentifier = State(initialValue: editedPlayer?.roleIdentifier ?? MBPlayerRole.midfielder.identifier)
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                MBSheetHandleHeader(title: editedPlayer == nil ? MBTexts.editorNewTitle : MBTexts.editorEditTitle, onClose: closeSheet)
                MBTextField(caption: MBTexts.fieldPlayerName, placeholder: MBTexts.fieldPlayerNamePlaceholder, text: $fullName)
                MBTextField(caption: MBTexts.fieldShirtNumber, placeholder: suggestedNumberText, text: $shirtNumberText, keyboard: .numberPad)
                MBTagText(text: MBTexts.fieldRole)
                MBChipRow(options: roleOptions, selectedIdentifier: $roleIdentifier, fillsWidth: false)
                Button(MBTexts.editorSave) {
                    savePlayer()
                }
                .buttonStyle(MBStickerButtonStyle())
                .padding(.top, 6)
            }
            .padding(20)
        }
        .scrollDismissesKeyboard(.interactively)
        .mbScreenBackground()
    }

    private var roleOptions: [MBChipOption] {
        return MBPlayerRole.everyRole.map { playerRole in
            return MBChipOption(identifier: playerRole.identifier, title: "\(playerRole.emoji) \(playerRole.title)")
        }
    }

    private var suggestedNumber: Int {
        let usedNumbers = ledger.players.map { player in
            return player.shirtNumber
        }
        return firstFreeNumber(candidate: 1, usedNumbers: usedNumbers)
    }

    private var suggestedNumberText: String {
        return "\(suggestedNumber)"
    }

    private func firstFreeNumber(candidate: Int, usedNumbers: [Int]) -> Int {
        if (usedNumbers.contains(candidate) == false || candidate > 99) {
            return candidate
        }
        return firstFreeNumber(candidate: candidate + 1, usedNumbers: usedNumbers)
    }

    private func closeSheet() {
        dismiss()
    }

    private func savePlayer() {
        let trimmedName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        if (trimmedName.isEmpty) {
            MBHaptics.rejected()
            return
        }
        let parsedNumber = Int(shirtNumberText.trimmingCharacters(in: .whitespacesAndNewlines)) ?? suggestedNumber
        let savedNumber = min(max(parsedNumber, 0), 99)
        if let editedPlayer = editedPlayer {
            ledger.savePlayer(MBPlayer(id: editedPlayer.id, fullName: trimmedName, shirtNumber: savedNumber, roleIdentifier: roleIdentifier))
        } else {
            ledger.savePlayer(MBPlayer(fullName: trimmedName, shirtNumber: savedNumber, roleIdentifier: roleIdentifier))
        }
        MBHaptics.confirmed()
        dismiss()
    }
}
