
import Foundation
import Combine

@MainActor
final class MBLedger: ObservableObject {
    @Published private(set) var club: MBClub?
    @Published private(set) var players: [MBPlayer] = []
    @Published private(set) var matches: [MBMatch] = []

    private let defaults = UserDefaults.standard
    private let ledgerStorageKey = "momentumball.ledger"
    private let ledgerFormatVersion = 1

    init() {
        restore()
    }

    var sortedMatches: [MBMatch] {
        return matches.sorted { firstMatch, secondMatch in
            return firstMatch.kickoffDate > secondMatch.kickoffDate
        }
    }

    var memoryMinutes: Int {
        return club?.waveMemoryMinutes ?? MBClub.standardWaveMemoryMinutes
    }

    func match(identifier: String) -> MBMatch? {
        return matches.first { storedMatch in
            return storedMatch.id == identifier
        }
    }

    func player(identifier: String?) -> MBPlayer? {
        guard let identifier = identifier else {
            return nil
        }
        return players.first { storedPlayer in
            return storedPlayer.id == identifier
        }
    }

    func playersSortedForSheet() -> [MBPlayer] {
        return players.sorted { firstPlayer, secondPlayer in
            return firstPlayer.shirtNumber < secondPlayer.shirtNumber
        }
    }

    func completeOnboarding(club: MBClub, players: [MBPlayer], includeSampleSeason: Bool) {
        self.club = club
        self.players = players
        if (includeSampleSeason) {
            self.matches = MBDemoSeason.sampleMatches(club: club, keptPlayers: players)
        } else {
            self.matches = []
        }
        persist()
    }

    func updateClub(_ updatedClub: MBClub) {
        club = updatedClub
        persist()
    }

    func savePlayer(_ player: MBPlayer) {
        let existingIndex = players.firstIndex { storedPlayer in
            return storedPlayer.id == player.id
        }
        if let existingIndex = existingIndex {
            players[existingIndex] = player
        } else {
            players.append(player)
        }
        persist()
    }

    func removePlayer(identifier: String) {
        players.removeAll { storedPlayer in
            return storedPlayer.id == identifier
        }
        persist()
    }

    func archiveMatch(_ finishedMatch: MBMatch) {
        matches.removeAll { storedMatch in
            return storedMatch.id == finishedMatch.id
        }
        matches.append(finishedMatch)
        persist()
    }

    func removeMatch(identifier: String) {
        matches.removeAll { storedMatch in
            return storedMatch.id == identifier
        }
        persist()
    }

    func wipeMatchArchive() {
        matches = []
        persist()
    }

    func resetEverything() {
        club = nil
        players = []
        matches = []
        defaults.removeObject(forKey: ledgerStorageKey)
    }

    private func persist() {
        guard let club = club else {
            defaults.removeObject(forKey: ledgerStorageKey)
            return
        }
        let encodedPlayers = players.map { player in
            return player.plistDictionary
        }
        let encodedMatches = matches.map { match in
            return match.plistDictionary
        }
        let ledgerSnapshot: [String: Any] = ["version": ledgerFormatVersion, "club": club.plistDictionary, "players": encodedPlayers, "matches": encodedMatches]
        defaults.set(ledgerSnapshot, forKey: ledgerStorageKey)
    }

    private func restore() {
        guard let ledgerSnapshot = defaults.dictionary(forKey: ledgerStorageKey) else {
            return
        }
        let storedVersion = ledgerSnapshot["version"] as? Int ?? 0
        guard storedVersion <= ledgerFormatVersion, let restoredClub = MBClub(plistDictionary: ledgerSnapshot["club"] as? [String: Any]) else {
            defaults.removeObject(forKey: ledgerStorageKey)
            return
        }
        club = restoredClub
        players = MBPlistList.decode(rawValue: ledgerSnapshot["players"]) { playerDictionary in
            return MBPlayer(plistDictionary: playerDictionary)
        }
        matches = MBPlistList.decode(rawValue: ledgerSnapshot["matches"]) { matchDictionary in
            return MBMatch(plistDictionary: matchDictionary)
        }
    }
}
