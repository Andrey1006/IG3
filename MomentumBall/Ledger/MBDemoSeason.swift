
import Foundation

struct MBSeededDice {
    private var dieState: UInt64

    init(seed: UInt64) {
        dieState = seed &* 6364136223846793005 &+ 1442695040888963407
    }

    mutating func roll() -> Double {
        dieState = dieState &* 6364136223846793005 &+ 1442695040888963407
        return Double(dieState >> 11) / Double(UInt64(1) << 53)
    }
}

struct MBDemoPhase {
    let fromMinute: Int
    let toMinute: Int
    let primaryPressure: Double
    let rivalPressure: Double
}

struct MBDemoGoal {
    let minute: Int
    let isPrimarySide: Bool
}

struct MBDemoSubstitution {
    let minute: Int
    let isPrimarySide: Bool
    let outgoingShirt: Int
    let incomingShirt: Int
}

struct MBDemoFixture {
    let isClubMatch: Bool
    let primaryOverrideName: String?
    let primaryOverrideSwatch: String?
    let rivalTeamName: String
    let rivalSwatchIdentifier: String
    let groundName: String
    let kickoffComponents: DateComponents
    let diceSeed: UInt64
    let phases: [MBDemoPhase]
    let goals: [MBDemoGoal]
    let substitutions: [MBDemoSubstitution]
}

struct MBDemoSeason {
    static let demoClubName = "SV Lindenau 08"
    static let demoSwatchIdentifier = "grass"
    static let restingPrimaryPressure = 0.32
    static let restingRivalPressure = 0.3
    static let slotSeconds = 20
    static let momentChancePerSlot = 0.45
    static let demoPlayedSeconds = [2820, 2940]

    static let demoSquad: [MBPlayer] = assembleDemoSquad()

    static let fixtures: [MBDemoFixture] = assembleFixtures()

    private static func assembleDemoSquad() -> [MBPlayer] {
        var assembledSquad: [MBPlayer] = []
        assembledSquad.append(MBPlayer(id: "mb-demo-01", fullName: "Jonas Becker", shirtNumber: 1, roleIdentifier: MBPlayerRole.goalkeeper.identifier))
        assembledSquad.append(MBPlayer(id: "mb-demo-02", fullName: "Lukas Hoffmann", shirtNumber: 2, roleIdentifier: MBPlayerRole.defender.identifier))
        assembledSquad.append(MBPlayer(id: "mb-demo-03", fullName: "Felix Wagner", shirtNumber: 3, roleIdentifier: MBPlayerRole.defender.identifier))
        assembledSquad.append(MBPlayer(id: "mb-demo-04", fullName: "Tim Schulz", shirtNumber: 4, roleIdentifier: MBPlayerRole.defender.identifier))
        assembledSquad.append(MBPlayer(id: "mb-demo-05", fullName: "Leon Richter", shirtNumber: 5, roleIdentifier: MBPlayerRole.defender.identifier))
        assembledSquad.append(MBPlayer(id: "mb-demo-06", fullName: "Paul Neumann", shirtNumber: 6, roleIdentifier: MBPlayerRole.midfielder.identifier))
        assembledSquad.append(MBPlayer(id: "mb-demo-07", fullName: "Niklas Braun", shirtNumber: 7, roleIdentifier: MBPlayerRole.midfielder.identifier))
        assembledSquad.append(MBPlayer(id: "mb-demo-08", fullName: "Moritz Krüger", shirtNumber: 8, roleIdentifier: MBPlayerRole.midfielder.identifier))
        assembledSquad.append(MBPlayer(id: "mb-demo-09", fullName: "Jan Wolf", shirtNumber: 9, roleIdentifier: MBPlayerRole.forward.identifier))
        assembledSquad.append(MBPlayer(id: "mb-demo-10", fullName: "Elias Hartmann", shirtNumber: 10, roleIdentifier: MBPlayerRole.midfielder.identifier))
        assembledSquad.append(MBPlayer(id: "mb-demo-11", fullName: "Ben Zimmermann", shirtNumber: 11, roleIdentifier: MBPlayerRole.forward.identifier))
        assembledSquad.append(MBPlayer(id: "mb-demo-12", fullName: "Finn Lange", shirtNumber: 12, roleIdentifier: MBPlayerRole.midfielder.identifier))
        assembledSquad.append(MBPlayer(id: "mb-demo-13", fullName: "Max Schmitt", shirtNumber: 13, roleIdentifier: MBPlayerRole.defender.identifier))
        assembledSquad.append(MBPlayer(id: "mb-demo-14", fullName: "Erik Vogel", shirtNumber: 14, roleIdentifier: MBPlayerRole.forward.identifier))
        assembledSquad.append(MBPlayer(id: "mb-demo-15", fullName: "Simon Fuchs", shirtNumber: 15, roleIdentifier: MBPlayerRole.midfielder.identifier))
        assembledSquad.append(MBPlayer(id: "mb-demo-16", fullName: "David Krause", shirtNumber: 16, roleIdentifier: MBPlayerRole.forward.identifier))
        return assembledSquad
    }

