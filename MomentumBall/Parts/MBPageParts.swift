
import SwiftUI

struct MBScreenHeader: View {
    let kicker: String
    let title: String
    var trailingEmoji: String?

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                MBTagText(text: kicker, color: MBColors.inkSoft)
                Text(title.uppercased())
                    .font(MBTypography.poster(38))
                    .foregroundColor(MBColors.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            Spacer()
            if let trailingEmoji = trailingEmoji {
                MBEmojiBadge(emoji: trailingEmoji, fill: MBColors.accent, diameter: 46)
                    .rotationEffect(.degrees(-8))
            }
        }
    }
}

struct MBSectionTitle: View {
    let title: String
    var detail: String?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title.uppercased())
                .font(MBTypography.poster(22))
                .foregroundColor(MBColors.ink)
            Spacer()
            if let detail = detail {
                MBTagText(text: detail)
            }
        }
        .padding(.top, 8)
    }
}

struct MBEmptyState: View {
    let artworkName: String
    let fallbackEmoji: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            MBArtworkView(artworkName: artworkName, fallbackEmoji: fallbackEmoji, height: 150)
            Text(title)
                .font(MBTypography.poster(28))
                .foregroundColor(MBColors.ink)
                .multilineTextAlignment(.center)
            Text(message)
                .font(MBTypography.body(15))
                .foregroundColor(MBColors.inkSoft)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle) {
                    action()
                }
                .buttonStyle(MBStickerButtonStyle())
                .padding(.top, 4)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .mbSticker(fill: MBColors.card, cornerRadius: 26)
    }
}

struct MBStatTile: View {
    let emoji: String
    let value: String
    let caption: String
    var fill: Color = MBColors.card

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(emoji)
                .font(.system(size: 22))
            Text(value)
                .font(MBTypography.scoreboard(24))
                .foregroundColor(MBColors.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            MBTagText(text: caption, size: 10)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .mbSticker(fill: fill, cornerRadius: 18, depth: 3)
    }
}

struct MBBackButton: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button {
            MBHaptics.tick()
            dismiss()
        } label: {
            Image(systemName: MBTexts.symbolBack)
                .font(.system(size: 16, weight: .black))
                .foregroundColor(MBColors.ink)
                .frame(width: 42, height: 42)
                .background(Circle().fill(MBColors.card))
                .overlay(Circle().stroke(MBColors.outline, lineWidth: 2))
                .background(Circle().fill(MBColors.hardShadow).offset(x: 3, y: 3))
        }
        .buttonStyle(MBCardPressStyle())
    }
}

struct MBSheetHandleHeader: View {
    let title: String
    let onClose: () -> Void

    var body: some View {
        HStack {
            Text(title.uppercased())
                .font(MBTypography.poster(28))
                .foregroundColor(MBColors.ink)
            Spacer()
            Button {
                MBHaptics.tick()
                onClose()
            } label: {
                Image(systemName: MBTexts.symbolClose)
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(MBColors.ink)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(MBColors.paperDeep))
                    .overlay(Circle().stroke(MBColors.outline, lineWidth: 2))
            }
            .buttonStyle(MBCardPressStyle())
        }
    }
}

struct MBMomentumNumber: View {
    let value: Double?
    var size: CGFloat = 20

    var body: some View {
        Text(MBTexts.signedMomentum(value: value))
            .font(MBTypography.scoreboard(size))
            .foregroundColor(colorForValue)
    }

    private var colorForValue: Color {
        guard let value = value else {
            return MBColors.inkFaint
        }
        if (value > 0.05) {
            return MBColors.grassInk
        } else if (value < -0.05) {
            return MBColors.alarmInk
        }
        return MBColors.inkSoft
    }
}

struct MBLayout {
    static let readableMaximumWidth: CGFloat = 680
    static let tabBarMaximumWidth: CGFloat = 560
}

extension View {
    func mbScreenBackground() -> some View {
        return self.background(MBColors.paper.ignoresSafeArea())
    }

    func mbReadableWidth(maximumWidth: CGFloat = MBLayout.readableMaximumWidth) -> some View {
        return self.frame(maxWidth: maximumWidth).frame(maxWidth: .infinity)
    }
}
