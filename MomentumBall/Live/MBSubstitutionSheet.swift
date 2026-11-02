
import SwiftUI

struct MBSubstitutionSheet: View {
    @EnvironmentObject private var ledger: MBLedger
    @EnvironmentObject private var liveSession: MBLiveSession
    @Environment(\.dismiss) private var dismiss
    let onConfirm: (String?, String?) -> Void

    @State private var outgoingPlayerIdentifier: String?
    @State private var incomingPlayerIdentifier: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            MBSheetHandleHeader(title: MBTexts.substitutionTitle, onClose: closeSheet)
            Text(MBTexts.substitutionMessage)
                .font(MBTypography.body(14))
                .foregroundColor(MBColors.inkSoft)
            HStack(alignment: .top, spacing: 12) {
                playerColumn(caption: MBTexts.substitutionOff, emoji: MBTexts.emojiArrowOff, players: onPitchPlayers, selectedIdentifier: outgoingPlayerIdentifier, onSelect: selectOutgoing)
                playerColumn(caption: MBTexts.substitutionOn, emoji: MBTexts.emojiArrowOn, players: benchPlayers, selectedIdentifier: incomingPlayerIdentifier, onSelect: selectIncoming)
            }
            Button(MBTexts.substitutionConfirm) {
                confirm()
            }
            .buttonStyle(MBStickerButtonStyle())
            .opacity(outgoingPlayerIdentifier != nil && incomingPlayerIdentifier != nil ? 1 : 0.5)
            Button(MBTexts.substitutionWithoutNames) {
                onConfirm(nil, nil)
                dismiss()
            }
            .buttonStyle(MBStickerButtonStyle(fillColor: MBColors.card, verticalPadding: 12))
        }
        .padding(20)
        .frame(maxHeight: .infinity, alignment: .top)
        .mbScreenBackground()
    }

    private var onPitchPlayers: [MBPlayer] {
        let onPitchIdentifiers = liveSession.match?.onPitchPlayerIdentifiers() ?? []
        return ledger.playersSortedForSheet().filter { player in
            return onPitchIdentifiers.contains(player.id)
        }
    }

    private var benchPlayers: [MBPlayer] {
        let onPitchIdentifiers = liveSession.match?.onPitchPlayerIdentifiers() ?? []
        return ledger.playersSortedForSheet().filter { player in
            return onPitchIdentifiers.contains(player.id) == false
        }
    }

    private func playerColumn(caption: String, emoji: String, players: [MBPlayer], selectedIdentifier: String?, onSelect: @escaping (String) -> Void) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            MBTagText(text: "\(emoji) \(caption)")
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 8) {
                    if (players.isEmpty) {
                        Text(MBTexts.substitutionNobody)
                            .font(MBTypography.body(13))
                            .foregroundColor(MBColors.inkSoft)
                            .padding(12)
                    }
                    ForEach(players) { player in
                        playerChip(player: player, isSelected: player.id == selectedIdentifier, onSelect: onSelect)
                    }
                }
                .padding(.trailing, 4)
                .padding(.bottom, 6)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func playerChip(player: MBPlayer, isSelected: Bool, onSelect: @escaping (String) -> Void) -> some View {
        Button {
            MBHaptics.tick()
            onSelect(player.id)
        } label: {
            HStack(spacing: 8) {
                Text("\(player.shirtNumber)")
                    .font(MBTypography.scoreboard(13))
                    .foregroundColor(MBColors.ink)
                    .frame(width: 26)
                Text(player.shortName)
                    .font(MBTypography.strong(13))
                    .foregroundColor(MBColors.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .mbSticker(fill: isSelected ? MBColors.accent : MBColors.card, cornerRadius: 14, depth: isSelected ? 0 : 2)
        }
        .buttonStyle(.plain)
    }

    private func selectOutgoing(playerIdentifier: String) {
        outgoingPlayerIdentifier = playerIdentifier
    }

    private func selectIncoming(playerIdentifier: String) {
        incomingPlayerIdentifier = playerIdentifier
    }

    private func closeSheet() {
        dismiss()
    }

    private func confirm() {
        guard let outgoingPlayerIdentifier = outgoingPlayerIdentifier, let incomingPlayerIdentifier = incomingPlayerIdentifier else {
            MBHaptics.rejected()
            return
        }
        onConfirm(outgoingPlayerIdentifier, incomingPlayerIdentifier)
        dismiss()
    }
}