    private static func assembleFixtures() -> [MBDemoFixture] {
        var assembledFixtures: [MBDemoFixture] = []
        assembledFixtures.append(MBDemoFixture(isClubMatch: true, primaryOverrideName: nil, primaryOverrideSwatch: nil, rivalTeamName: "FC Gohlis 1921", rivalSwatchIdentifier: "cobalt", groundName: "Sportpark Lindenau, Leipzig", kickoffComponents: DateComponents(year: 2026, month: 9, day: 6, hour: 11), diceSeed: 1921, phases: [MBDemoPhase(fromMinute: 0, toMinute: 15, primaryPressure: 0.45, rivalPressure: 0.28), MBDemoPhase(fromMinute: 58, toMinute: 71, primaryPressure: 0.12, rivalPressure: 0.62), MBDemoPhase(fromMinute: 75, toMinute: 90, primaryPressure: 0.5, rivalPressure: 0.25)], goals: [MBDemoGoal(minute: 23, isPrimarySide: true), MBDemoGoal(minute: 64, isPrimarySide: false), MBDemoGoal(minute: 81, isPrimarySide: true)], substitutions: [MBDemoSubstitution(minute: 62, isPrimarySide: true, outgoingShirt: 9, incomingShirt: 14), MBDemoSubstitution(minute: 74, isPrimarySide: true, outgoingShirt: 7, incomingShirt: 15)]))
        assembledFixtures.append(MBDemoFixture(isClubMatch: true, primaryOverrideName: nil, primaryOverrideSwatch: nil, rivalTeamName: "TuS Paunsdorf", rivalSwatchIdentifier: "berry", groundName: "Paunsdorfer Wäldchen, Leipzig", kickoffComponents: DateComponents(year: 2026, month: 9, day: 13, hour: 14), diceSeed: 4413, phases: [MBDemoPhase(fromMinute: 20, toMinute: 40, primaryPressure: 0.5, rivalPressure: 0.25), MBDemoPhase(fromMinute: 60, toMinute: 72, primaryPressure: 0.1, rivalPressure: 0.6)], goals: [MBDemoGoal(minute: 38, isPrimarySide: true), MBDemoGoal(minute: 66, isPrimarySide: false)], substitutions: [MBDemoSubstitution(minute: 65, isPrimarySide: true, outgoingShirt: 10, incomingShirt: 13)]))
        assembledFixtures.append(MBDemoFixture(isClubMatch: true, primaryOverrideName: nil, primaryOverrideSwatch: nil, rivalTeamName: "SpVgg Möckern", rivalSwatchIdentifier: "violet", groundName: "Sportpark Lindenau, Leipzig", kickoffComponents: DateComponents(year: 2026, month: 9, day: 20, hour: 11), diceSeed: 7720, phases: [MBDemoPhase(fromMinute: 0, toMinute: 30, primaryPressure: 0.25, rivalPressure: 0.4), MBDemoPhase(fromMinute: 48, toMinute: 56, primaryPressure: 0.15, rivalPressure: 0.55), MBDemoPhase(fromMinute: 59, toMinute: 70, primaryPressure: 0.1, rivalPressure: 0.65)], goals: [MBDemoGoal(minute: 52, isPrimarySide: false), MBDemoGoal(minute: 67, isPrimarySide: false)], substitutions: [MBDemoSubstitution(minute: 63, isPrimarySide: true, outgoingShirt: 8, incomingShirt: 14), MBDemoSubstitution(minute: 70, isPrimarySide: true, outgoingShirt: 11, incomingShirt: 16)]))
        assembledFixtures.append(MBDemoFixture(isClubMatch: true, primaryOverrideName: nil, primaryOverrideSwatch: nil, rivalTeamName: "BSC Connewitz", rivalSwatchIdentifier: "ink", groundName: "Sportplatz Connewitz, Leipzig", kickoffComponents: DateComponents(year: 2026, month: 9, day: 27, hour: 13), diceSeed: 2709, phases: [MBDemoPhase(fromMinute: 0, toMinute: 20, primaryPressure: 0.55, rivalPressure: 0.2), MBDemoPhase(fromMinute: 40, toMinute: 46, primaryPressure: 0.5, rivalPressure: 0.2), MBDemoPhase(fromMinute: 60, toMinute: 75, primaryPressure: 0.5, rivalPressure: 0.22)], goals: [MBDemoGoal(minute: 12, isPrimarySide: true), MBDemoGoal(minute: 44, isPrimarySide: true), MBDemoGoal(minute: 70, isPrimarySide: true)], substitutions: [MBDemoSubstitution(minute: 60, isPrimarySide: true, outgoingShirt: 6, incomingShirt: 12), MBDemoSubstitution(minute: 78, isPrimarySide: true, outgoingShirt: 9, incomingShirt: 15)]))
        assembledFixtures.append(MBDemoFixture(isClubMatch: true, primaryOverrideName: nil, primaryOverrideSwatch: nil, rivalTeamName: "Eintracht Schönefeld", rivalSwatchIdentifier: "amber", groundName: "Sportpark Lindenau, Leipzig", kickoffComponents: DateComponents(year: 2026, month: 10, day: 4, hour: 11), diceSeed: 1004, phases: [MBDemoPhase(fromMinute: 25, toMinute: 35, primaryPressure: 0.5, rivalPressure: 0.25), MBDemoPhase(fromMinute: 59, toMinute: 71, primaryPressure: 0.12, rivalPressure: 0.62)], goals: [MBDemoGoal(minute: 30, isPrimarySide: true), MBDemoGoal(minute: 61, isPrimarySide: false), MBDemoGoal(minute: 69, isPrimarySide: false)], substitutions: [MBDemoSubstitution(minute: 72, isPrimarySide: true, outgoingShirt: 9, incomingShirt: 14)]))
        assembledFixtures.append(MBDemoFixture(isClubMatch: true, primaryOverrideName: nil, primaryOverrideSwatch: nil, rivalTeamName: "SG Plagwitz", rivalSwatchIdentifier: "teal", groundName: "Kunstrasen Plagwitz, Leipzig", kickoffComponents: DateComponents(year: 2026, month: 10, day: 11, hour: 14), diceSeed: 1110, phases: [MBDemoPhase(fromMinute: 28, toMinute: 38, primaryPressure: 0.2, rivalPressure: 0.5), MBDemoPhase(fromMinute: 50, toMinute: 58, primaryPressure: 0.5, rivalPressure: 0.25), MBDemoPhase(fromMinute: 59, toMinute: 66, primaryPressure: 0.12, rivalPressure: 0.6), MBDemoPhase(fromMinute: 66, toMinute: 90, primaryPressure: 0.62, rivalPressure: 0.2)], goals: [MBDemoGoal(minute: 33, isPrimarySide: false), MBDemoGoal(minute: 55, isPrimarySide: true), MBDemoGoal(minute: 62, isPrimarySide: false), MBDemoGoal(minute: 84, isPrimarySide: true)], substitutions: [MBDemoSubstitution(minute: 66, isPrimarySide: true, outgoingShirt: 11, incomingShirt: 14), MBDemoSubstitution(minute: 75, isPrimarySide: true, outgoingShirt: 7, incomingShirt: 13)]))
        assembledFixtures.append(MBDemoFixture(isClubMatch: false, primaryOverrideName: "Germany", primaryOverrideSwatch: "ink", rivalTeamName: "Netherlands", rivalSwatchIdentifier: "amber", groundName: "Düsseldorf Arena", kickoffComponents: DateComponents(year: 2026, month: 10, day: 13, hour: 20, minute: 45), diceSeed: 2026, phases: [MBDemoPhase(fromMinute: 0, toMinute: 20, primaryPressure: 0.45, rivalPressure: 0.3), MBDemoPhase(fromMinute: 30, toMinute: 45, primaryPressure: 0.25, rivalPressure: 0.5), MBDemoPhase(fromMinute: 55, toMinute: 70, primaryPressure: 0.5, rivalPressure: 0.3), MBDemoPhase(fromMinute: 75, toMinute: 90, primaryPressure: 0.3, rivalPressure: 0.5)], goals: [MBDemoGoal(minute: 14, isPrimarySide: true), MBDemoGoal(minute: 39, isPrimarySide: false), MBDemoGoal(minute: 61, isPrimarySide: true), MBDemoGoal(minute: 88, isPrimarySide: false)], substitutions: [MBDemoSubstitution(minute: 60, isPrimarySide: true, outgoingShirt: 0, incomingShirt: 0), MBDemoSubstitution(minute: 70, isPrimarySide: false, outgoingShirt: 0, incomingShirt: 0)]))
        assembledFixtures.append(MBDemoFixture(isClubMatch: true, primaryOverrideName: nil, primaryOverrideSwatch: nil, rivalTeamName: "VfK Mockau", rivalSwatchIdentifier: "tomato", groundName: "Sportpark Lindenau, Leipzig", kickoffComponents: DateComponents(year: 2026, month: 10, day: 25, hour: 11), diceSeed: 2510, phases: [MBDemoPhase(fromMinute: 10, toMinute: 22, primaryPressure: 0.5, rivalPressure: 0.25), MBDemoPhase(fromMinute: 62, toMinute: 69, primaryPressure: 0.18, rivalPressure: 0.5), MBDemoPhase(fromMinute: 72, toMinute: 85, primaryPressure: 0.5, rivalPressure: 0.25)], goals: [MBDemoGoal(minute: 17, isPrimarySide: true), MBDemoGoal(minute: 66, isPrimarySide: false), MBDemoGoal(minute: 77, isPrimarySide: true)], substitutions: [MBDemoSubstitution(minute: 68, isPrimarySide: true, outgoingShirt: 9, incomingShirt: 14)]))
        return assembledFixtures
    }

