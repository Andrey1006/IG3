
import SwiftUI

extension Color {
    init(mbHex: UInt32, opacity: Double = 1) {
        let redComponent = Double((mbHex >> 16) & 0xFF) / 255
        let greenComponent = Double((mbHex >> 8) & 0xFF) / 255
        let blueComponent = Double(mbHex & 0xFF) / 255
        self.init(.sRGB, red: redComponent, green: greenComponent, blue: blueComponent, opacity: opacity)
    }
}

struct MBTeamSwatch: Identifiable, Hashable {
    let identifier: String
    let strongColor: Color
    let paleColor: Color
    let stripeColor: Color

    var id: String {
        return identifier
    }

    static func resolve(identifier: String) -> MBTeamSwatch {
        return findSwatch(identifier: identifier, remainingSwatches: MBColors.teamSwatches[...])
    }

    private static func findSwatch(identifier: String, remainingSwatches: ArraySlice<MBTeamSwatch>) -> MBTeamSwatch {
        guard let candidateSwatch = remainingSwatches.first else {
            return MBColors.teamSwatches[0]
        }
        if (candidateSwatch.identifier == identifier) {
            return candidateSwatch
        }
        return findSwatch(identifier: identifier, remainingSwatches: remainingSwatches.dropFirst())
    }
}
