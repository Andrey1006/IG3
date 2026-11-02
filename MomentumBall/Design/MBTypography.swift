
import SwiftUI

struct MBTypography {
    static func poster(_ size: CGFloat) -> Font {
        return Font.system(size: size, weight: .black, design: .default).width(.condensed)
    }

    static func scoreboard(_ size: CGFloat) -> Font {
        return Font.system(size: size, weight: .heavy, design: .rounded).monospacedDigit()
    }

    static func tag(_ size: CGFloat = 11) -> Font {
        return Font.system(size: size, weight: .bold, design: .rounded)
    }

    static func body(_ size: CGFloat = 15) -> Font {
        return Font.system(size: size, weight: .medium, design: .default)
    }

    static func strong(_ size: CGFloat = 16) -> Font {
        return Font.system(size: size, weight: .bold, design: .rounded)
    }

    static func button() -> Font {
        return Font.system(size: 17, weight: .heavy, design: .rounded)
    }
}

struct MBTagText: View {
    let text: String
    var color: Color = MBColors.inkSoft
    var size: CGFloat = 11

    var body: some View {
        Text(text.uppercased())
            .font(MBTypography.tag(size))
            .tracking(1.4)
            .foregroundColor(color)
    }
}
