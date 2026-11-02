
import SwiftUI

struct MBSeasonScreen: View {
    @EnvironmentObject private var ledger: MBLedger
    @Binding var navigationPath: NavigationPath

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    MBScreenHeader(kicker: ledger.club?.name ?? MBTexts.fallbackClubName, title: MBTexts.seasonTitle, trailingEmoji: MBTexts.emojiSeason)
                    seasonBody(digest: MBSeasonDigest(matches: ledger.matches, memoryMinutes: ledger.memoryMinutes, players: ledger.players))
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 120)
                .mbReadableWidth()
            }
            .mbScreenBackground()
            .toolbar(.hidden, for: .tabBar)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: MBBucketRoute.self) { bucketRoute in
                MBSeasonBucketScreen(bucketIndex: bucketRoute.bucketIndex)
            }
            .navigationDestination(for: MBReportRoute.self) { reportRoute in
                MBMatchReportScreen(matchIdentifier: reportRoute.matchIdentifier)
            }
            .navigationDestination(for: MBPlayerRoute.self) { playerRoute in
                MBPlayerScreen(playerIdentifier: playerRoute.playerIdentifier)
            }
        }
    }

    @ViewBuilder
    private func seasonBody(digest: MBSeasonDigest) -> some View {
        if (digest.clubMatches.isEmpty) {
            MBEmptyState(artworkName: MBArtworkNames.emptySeason, fallbackEmoji: MBTexts.emojiSeason, title: MBTexts.seasonEmptyTitle, message: MBTexts.seasonEmptyMessage)
        } else {
            recordCard(digest: digest)
            MBSectionTitle(title: MBTexts.seasonHeatTitle, detail: MBTexts.seasonHeatDetail)
            heatStrip(digest: digest)
            if (digest.clubMatches.count < MBSeasonBucket.reliableMatchCount) {
                MBNoteCard(emoji: MBTexts.emojiWatch, text: MBTexts.seasonFewMatches(needed: MBSeasonBucket.reliableMatchCount - digest.clubMatches.count))
            }
            MBSectionTitle(title: MBTexts.seasonInsightsTitle)
            insightList(digest: digest)
            MBSectionTitle(title: MBTexts.seasonFormTitle, detail: MBTexts.seasonFormDetail)
            formStrip(digest: digest)
            playerSpotlight(digest: digest)
        }
    }

    private func recordCard(digest: MBSeasonDigest) -> some View {
        let tileColumns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
        return LazyVGrid(columns: tileColumns, spacing: 10) {
            MBStatTile(emoji: MBTexts.emojiRecord, value: MBTexts.recordLine(wins: digest.wins, draws: digest.draws, losses: digest.losses), caption: MBTexts.seasonRecordCaption, fill: MBColors.mint)
            MBStatTile(emoji: MBTexts.emojiGoal, value: MBTexts.scoreLine(primaryGoals: digest.goalsFor, rivalGoals: digest.goalsAgainst), caption: MBTexts.seasonGoalsCaption)
            MBStatTile(emoji: MBTexts.emojiControl, value: MBTexts.percentValue(share: digest.averageControlShare), caption: MBTexts.seasonControlCaption, fill: MBColors.skyPale)
        }
    }

    private func heatStrip(digest: MBSeasonDigest) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 5) {
                ForEach(digest.buckets) { bucket in
                    NavigationLink(value: MBBucketRoute(bucketIndex: bucket.bucketIndex)) {
                        heatCell(bucket: bucket)
                    }
                    .buttonStyle(MBCardPressStyle())
                }
            }
            HStack {
                legendDot(color: MBColors.alarm, caption: MBTexts.seasonLegendSink)
                Spacer()
                legendDot(color: MBColors.grass, caption: MBTexts.seasonLegendPress)
            }
        }
        .padding(14)
        .mbSticker(fill: MBColors.card, cornerRadius: 22)
    }

    private func heatCell(bucket: MBSeasonBucket) -> some View {
        VStack(spacing: 4) {
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(MBSeasonPalette.heatColor(bucket: bucket))
                    .frame(height: 74)
                    .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(MBColors.outline, lineWidth: 1.5))
                if (bucket.isStableSlump) {
                    Text(MBTexts.emojiWarning)
                        .font(.system(size: 12))
                        .padding(.top, 4)
                } else if (bucket.isStrongSpell) {
                    Text(MBTexts.emojiStrong)
                        .font(.system(size: 12))
                        .padding(.top, 4)
                }
            }
            Text("\(bucket.startMinute)")
                .font(MBTypography.tag(9))
                .foregroundColor(MBColors.inkSoft)
        }
        .frame(maxWidth: .infinity)
    }

    private func legendDot(color: Color, caption: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
                .overlay(Circle().stroke(MBColors.outline, lineWidth: 1))
            MBTagText(text: caption, size: 9)
        }
    }

    private func insightList(digest: MBSeasonDigest) -> some View {
        VStack(spacing: 10) {
            ForEach(digest.insights) { seasonInsight in
                HStack(alignment: .top, spacing: 12) {
                    MBEmojiBadge(emoji: seasonInsight.emoji, fill: seasonInsight.isWarning ? MBColors.alarmPale : MBColors.mint, diameter: 42)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(seasonInsight.headline)
                            .font(MBTypography.strong(16))
                            .foregroundColor(MBColors.ink)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(seasonInsight.detail)
                            .font(MBTypography.body(13))
                            .foregroundColor(MBColors.inkSoft)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                }
                .padding(14)
                .mbSticker(fill: MBColors.card, cornerRadius: 20, depth: 3)
            }
        }
    }

    private func formStrip(digest: MBSeasonDigest) -> some View {
        let recentReports = Array(digest.reports.suffix(6))
        return HStack(alignment: .bottom, spacing: 8) {
            ForEach(recentReports, id: \.match.id) { report in
                NavigationLink(value: MBReportRoute(matchIdentifier: report.match.id)) {
                    formColumn(report: report)
                }
                .buttonStyle(MBCardPressStyle())
            }
        }
        .padding(14)
        .mbSticker(fill: MBColors.card, cornerRadius: 22)
    }

    private func formColumn(report: MBMatchReport) -> some View {
        let barHeight = CGFloat(max(report.primaryControlShare, 0.05)) * 90
        return VStack(spacing: 6) {
            MBTagText(text: MBTexts.percentValue(share: report.primaryControlShare), size: 9)
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(report.primaryControlShare >= 0.5 ? MBColors.grass : MBColors.alarm)
                .frame(height: barHeight)
                .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(MBColors.outline, lineWidth: 1.5))
            Text(report.match.resultSymbol)
                .font(MBTypography.tag(11))
                .foregroundColor(MBColors.ink)
            Text(MBTexts.rivalInitials(name: report.match.rivalTeamName))
                .font(MBTypography.tag(9))
                .foregroundColor(MBColors.inkSoft)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150, alignment: .bottom)
    }

    @ViewBuilder
    private func playerSpotlight(digest: MBSeasonDigest) -> some View {
        let rankedLines = digest.playerLines.filter { playerLine in
            return playerLine.playedMinutes >= MBSeasonDigest.playerMinimumMinutes && playerLine.weightedMomentum != nil
        }.sorted { firstLine, secondLine in
            return (firstLine.weightedMomentum ?? 0) > (secondLine.weightedMomentum ?? 0)
        }
        if (rankedLines.isEmpty == false) {
            MBSectionTitle(title: MBTexts.seasonPlayersTitle, detail: MBTexts.seasonPlayersDetail)
            VStack(spacing: 8) {
                ForEach(rankedLines.prefix(5)) { playerLine in
                    if let player = ledger.player(identifier: playerLine.playerIdentifier) {
                        NavigationLink(value: MBPlayerRoute(playerIdentifier: player.id)) {
                            MBPlayerRow(player: player, seasonLine: playerLine, swatch: ledger.club?.swatch ?? MBColors.teamSwatches[0])
                        }
                        .buttonStyle(MBCardPressStyle())
                    }
                }
            }
        }
    }
}

struct MBSeasonPalette {
    static func heatColor(bucket: MBSeasonBucket) -> Color {
        if (bucket.matchCount == 0) {
            return MBColors.paperDeep
        }
        let intensity = min(abs(bucket.averageMomentum) / 0.5, 1)
        if (bucket.averageMomentum >= 0) {
            return MBColors.grass.opacity(0.18 + intensity * 0.82)
        }
        return MBColors.alarm.opacity(0.18 + intensity * 0.82)
    }
}
