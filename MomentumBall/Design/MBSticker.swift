
import SwiftUI

struct MBStickerModifier: ViewModifier {
    let fillColor: Color
    let cornerRadius: CGFloat
    let shadowDepth: CGFloat

    func body(content: Content) -> some View {
        let stickerOutline = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        return content
            .background(stickerOutline.fill(fillColor))
            .overlay(stickerOutline.stroke(MBColors.outline, lineWidth: 2))
            .background(stickerOutline.fill(MBColors.hardShadow).offset(x: shadowDepth, y: shadowDepth))
    }
}

extension View {
    func mbSticker(fill: Color = MBColors.card, cornerRadius: CGFloat = 20, depth: CGFloat = 4) -> some View {
        return modifier(MBStickerModifier(fillColor: fill, cornerRadius: cornerRadius, shadowDepth: depth))
    }
}

struct MBStickerButtonStyle: ButtonStyle {
    var fillColor: Color = MBColors.accent
    var textColor: Color = MBColors.ink
    var verticalPadding: CGFloat = 16
    var expandsHorizontally = true
    private let stickerDepth: CGFloat = 4

    func makeBody(configuration: Configuration) -> some View {
        let pressTravel: CGFloat = configuration.isPressed ? stickerDepth : 0
        let buttonOutline = RoundedRectangle(cornerRadius: 16, style: .continuous)
        return configuration.label
            .font(MBTypography.button())
            .foregroundColor(textColor)
            .frame(maxWidth: expandsHorizontally ? .infinity : nil)
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, 18)
            .background(buttonOutline.fill(fillColor))
            .overlay(buttonOutline.stroke(MBColors.outline, lineWidth: 2))
            .offset(x: pressTravel, y: pressTravel)
            .background(buttonOutline.fill(MBColors.hardShadow).offset(x: stickerDepth, y: stickerDepth))
            .animation(.spring(response: 0.16, dampingFraction: 0.55), value: configuration.isPressed)
    }
}

struct MBCardPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let pressTravel: CGFloat = configuration.isPressed ? 3 : 0
        return configuration.label
            .offset(x: pressTravel, y: pressTravel)
            .animation(.spring(response: 0.18, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct MBEmojiBadge: View {
    let emoji: String
    var fill: Color = MBColors.paperDeep
    var diameter: CGFloat = 40

    var body: some View {
        Text(emoji)
            .font(.system(size: diameter * 0.5))
            .frame(width: diameter, height: diameter)
            .background(Circle().fill(fill))
            .overlay(Circle().stroke(MBColors.outline, lineWidth: 2))
    }
}
