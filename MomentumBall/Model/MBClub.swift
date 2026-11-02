
import Foundation

struct MBTrackingMode: Hashable, Identifiable {
    let identifier: String
    let title: String
    let detail: String
    let emoji: String

    var id: String {
        return identifier
    }

    static let ownClub = MBTrackingMode(identifier: "club", title: MBTexts.modeClubTitle, detail: MBTexts.modeClubDetail, emoji: MBTexts.emojiClubMode)
    static let broadcast = MBTrackingMode(identifier: "broadcast", title: MBTexts.modeBroadcastTitle, detail: MBTexts.modeBroadcastDetail, emoji: MBTexts.emojiBroadcastMode)
    static let both = MBTrackingMode(identifier: "both", title: MBTexts.modeBothTitle, detail: MBTexts.modeBothDetail, emoji: MBTexts.emojiBothMode)
    static let everyMode: [MBTrackingMode] = [ownClub, broadcast, both]
}

struct MBClub: Hashable {
    var name: String
    var swatchIdentifier: String
    var format: MBMatchFormat
    var trackingModeIdentifier: String
    var hapticsEnabled: Bool
    var waveMemoryMinutes: Int
    var foundedInAppDate: Date

    static let waveMemoryChoices = [2, 3, 5]
    static let standardWaveMemoryMinutes = 3

    var swatch: MBTeamSwatch {
        return MBTeamSwatch.resolve(identifier: swatchIdentifier)
    }

    var prefersBroadcastMatches: Bool {
        return trackingModeIdentifier == MBTrackingMode.broadcast.identifier
    }

    init(name: String, swatchIdentifier: String, format: MBMatchFormat, trackingModeIdentifier: String, hapticsEnabled: Bool = true, waveMemoryMinutes: Int = MBClub.standardWaveMemoryMinutes, foundedInAppDate: Date = Date()) {
        self.name = name
        self.swatchIdentifier = swatchIdentifier
        self.format = format
        self.trackingModeIdentifier = trackingModeIdentifier
        self.hapticsEnabled = hapticsEnabled
        self.waveMemoryMinutes = waveMemoryMinutes
        self.foundedInAppDate = foundedInAppDate
    }

    init?(plistDictionary: [String: Any]?) {
        guard let plistDictionary = plistDictionary, let storedName = plistDictionary["name"] as? String else {
            return nil
        }
        let storedMemory = plistDictionary["memory"] as? Int ?? MBClub.standardWaveMemoryMinutes
        let safeMemory = MBClub.waveMemoryChoices.contains(storedMemory) ? storedMemory : MBClub.standardWaveMemoryMinutes
        let storedFounded = plistDictionary["founded"] as? Double ?? Date().timeIntervalSince1970
        self.init(name: storedName, swatchIdentifier: plistDictionary["swatch"] as? String ?? MBColors.defaultPrimarySwatchIdentifier, format: MBMatchFormat(plistDictionary: plistDictionary["format"] as? [String: Any]), trackingModeIdentifier: plistDictionary["mode"] as? String ?? MBTrackingMode.ownClub.identifier, hapticsEnabled: plistDictionary["haptics"] as? Bool ?? true, waveMemoryMinutes: safeMemory, foundedInAppDate: Date(timeIntervalSince1970: storedFounded))
    }

    var plistDictionary: [String: Any] {
        return ["name": name, "swatch": swatchIdentifier, "format": format.plistDictionary, "mode": trackingModeIdentifier, "haptics": hapticsEnabled, "memory": waveMemoryMinutes, "founded": foundedInAppDate.timeIntervalSince1970]
    }
}
