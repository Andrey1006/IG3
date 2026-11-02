
import SwiftUI

struct MBSeasonBucketScreen: View {
    @EnvironmentObject private var ledger: MBLedger
    let bucketIndex: Int

    var body: some View {
        let digest = MBSeasonDigest(matches: ledger.matches, memoryMinutes: ledger.memoryMinutes, players: ledger.players)
        let matchingBucket = digest.buckets.first { bucket in
            return bucket.bucketIndex == bucketIndex
        }
        return ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    MBBackButton()
                    Spacer()
                }
                if let bucket = matchingBucket {
                    bucketBody(bucket: bucket)
                } else {
                    MBEmptyState(artworkName: MBArtworkNames.emptySeason, fallbackEmoji: MBTexts.emojiSeason, title: MBTexts.bucketMissingTitle, message: MBTexts.bucketMissingMessage)
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
    }

    private func bucketBody(bucket: MBSeasonBucket) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                MBTagText(text: MBTexts.bucketKicker)
                Text(bucket.rangeTitle)
                    .font(MBTypography.poster(56))
                    .foregroundColor(MBColors.ink)
                Text(bucketVerdict(bucket: bucket))
                    .font(MBTypography.body(15))
                    .foregroundColor(MBColors.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack(spacing: 12) {
                MBStatTile(emoji: MBTexts.emojiWave, value: MBTexts.signedMomentum(value: bucket.matchCount > 0 ? bucket.averageMomentum : nil), caption: MBTexts.bucketAverageCaption, fill: bucket.averageMomentum < 0 ? MBColors.alarmPale : MBColors.mint)
                MBStatTile(emoji: MBTexts.emojiSlump, value: MBTexts.percentValue(share: bucket.negativeShare), caption: MBTexts.bucketSinkShareCaption)
                MBStatTile(emoji: MBTexts.emojiRecord, value: "\(bucket.matchCount)", caption: MBTexts.bucketMatchesCaption)
            }
            .fixedSize(horizontal: false, vertical: true)
            MBSectionTitle(title: MBTexts.bucketPerMatchTitle)
            if (bucket.matchValues.isEmpty) {
                MBNoteCard(emoji: MBTexts.emojiWatch, text: MBTexts.bucketNoCoverage)
            }
            ForEach(newestFirst(matchValues: bucket.matchValues)) { matchValue in
                NavigationLink(value: MBReportRoute(matchIdentifier: matchValue.matchIdentifier)) {
                    matchValueRow(matchValue: matchValue)
                }
                .buttonStyle(MBCardPressStyle())
            }
        }
    }

    private func newestFirst(matchValues: [MBBucketMatchValue]) -> [MBBucketMatchValue] {
        return matchValues.sorted { firstValue, secondValue in
            return firstValue.kickoffDate > secondValue.kickoffDate
        }
    }

    private func bucketVerdict(bucket: MBSeasonBucket) -> String {
        if (bucket.isStableSlump) {
            return MBTexts.bucketVerdictSlump
        } else if (bucket.isStrongSpell) {
            return MBTexts.bucketVerdictStrong
        } else if (bucket.matchCount < MBSeasonBucket.reliableMatchCount) {
            return MBTexts.bucketVerdictThin
        }
        return MBTexts.bucketVerdictMixed
    }

    private func matchValueRow(matchValue: MBBucketMatchValue) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                MBTagText(text: MBTexts.matchCardDate(date: matchValue.kickoffDate), size: 9)
                Text(MBTexts.versusRival(rivalName: matchValue.rivalTeamName))
                    .font(MBTypography.strong(14))
                    .foregroundColor(MBColors.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                if (matchValue.primaryGoalsInWindow + matchValue.rivalGoalsInWindow > 0) {
                    Text(MBTexts.bucketGoalsLine(scored: matchValue.primaryGoalsInWindow, conceded: matchValue.rivalGoalsInWindow))
                        .font(MBTypography.body(12))
                        .foregroundColor(MBColors.inkSoft)
                }
            }
            Spacer(minLength: 8)
            centredBar(value: matchValue.averageMomentum)
                .frame(width: 110, height: 16)
            MBMomentumNumber(value: matchValue.averageMomentum, size: 15)
                .frame(width: 48, alignment: .trailing)
        }
        .padding(14)
        .mbSticker(fill: MBColors.card, cornerRadius: 18, depth: 3)
    }

    private func centredBar(value: Double) -> some View {
        GeometryReader { barGeometry in
            let halfWidth = barGeometry.size.width / 2
            let fillWidth = halfWidth * CGFloat(min(abs(value), 1))
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(MBColors.paperDeep)
                Capsule()
                    .fill(value >= 0 ? MBColors.grass : MBColors.alarm)
                    .frame(width: fillWidth)
                    .offset(x: value >= 0 ? halfWidth : halfWidth - fillWidth)
                Rectangle()
                    .fill(MBColors.ink)
                    .frame(width: 1.5)
                    .offset(x: halfWidth)
            }
            .clipShape(Capsule())
            .overlay(Capsule().stroke(MBColors.outline, lineWidth: 1.5))
        }
    }
}
