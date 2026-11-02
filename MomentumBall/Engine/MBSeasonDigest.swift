
import Foundation

struct MBBucketMatchValue: Identifiable, Hashable {
    let matchIdentifier: String
    let rivalTeamName: String
    let kickoffDate: Date
    let averageMomentum: Double
    let primaryGoalsInWindow: Int
    let rivalGoalsInWindow: Int

    var id: String {
        return matchIdentifier
    }
}

struct MBSeasonBucket: Identifiable, Hashable {
    static let bucketMinutes = 10
    static let reliableMatchCount = 3
    static let slumpAverage = -0.2
    static let strongAverage = 0.2
    static let consistencyShare = 0.6
    static let minimumCoveredPoints = 10

    let bucketIndex: Int
    let matchValues: [MBBucketMatchValue]

    var id: Int {
        return bucketIndex
    }

    var startMinute: Int {
        return bucketIndex * MBSeasonBucket.bucketMinutes
    }

    var endMinute: Int {
        return startMinute + MBSeasonBucket.bucketMinutes
    }

    var matchCount: Int {
        return matchValues.count
    }

    var averageMomentum: Double {
        if (matchValues.isEmpty) {
            return 0
        }
        let summedMomentum = matchValues.reduce(0.0) { runningTotal, matchValue in
            return runningTotal + matchValue.averageMomentum
        }
        return summedMomentum / Double(matchValues.count)
    }

    var negativeShare: Double {
        if (matchValues.isEmpty) {
            return 0
        }
        let sinkingMatches = matchValues.filter { matchValue in
            return matchValue.averageMomentum < 0
        }
        return Double(sinkingMatches.count) / Double(matchValues.count)
    }

    var isStableSlump: Bool {
        return matchCount >= MBSeasonBucket.reliableMatchCount && averageMomentum < MBSeasonBucket.slumpAverage && negativeShare >= MBSeasonBucket.consistencyShare
    }

    var isStrongSpell: Bool {
        return matchCount >= MBSeasonBucket.reliableMatchCount && averageMomentum > MBSeasonBucket.strongAverage && (1 - negativeShare) >= MBSeasonBucket.consistencyShare
    }

    var rangeTitle: String {
        return MBTexts.minuteRange(startMinute: startMinute, endMinute: endMinute)
    }
}

struct MBPlayerSeasonLine: Identifiable, Hashable {
    let playerIdentifier: String
    let appearances: Int
    let playedSeconds: Int
    let weightedMomentum: Double?

    var id: String {
        return playerIdentifier
    }

    var playedMinutes: Int {
        return playedSeconds / 60
    }
}

struct MBSeasonInsight: Identifiable, Hashable {
    let id: String
    let emoji: String
    let headline: String
    let detail: String
    let isWarning: Bool
}

struct MBSeasonDigest {
    static let playerMinimumMinutes = 45

    let clubMatches: [MBMatch]
    let reports: [MBMatchReport]
    let buckets: [MBSeasonBucket]
    let playerLines: [MBPlayerSeasonLine]

    init(matches: [MBMatch], memoryMinutes: Int, players: [MBPlayer]) {
        let sortedClubMatches = matches.filter { match in
            return match.isClubMatch
        }.sorted { firstMatch, secondMatch in
            return firstMatch.kickoffDate < secondMatch.kickoffDate
        }
        let builtReports = sortedClubMatches.map { match in
            return MBMatchReport(match: match, memoryMinutes: memoryMinutes, players: players)
        }
        self.clubMatches = sortedClubMatches
        self.reports = builtReports
        let longestNominalSeconds = sortedClubMatches.map { match in
            return match.format.nominalMatchSeconds
        }.max() ?? 0
        let bucketCount = Int((Double(longestNominalSeconds) / Double(MBSeasonBucket.bucketMinutes * 60)).rounded(.up))
        var assembledBuckets: [MBSeasonBucket] = []
        MBSeasonDigest.assembleBuckets(bucketIndex: 0, bucketCount: bucketCount, reports: builtReports, assembledBuckets: &assembledBuckets)
        self.buckets = assembledBuckets
        self.playerLines = MBSeasonDigest.summarisePlayers(reports: builtReports)
    }

    var wins: Int {
        return clubMatches.filter { match in
            return match.primaryGoals > match.rivalGoals
        }.count
    }