    static func sampleMatches(club: MBClub, keptPlayers: [MBPlayer]) -> [MBMatch] {
        return fixtures.map { fixture in
            return buildMatch(fixture: fixture, club: club, keptPlayers: keptPlayers)
        }
    }

    private static func buildMatch(fixture: MBDemoFixture, club: MBClub, keptPlayers: [MBPlayer]) -> MBMatch {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Berlin") ?? TimeZone.current
        let kickoffDate = calendar.date(from: fixture.kickoffComponents) ?? Date()
        var dice = MBSeededDice(seed: fixture.diceSeed)
        var generatedEvents: [MBMatchEvent] = []
        generateSlots(periodIndex: 0, periodSecond: 0, fixture: fixture, dice: &dice, generatedEvents: &generatedEvents)
        generateSlots(periodIndex: 1, periodSecond: 0, fixture: fixture, dice: &dice, generatedEvents: &generatedEvents)
        fixture.goals.forEach { demoGoal in
            let goalPlacement = placement(minute: demoGoal.minute, secondWithinMinute: 25)
            generatedEvents.append(MBMatchEvent(kindIdentifier: MBEventKind.danger.identifier, isPrimarySide: demoGoal.isPrimarySide, periodIndex: goalPlacement.periodIndex, periodSecond: max(0, goalPlacement.periodSecond - 20)))
            generatedEvents.append(MBMatchEvent(kindIdentifier: MBEventKind.goal.identifier, isPrimarySide: demoGoal.isPrimarySide, periodIndex: goalPlacement.periodIndex, periodSecond: goalPlacement.periodSecond))
        }
        fixture.substitutions.forEach { demoSubstitution in
            let substitutionPlacement = placement(minute: demoSubstitution.minute, secondWithinMinute: 5)
            let outgoingPlayer = fixture.isClubMatch ? squadPlayer(shirt: demoSubstitution.outgoingShirt, keptPlayers: keptPlayers) : nil
            let incomingPlayer = fixture.isClubMatch ? squadPlayer(shirt: demoSubstitution.incomingShirt, keptPlayers: keptPlayers) : nil
            generatedEvents.append(MBMatchEvent(kindIdentifier: MBEventKind.substitution.identifier, isPrimarySide: demoSubstitution.isPrimarySide, periodIndex: substitutionPlacement.periodIndex, periodSecond: substitutionPlacement.periodSecond, outgoingPlayerIdentifier: outgoingPlayer?.id, incomingPlayerIdentifier: incomingPlayer?.id))
        }
        let sortedEvents = generatedEvents.sorted { firstEvent, secondEvent in
            if (firstEvent.periodIndex != secondEvent.periodIndex) {
                return firstEvent.periodIndex < secondEvent.periodIndex
            }
            return firstEvent.periodSecond < secondEvent.periodSecond
        }
        let startingLineup = fixture.isClubMatch ? startingIdentifiers(keptPlayers: keptPlayers) : []
        let demoIdentifier = "mb-demo-match-\(fixture.diceSeed)"
        return MBMatch(id: demoIdentifier, kickoffDate: kickoffDate, isClubMatch: fixture.isClubMatch, primaryTeamName: fixture.primaryOverrideName ?? club.name, rivalTeamName: fixture.rivalTeamName, primarySwatchIdentifier: fixture.primaryOverrideSwatch ?? club.swatchIdentifier, rivalSwatchIdentifier: fixture.rivalSwatchIdentifier, groundName: fixture.groundName, format: MBMatchFormat.fullTime, events: sortedEvents, playedSecondsPerPeriod: demoPlayedSeconds, startingPlayerIdentifiers: startingLineup)
    }

