
import SwiftUI

struct MBArchiveScreen: View {
    @EnvironmentObject private var ledger: MBLedger
    @Binding var navigationPath: NavigationPath
    @State private var filterIdentifier = MBArchiveScreen.filterEverything

    private static let filterEverything = "all"
    private static let filterClub = "club"
    private static let filterBroadcast = "broadcast"

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    MBScreenHeader(kicker: MBTexts.archiveKicker, title: MBTexts.archiveTitle, trailingEmoji: MBTexts.emojiArchive)
                    if (ledger.matches.isEmpty) {
                        MBEmptyState(artworkName: MBArtworkNames.emptyArchive, fallbackEmoji: MBTexts.emojiArchive, title: MBTexts.archiveEmptyTitle, message: MBTexts.archiveEmptyMessage)
                    } else {
                        MBChipRow(options: filterOptions, selectedIdentifier: $filterIdentifier)
                        if (filteredMatches.isEmpty) {
                            Text(MBTexts.archiveFilterEmpty)
                                .font(MBTypography.body(14))
                                .foregroundColor(MBColors.inkSoft)
                                .padding(18)
                                .frame(maxWidth: .infinity)
                                .mbSticker(fill: MBColors.paperDeep, cornerRadius: 18, depth: 2)
                        }
                        ForEach(filteredMatches) { match in
                            NavigationLink(value: MBReportRoute(matchIdentifier: match.id)) {
                                MBMatchCard(match: match, memoryMinutes: ledger.memoryMinutes)
                            }
                            .buttonStyle(MBCardPressStyle())
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 120)
                .mbReadableWidth()
            }
            .mbScreenBackground()
            .toolbar(.hidden, for: .tabBar)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: MBReportRoute.self) { reportRoute in
                MBMatchReportScreen(matchIdentifier: reportRoute.matchIdentifier)
            }
        }
    }

    private var filterOptions: [MBChipOption] {
        var archiveFilters: [MBChipOption] = []
        archiveFilters.append(MBChipOption(identifier: MBArchiveScreen.filterEverything, title: MBTexts.archiveFilterAll))
        archiveFilters.append(MBChipOption(identifier: MBArchiveScreen.filterClub, title: MBTexts.archiveFilterClub))
        archiveFilters.append(MBChipOption(identifier: MBArchiveScreen.filterBroadcast, title: MBTexts.archiveFilterBroadcast))
        return archiveFilters
    }

    private var filteredMatches: [MBMatch] {
        if (filterIdentifier == MBArchiveScreen.filterClub) {
            return ledger.sortedMatches.filter { match in
                return match.isClubMatch
            }
        } else if (filterIdentifier == MBArchiveScreen.filterBroadcast) {
            return ledger.sortedMatches.filter { match in
                return match.isClubMatch == false
            }
        }
        return ledger.sortedMatches
    }
}

struct MBMatchCard: View {
    let match: MBMatch
    let memoryMinutes: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    MBTagText(text: MBTexts.matchCardDate(date: match.kickoffDate), size: 10)
                    Text(MBTexts.versusLine(primaryName: match.primaryTeamName, rivalName: match.rivalTeamName))
                        .font(MBTypography.strong(16))
                        .foregroundColor(MBColors.ink)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 8)
                VStack(alignment: .trailing, spacing: 6) {
                    Text(MBTexts.scoreLine(primaryGoals: match.primaryGoals, rivalGoals: match.rivalGoals))
                        .font(MBTypography.scoreboard(24))
                        .foregroundColor(MBColors.ink)
                    resultBadge
                }
            }
            MBWaveSparkline(match: match, memoryMinutes: memoryMinutes)
                .frame(height: 46)
                .padding(.horizontal, 2)
            HStack(spacing: 6) {
                Text(match.isClubMatch ? MBTexts.emojiClubMode : MBTexts.emojiBroadcastMode)
                    .font(.system(size: 12))
                MBTagText(text: match.groundName.isEmpty ? match.format.title : MBTexts.groundAndFormat(ground: match.groundName, format: match.format.title), size: 9)
                    .lineLimit(1)
                Spacer()
                MBTagText(text: MBTexts.momentCount(count: match.pressureMomentCount), size: 9)
            }
        }
        .padding(16)
        .mbSticker(fill: MBColors.card, cornerRadius: 22)
    }

    private var resultBadge: some View {
        let badgeFill: Color
        if (match.isClubMatch == false) {
            badgeFill = MBColors.skyPale
        } else if (match.primaryGoals > match.rivalGoals) {
            badgeFill = MBColors.mint
        } else if (match.primaryGoals < match.rivalGoals) {
            badgeFill = MBColors.alarmPale
        } else {
            badgeFill = MBColors.paperDeep
        }
        return Text(match.isClubMatch ? match.resultSymbol : MBTexts.resultBroadcast)
            .font(MBTypography.tag(11))
            .foregroundColor(MBColors.ink)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Capsule().fill(badgeFill))
            .overlay(Capsule().stroke(MBColors.outline, lineWidth: 1.5))
    }
}
