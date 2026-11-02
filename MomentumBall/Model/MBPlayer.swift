
import Foundation

struct MBPlayerRole: Hashable, Identifiable {
    let identifier: String
    let title: String
    let emoji: String

    var id: String {
        return identifier
    }

    static let goalkeeper = MBPlayerRole(identifier: "gk", title: MBTexts.roleGoalkeeper, emoji: MBTexts.emojiGoalkeeper)
    static let defender = MBPlayerRole(identifier: "df", title: MBTexts.roleDefender, emoji: MBTexts.emojiDefender)
    static let midfielder = MBPlayerRole(identifier: "mf", title: MBTexts.roleMidfielder, emoji: MBTexts.emojiMidfielder)
    static let forward = MBPlayerRole(identifier: "fw", title: MBTexts.roleForward, emoji: MBTexts.emojiForward)
    static let everyRole: [MBPlayerRole] = [goalkeeper, defender, midfielder, forward]

    static func resolve(identifier: String) -> MBPlayerRole {
        let matchingRole = everyRole.first { candidateRole in
            return candidateRole.identifier == identifier
        }
        return matchingRole ?? midfielder
    }
}

struct MBPlayer: Identifiable, Hashable {
    let id: String
    var fullName: String
    var shirtNumber: Int
    var roleIdentifier: String

    var role: MBPlayerRole {
        return MBPlayerRole.resolve(identifier: roleIdentifier)
    }

    var shortName: String {
        let nameParts = fullName.split(separator: " ")
        if (nameParts.count < 2) {
            return fullName
        }
        return "\(nameParts[0].prefix(1)). \(nameParts[nameParts.count - 1])"
    }

    init(id: String = UUID().uuidString, fullName: String, shirtNumber: Int, roleIdentifier: String) {
        self.id = id
        self.fullName = fullName
        self.shirtNumber = shirtNumber
        self.roleIdentifier = roleIdentifier
    }

    init?(plistDictionary: [String: Any]) {
        guard let storedIdentifier = plistDictionary["id"] as? String, let storedName = plistDictionary["name"] as? String else {
            return nil
        }
        self.init(id: storedIdentifier, fullName: storedName, shirtNumber: plistDictionary["number"] as? Int ?? 0, roleIdentifier: plistDictionary["role"] as? String ?? MBPlayerRole.midfielder.identifier)
    }

    var plistDictionary: [String: Any] {
        return ["id": id, "name": fullName, "number": shirtNumber, "role": roleIdentifier]
    }
}