    private static func generateSlots(periodIndex: Int, periodSecond: Int, fixture: MBDemoFixture, dice: inout MBSeededDice, generatedEvents: inout [MBMatchEvent]) {
        if (periodSecond >= demoPlayedSeconds[periodIndex]) {
            return
        }
        let nominalMinute = periodIndex * 45 + min(periodSecond / 60, 44)
        let activePhase = fixture.phases.first { demoPhase in
            return nominalMinute >= demoPhase.fromMinute && nominalMinute < demoPhase.toMinute
        }
        let primaryPressure = activePhase?.primaryPressure ?? restingPrimaryPressure
        let rivalPressure = activePhase?.rivalPressure ?? restingRivalPressure
        let slotRoll = dice.roll()
        let jitteredSecond = periodSecond + Int(dice.roll() * Double(slotSeconds - 1))
        if (slotRoll < primaryPressure * momentChancePerSlot) {
            generatedEvents.append(pressingMoment(pressingIsPrimary: true, periodIndex: periodIndex, periodSecond: jitteredSecond, kindRoll: dice.roll()))
        } else if (slotRoll < (primaryPressure + rivalPressure) * momentChancePerSlot) {
            generatedEvents.append(pressingMoment(pressingIsPrimary: false, periodIndex: periodIndex, periodSecond: jitteredSecond, kindRoll: dice.roll()))
        }
        generateSlots(periodIndex: periodIndex, periodSecond: periodSecond + slotSeconds, fixture: fixture, dice: &dice, generatedEvents: &generatedEvents)
    }

