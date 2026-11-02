
import Foundation

struct MBMatchEvent: Identifiable, Hashable {
    let id: String
    let kindIdentifier: String
    let isPrimarySide: Bool
    let periodIndex: Int
    let periodSecond: Int
    var outgoingPlayerIdentifier: String?
    var incomingPlayerIdentifier: String?

    var kind: MBEventKind {
        return MBEventKind.resolve(identifier: kindIdentifier)
    }

    var favoursPrimarySide: Bool {
        return isPrimarySide != kind.swingsToOpponent
    }

    init(id: String = UUID().uuidString, kindIdentifier: String, isPrimarySide: Bool, periodIndex: Int, periodSecond: Int, outgoingPlayerIdentifier: String? = nil, incomingPlayerIdentifier: String? = nil) {
        self.id = id
        self.kindIdentifier = kindIdentifier
        self.isPrimarySide = isPrimarySide
        self.periodIndex = periodIndex
        self.periodSecond = periodSecond
        self.outgoingPlayerIdentifier = outgoingPlayerIdentifier
        self.incomingPlayerIdentifier = incomingPlayerIdentifier
    }

    init?(plistDictionary: [String: Any]) {
        guard let storedIdentifier = plistDictionary["id"] as? String, let storedKind = plistDictionary["kind"] as? String, let storedSide = plistDictionary["primary"] as? Bool, let storedPeriod = plistDictionary["period"] as? Int, let storedSecond = plistDictionary["second"] as? Int else {
            return nil
        }
        self.init(id: storedIdentifier, kindIdentifier: storedKind, isPrimarySide: storedSide, periodIndex: storedPeriod, periodSecond: storedSecond, outgoingPlayerIdentifier: plistDictionary["out"] as? String, incomingPlayerIdentifier: plistDictionary["in"] as? String)
    }

    var plistDictionary: [String: Any] {
        var storedFields: [String: Any] = ["id": id, "kind": kindIdentifier, "primary": isPrimarySide, "period": periodIndex, "second": periodSecond]
        if let outgoingPlayerIdentifier = outgoingPlayerIdentifier {
            storedFields["out"] = outgoingPlayerIdentifier
        }
        if let incomingPlayerIdentifier = incomingPlayerIdentifier {
            storedFields["in"] = incomingPlayerIdentifier
        }
        return storedFields
    }
}
