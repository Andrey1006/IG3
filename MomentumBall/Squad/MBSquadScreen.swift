
import SwiftUI

struct MBSquadScreen: View {
    @EnvironmentObject private var ledger: MBLedger
    @Binding var navigationPath: NavigationPath
    @State private var isEditorPresented = false

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    MBScreenHeader(kicker: ledger.club?.name ?? MBTexts.fallbackClubName, title: MBTexts.squadTitle, trailingEmoji: MBTexts.emojiSquad)
                    squadBody(digest: MBSeasonDigest(matches: ledger.matches, memoryMinutes: ledger.memoryMinutes, players: ledger.players))
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 120)
                .mbReadableWidth()
            }
            .mbScreenBackground()
            .toolbar(.hidden, for: .tabBar)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: MBPlayerRoute.self) { playerRoute in
                MBPlayerScreen(playerIdentifier: playerRoute.playerIdentifier)
            }
            .navigationDestination(for: MBReportRoute.self) { reportRoute in
                MBMatchReportScreen(matchIdentifier: reportRoute.matchIdentifier)
            }
            .sheet(isPresented: $isEditorPresented) {
                MBPlayerEditorSheet(editedPlayer: nil)
                    .presentationDetents([.medium, .large])
            }
        }
    }

    @ViewBuilder
    private func squadBody(digest: MBSeasonDigest) -> some View {
        Button(MBTexts.squadAddPlayer) {
            MBHaptics.tick()
            isEditorPresented = true
        }
        .buttonStyle(MBStickerButtonStyle())
        if (ledger.players.isEmpty) {
            MBEmptyState(artworkName: MBArtworkNames.emptySquad, fallbackEmoji: MBTexts.emojiBench, title: MBTexts.squadEmptyTitle, message: MBTexts.squadEmptyMessage)
        } else {
            Text(MBTexts.squadExplainer)
                .font(MBTypography.body(13))
                .foregroundColor(MBColors.inkSoft)
                .fixedSize(horizontal: false, vertical: true)
            ForEach(MBPlayerRole.everyRole) { playerRole in
                roleSection(playerRole: playerRole, digest: digest)
            }
        }
    }

    @ViewBuilder
    private func roleSection(playerRole: MBPlayerRole, digest: MBSeasonDigest) -> some View {
        let rolePlayers = ledger.playersSortedForSheet().filter { player in
            return player.roleIdentifier == playerRole.identifier
        }
        if (rolePlayers.isEmpty == false) {
            MBSectionTitle(title: "\(playerRole.emoji) \(playerRole.title)", detail: MBTexts.playerCount(count: rolePlayers.count))
            VStack(spacing: 8) {
                ForEach(rolePlayers) { player in
                    NavigationLink(value: MBPlayerRoute(playerIdentifier: player.id)) {
                        MBPlayerRow(player: player, seasonLine: digest.playerLine(playerIdentifier: player.id), swatch: ledger.club?.swatch ?? MBColors.teamSwatches[0])
                    }
                    .buttonStyle(MBCardPressStyle())
                }
            }
        }
    }
}

struct MBPlayerRow: View {
    let player: MBPlayer
    let seasonLine: MBPlayerSeasonLine?
    let swatch: MBTeamSwatch

    var body: some View {
        HStack(spacing: 12) {
            Text("\(player.shirtNumber)")
                .font(MBTypography.scoreboard(16))
                .foregroundColor(MBColors.onStrong)
                .frame(width: 38, height: 38)
                .background(Circle().fill(swatch.strongColor))
                .overlay(Circle().stroke(MBColors.outline, lineWidth: 2))
            VStack(alignment: .leading, spacing: 2) {
                Text(player.fullName)
                    .font(MBTypography.strong(15))
                    .foregroundColor(MBColors.ink)
                    .lineLimit(1)
                Text(MBTexts.playerRowDetail(minutes: seasonLine?.playedMinutes ?? 0, appearances: seasonLine?.appearances ?? 0))
                    .font(MBTypography.body(12))
                    .foregroundColor(MBColors.inkSoft)
            }
            Spacer(minLength: 0)
            MBMomentumNumber(value: seasonLine?.weightedMomentum, size: 16)
        }
        .padding(12)
        .mbSticker(fill: MBColors.card, cornerRadius: 18, depth: 3)
    }
}