    var draws: Int {
        return clubMatches.filter { match in
            return match.primaryGoals == match.rivalGoals
        }.count
    }

    var losses: Int {
        return clubMatches.count - wins - draws
    }

    var goalsFor: Int {
        let scoredPerMatch = clubMatches.map { match in
            return match.primaryGoals
        }
        return MBPlistList.sum(values: scoredPerMatch[...])
    }

    var goalsAgainst: Int {
        let concededPerMatch = clubMatches.map { match in
            return match.rivalGoals
        }
        return MBPlistList.sum(values: concededPerMatch[...])
    }

    var averageControlShare: Double {
        if (reports.isEmpty) {
            return 0
        }
        let summedShare = reports.reduce(0.0) { runningTotal, report in
            return runningTotal + report.primaryControlShare
        }
        return summedShare / Double(reports.count)
    }

    var concededRecoveries: [MBRecoveryRecord] {
        return reports.flatMap { report in
            return report.recoveries.filter { recoveryRecord in
                return recoveryRecord.concedingIsPrimarySide
            }
        }
    }

    var averageRecoveryMinutes: Double? {
        let recoveredSpans = concededRecoveries.compactMap { recoveryRecord in
            return recoveryRecord.recoverySeconds
        }
        if (recoveredSpans.isEmpty) {
            return nil
        }
        return Double(MBPlistList.sum(values: recoveredSpans[...])) / Double(recoveredSpans.count) / 60
    }

    var unrecoveredGoalCount: Int {
        return concededRecoveries.filter { recoveryRecord in
            return recoveryRecord.recoverySeconds == nil
        }.count
    }

    var weakestBucket: MBSeasonBucket? {
        return buckets.filter { bucket in
            return bucket.matchCount > 0
        }.min { firstBucket, secondBucket in
            return firstBucket.averageMomentum < secondBucket.averageMomentum
        }
    }

    var strongestBucket: MBSeasonBucket? {
        return buckets.filter { bucket in
            return bucket.matchCount > 0
        }.max { firstBucket, secondBucket in
            return firstBucket.averageMomentum < secondBucket.averageMomentum
        }
    }

    var insights: [MBSeasonInsight] {
        var collectedInsights: [MBSeasonInsight] = []
        let stableSlumps = buckets.filter { bucket in
            return bucket.isStableSlump
        }
        let deepestSlump = stableSlumps.min { firstBucket, secondBucket in
            return firstBucket.averageMomentum < secondBucket.averageMomentum
        }
        if let deepestSlump = deepestSlump {
            collectedInsights.append(MBSeasonInsight(id: "slump", emoji: MBTexts.emojiSlump, headline: MBTexts.insightSlumpHeadline(range: deepestSlump.rangeTitle), detail: MBTexts.insightSlumpDetail(sinkingMatches: Int((deepestSlump.negativeShare * Double(deepestSlump.matchCount)).rounded()), totalMatches: deepestSlump.matchCount), isWarning: true))
        } else if let weakestBucket = weakestBucket, weakestBucket.averageMomentum < 0 {
            collectedInsights.append(MBSeasonInsight(id: "weak", emoji: MBTexts.emojiWatch, headline: MBTexts.insightWeakHeadline(range: weakestBucket.rangeTitle), detail: MBTexts.insightWeakDetail, isWarning: false))
        }
        if let strongestBucket = strongestBucket, strongestBucket.averageMomentum > 0 {
            collectedInsights.append(MBSeasonInsight(id: "strong", emoji: MBTexts.emojiStrong, headline: MBTexts.insightStrongHeadline(range: strongestBucket.rangeTitle), detail: strongestBucket.isStrongSpell ? MBTexts.insightStrongStableDetail : MBTexts.insightStrongDetail, isWarning: false))
        }
        if let averageRecoveryMinutes = averageRecoveryMinutes {
            collectedInsights.append(MBSeasonInsight(id: "recovery", emoji: MBTexts.emojiRecovery, headline: MBTexts.insightRecoveryHeadline(minutes: averageRecoveryMinutes), detail: MBTexts.insightRecoveryDetail(unrecovered: unrecoveredGoalCount), isWarning: averageRecoveryMinutes > 8))
        }
        let substitutionSwings = reports.flatMap { report in
            return report.substitutionImpacts.compactMap { substitutionImpact in
                return substitutionImpact.isPrimarySide ? substitutionImpact.swing : nil
            }
        }
        if (substitutionSwings.isEmpty == false) {
            let averageSwing = substitutionSwings.reduce(0.0, +) / Double(substitutionSwings.count)
            collectedInsights.append(MBSeasonInsight(id: "bench", emoji: MBTexts.emojiSubstitution, headline: MBTexts.insightBenchHeadline(swing: averageSwing), detail: MBTexts.insightBenchDetail(count: substitutionSwings.count), isWarning: averageSwing < 0))
        }
        return collectedInsights
    }

