
import Foundation

struct MBMatch: Identifiable, Hashable {
    let id: String
    var kickoffDate: Date
    var isClubMatch: Bool
    var primaryTeamName: String
    var rivalTeamName: String
    var primarySwatchIdentifier: String
    var rivalSwatchIdentifier: String
    var groundName: String
    var format: MBMatchFormat
    var events: [MBMatchEvent]
    var playedSecondsPerPeriod: [Int]
    var startingPlayerIdentifiers: [String]

    init(id: String = UUID().uuidString, kickoffDate: Date, isClubMatch: Bool, primaryTeamName: String, rivalTeamName: String, primarySwatchIdentifier: String, rivalSwatchIdentifier: String, groundName: String, format: MBMatchFormat, events: [MBMatchEvent] = [], playedSecondsPerPeriod: [Int] = [], startingPlayerIdentifiers: [String] = []) {
        self.id = id
        self.kickoffDate = kickoffDate
        self.isClubMatch = isClubMatch
        self.primaryTeamName = primaryTeamName
        self.rivalTeamName = rivalTeamName
        self.primarySwatchIdentifier = primarySwatchIdentifier
        self.rivalSwatchIdentifier = rivalSwatchIdentifier
        self.groundName = groundName
        self.format = format
        self.events = events
        self.playedSecondsPerPeriod = playedSecondsPerPeriod
        self.startingPlayerIdentifiers = startingPlayerIdentifiers
    }

    var primarySwatch: MBTeamSwatch {
        return MBTeamSwatch.resolve(identifier: primarySwatchIdentifier)
    }

    var rivalSwatch: MBTeamSwatch {
        return MBTeamSwatch.resolve(identifier: rivalSwatchIdentifier)
    }

    var primaryGoals: Int {
        return countEvents(kindIdentifier: MBEventKind.goal.identifier, isPrimarySide: true, remainingEvents: events[...])
    }

    var rivalGoals: Int {
        return countEvents(kindIdentifier: MBEventKind.goal.identifier, isPrimarySide: false, remainingEvents: events[...])
    }

    var pressureMomentCount: Int {
        return events.filter { matchEvent in
            return matchEvent.kind.isPressureMoment
        }.count
    }

    var totalPlayedSeconds: Int {
        return MBPlistList.sum(values: playedSecondsPerPeriod[...])
    }

    var resultSymbol: String {
        if (primaryGoals > rivalGoals) {
            return MBTexts.resultWin
        } else if (primaryGoals < rivalGoals) {
            return MBTexts.resultLoss
        }
        return MBTexts.resultDraw
    }

    func countEvents(kindIdentifier: String, isPrimarySide: Bool, remainingEvents: ArraySlice<MBMatchEvent>) -> Int {
        guard let candidateEvent = remainingEvents.first else {
            return 0
        }
        let matchesQuery = candidateEvent.kindIdentifier == kindIdentifier && candidateEvent.isPrimarySide == isPrimarySide
        return (matchesQuery ? 1 : 0) + countEvents(kindIdentifier: kindIdentifier, isPrimarySide: isPrimarySide, remainingEvents: remainingEvents.dropFirst())
    }

    func periodStartTimelineSecond(periodIndex: Int) -> Int {
        let completedPeriods = min(periodIndex, playedSecondsPerPeriod.count)
        let completedSeconds = MBPlistList.sum(values: playedSecondsPerPeriod.prefix(completedPeriods))
        let missingPeriods = periodIndex - completedPeriods
        return completedSeconds + missingPeriods * format.nominalPeriodSeconds
    }

    func timelineSecond(event: MBMatchEvent) -> Int {
        return periodStartTimelineSecond(periodIndex: event.periodIndex) + event.periodSecond
    }

    func nominalSecond(timelineSecond: Int) -> Int {
        return resolveNominalSecond(remainingTimeline: timelineSecond, periodIndex: 0)
    }