    private static func pressingMoment(pressingIsPrimary: Bool, periodIndex: Int, periodSecond: Int, kindRoll: Double) -> MBMatchEvent {
        if (kindRoll < 0.42) {
            return MBMatchEvent(kindIdentifier: MBEventKind.attack.identifier, isPrimarySide: pressingIsPrimary, periodIndex: periodIndex, periodSecond: periodSecond)
        } else if (kindRoll < 0.62) {
            return MBMatchEvent(kindIdentifier: MBEventKind.shot.identifier, isPrimarySide: pressingIsPrimary, periodIndex: periodIndex, periodSecond: periodSecond)
        } else if (kindRoll < 0.74) {
            return MBMatchEvent(kindIdentifier: MBEventKind.corner.identifier, isPrimarySide: pressingIsPrimary, periodIndex: periodIndex, periodSecond: periodSecond)
        } else if (kindRoll < 0.84) {
            return MBMatchEvent(kindIdentifier: MBEventKind.danger.identifier, isPrimarySide: pressingIsPrimary, periodIndex: periodIndex, periodSecond: periodSecond)
        }
        return MBMatchEvent(kindIdentifier: MBEventKind.loss.identifier, isPrimarySide: pressingIsPrimary == false, periodIndex: periodIndex, periodSecond: periodSecond)
    }

    private static func placement(minute: Int, secondWithinMinute: Int) -> (periodIndex: Int, periodSecond: Int) {
        let zeroBasedMinute = max(0, minute - 1)
        let periodIndex = min(zeroBasedMinute / 45, 1)
        return (periodIndex, (zeroBasedMinute - periodIndex * 45) * 60 + secondWithinMinute)
    }

    private static func squadPlayer(shirt: Int, keptPlayers: [MBPlayer]) -> MBPlayer? {
        let demoIdentifier = demoSquad.first { demoPlayer in
            return demoPlayer.shirtNumber == shirt
        }?.id
        return keptPlayers.first { keptPlayer in
            return keptPlayer.id == demoIdentifier
        }
    }

    private static func startingIdentifiers(keptPlayers: [MBPlayer]) -> [String] {
        let startingDemoIdentifiers = demoSquad.prefix(11).map { demoPlayer in
            return demoPlayer.id
        }
        return keptPlayers.map { keptPlayer in
            return keptPlayer.id
        }.filter { keptIdentifier in
            return startingDemoIdentifiers.contains(keptIdentifier)
        }
    }
}