    func playerLine(playerIdentifier: String) -> MBPlayerSeasonLine? {
        return playerLines.first { playerLine in
            return playerLine.playerIdentifier == playerIdentifier
        }
    }

    private static func assembleBuckets(bucketIndex: Int, bucketCount: Int, reports: [MBMatchReport], assembledBuckets: inout [MBSeasonBucket]) {
        if (bucketIndex >= bucketCount) {
            return
        }
        let windowStart = bucketIndex * MBSeasonBucket.bucketMinutes * 60
        let windowEnd = windowStart + MBSeasonBucket.bucketMinutes * 60
        let matchValues = reports.compactMap { report in
            return bucketValue(report: report, windowStart: windowStart, windowEnd: windowEnd)
        }
        assembledBuckets.append(MBSeasonBucket(bucketIndex: bucketIndex, matchValues: matchValues))
        assembleBuckets(bucketIndex: bucketIndex + 1, bucketCount: bucketCount, reports: reports, assembledBuckets: &assembledBuckets)
    }

    private static func bucketValue(report: MBMatchReport, windowStart: Int, windowEnd: Int) -> MBBucketMatchValue? {
        let windowPoints = report.wave.filter { wavePoint in
            return wavePoint.nominalSecond >= windowStart && wavePoint.nominalSecond < windowEnd
        }
        if (windowPoints.count < MBSeasonBucket.minimumCoveredPoints) {
            return nil
        }
        guard let windowAverage = MBMomentumEngine.averageValue(points: windowPoints[...], forPrimarySide: true) else {
            return nil
        }
        let windowGoals = report.match.events.filter { matchEvent in
            let nominalSecond = report.match.nominalSecond(timelineSecond: report.match.timelineSecond(event: matchEvent))
            return matchEvent.kindIdentifier == MBEventKind.goal.identifier && nominalSecond >= windowStart && nominalSecond < windowEnd
        }
        let primaryWindowGoals = windowGoals.filter { goalEvent in
            return goalEvent.isPrimarySide
        }.count
        return MBBucketMatchValue(matchIdentifier: report.match.id, rivalTeamName: report.match.rivalTeamName, kickoffDate: report.match.kickoffDate, averageMomentum: windowAverage, primaryGoalsInWindow: primaryWindowGoals, rivalGoalsInWindow: windowGoals.count - primaryWindowGoals)
    }

    private static func summarisePlayers(reports: [MBMatchReport]) -> [MBPlayerSeasonLine] {
        let everyStint = reports.flatMap { report in
            return report.playerStints
        }
        let stintsByPlayer = Dictionary(grouping: everyStint) { playerStint in
            return playerStint.playerIdentifier
        }
        return stintsByPlayer.map { playerIdentifier, playerStints in
            let stintSeconds = playerStints.map { playerStint in
                return playerStint.playedSeconds
            }
            let totalSeconds = MBPlistList.sum(values: stintSeconds[...])
            return MBPlayerSeasonLine(playerIdentifier: playerIdentifier, appearances: playerStints.count, playedSeconds: totalSeconds, weightedMomentum: weightedMomentum(remainingStints: playerStints[...], weightedTotal: 0, weightSum: 0))
        }
    }

    private static func weightedMomentum(remainingStints: ArraySlice<MBPlayerStint>, weightedTotal: Double, weightSum: Double) -> Double? {
        guard let playerStint = remainingStints.first else {
            return weightSum > 0 ? weightedTotal / weightSum : nil
        }
        guard let stintAverage = playerStint.averageMomentum else {
            return weightedMomentum(remainingStints: remainingStints.dropFirst(), weightedTotal: weightedTotal, weightSum: weightSum)
        }
        let stintWeight = Double(playerStint.playedSeconds)
        return weightedMomentum(remainingStints: remainingStints.dropFirst(), weightedTotal: weightedTotal + stintAverage * stintWeight, weightSum: weightSum + stintWeight)
    }
}