    private func resolveNominalSecond(remainingTimeline: Int, periodIndex: Int) -> Int {
        let isLastKnownPeriod = periodIndex >= playedSecondsPerPeriod.count || periodIndex >= format.periodCount - 1
        let periodLength = periodIndex < playedSecondsPerPeriod.count ? playedSecondsPerPeriod[periodIndex] : format.nominalPeriodSeconds
        if (remainingTimeline < periodLength || isLastKnownPeriod) {
            let clampedSecond = min(remainingTimeline, format.nominalPeriodSeconds - 1)
            return periodIndex * format.nominalPeriodSeconds + max(0, clampedSecond)
        }
        return resolveNominalSecond(remainingTimeline: remainingTimeline - periodLength, periodIndex: periodIndex + 1)
    }

    func minuteLabel(event: MBMatchEvent) -> String {
        return format.minuteLabel(periodIndex: event.periodIndex, periodSecond: event.periodSecond)
    }

    func minuteLabel(timelineSecond: Int) -> String {
        return MBTexts.minuteMark(minute: nominalSecond(timelineSecond: timelineSecond) / 60 + 1)
    }

    func onPitchPlayerIdentifiers() -> [String] {
        let primarySubstitutions = events.filter { matchEvent in
            return matchEvent.isPrimarySide && matchEvent.kindIdentifier == MBEventKind.substitution.identifier
        }
        return applySubstitutions(lineup: startingPlayerIdentifiers, remainingSubstitutions: primarySubstitutions[...])
    }

    private func applySubstitutions(lineup: [String], remainingSubstitutions: ArraySlice<MBMatchEvent>) -> [String] {
        guard let substitution = remainingSubstitutions.first else {
            return lineup
        }
        var updatedLineup = lineup.filter { playerIdentifier in
            return playerIdentifier != substitution.outgoingPlayerIdentifier
        }
        if let incomingIdentifier = substitution.incomingPlayerIdentifier, updatedLineup.contains(incomingIdentifier) == false {
            updatedLineup.append(incomingIdentifier)
        }
        return applySubstitutions(lineup: updatedLineup, remainingSubstitutions: remainingSubstitutions.dropFirst())
    }

    init?(plistDictionary: [String: Any]) {
        guard let storedIdentifier = plistDictionary["id"] as? String, let storedKickoff = plistDictionary["kickoff"] as? Double, let storedPrimaryName = plistDictionary["primaryName"] as? String, let storedRivalName = plistDictionary["rivalName"] as? String else {
            return nil
        }
        let storedEvents = MBPlistList.decode(rawValue: plistDictionary["events"]) { eventDictionary in
            return MBMatchEvent(plistDictionary: eventDictionary)
        }
        let storedPrimarySwatch = plistDictionary["primarySwatch"] as? String ?? MBColors.defaultPrimarySwatchIdentifier
        let storedRivalSwatch = plistDictionary["rivalSwatch"] as? String ?? MBColors.defaultRivalSwatchIdentifier
        let storedFormat = MBMatchFormat(plistDictionary: plistDictionary["format"] as? [String: Any])
        self.init(id: storedIdentifier, kickoffDate: Date(timeIntervalSince1970: storedKickoff), isClubMatch: plistDictionary["club"] as? Bool ?? true, primaryTeamName: storedPrimaryName, rivalTeamName: storedRivalName, primarySwatchIdentifier: storedPrimarySwatch, rivalSwatchIdentifier: storedRivalSwatch, groundName: plistDictionary["ground"] as? String ?? "", format: storedFormat, events: storedEvents, playedSecondsPerPeriod: plistDictionary["played"] as? [Int] ?? [], startingPlayerIdentifiers: plistDictionary["lineup"] as? [String] ?? [])
    }

    var plistDictionary: [String: Any] {
        let encodedEvents = events.map { matchEvent in
            return matchEvent.plistDictionary
        }
        return ["id": id, "kickoff": kickoffDate.timeIntervalSince1970, "club": isClubMatch, "primaryName": primaryTeamName, "rivalName": rivalTeamName, "primarySwatch": primarySwatchIdentifier, "rivalSwatch": rivalSwatchIdentifier, "ground": groundName, "format": format.plistDictionary, "events": encodedEvents, "played": playedSecondsPerPeriod, "lineup": startingPlayerIdentifiers]
    }
}
