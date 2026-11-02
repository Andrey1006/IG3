
import SwiftUI

struct MBChipOption: Identifiable, Hashable {
    let identifier: String
    let title: String

    var id: String {
        return identifier
    }
}

struct MBChipRow: View {
    let options: [MBChipOption]
    @Binding var selectedIdentifier: String
    var fillsWidth = true
    var selectedFill: Color = MBColors.accent

    var body: some View {
        if (fillsWidth) {
            HStack(spacing: 8) {
                ForEach(options) { option in
                    chip(option: option)
                }
            }
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(options) { option in
                        chip(option: option)
                    }
                }
                .padding(.vertical, 4)
                .padding(.trailing, 6)
                .padding(.leading, 2)
            }
        }
    }

    private func chip(option: MBChipOption) -> some View {
        let isSelected = option.identifier == selectedIdentifier
        return Button {
            if (isSelected == false) {
                MBHaptics.tick()
                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                    selectedIdentifier = option.identifier
                }
            }
        } label: {
            Text(option.title)
                .font(MBTypography.strong(14))
                .foregroundColor(MBColors.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .frame(maxWidth: fillsWidth ? .infinity : nil)
                .mbSticker(fill: isSelected ? selectedFill : MBColors.card, cornerRadius: 14, depth: isSelected ? 0 : 3)
                .offset(x: isSelected ? 3 : 0, y: isSelected ? 3 : 0)
        }
        .buttonStyle(.plain)
    }
}

struct MBToggleSwitch: View {
    @Binding var isOn: Bool

    var body: some View {
        Button {
            MBHaptics.tick()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) {
                isOn.toggle()
            }
        } label: {
            ZStack(alignment: isOn ? .trailing : .leading) {
                Capsule()
                    .fill(isOn ? MBColors.grass : MBColors.paperDeep)
                    .frame(width: 58, height: 32)
                    .overlay(Capsule().stroke(MBColors.outline, lineWidth: 2))
                Text(isOn ? MBTexts.emojiToggleOn : MBTexts.emojiToggleOff)
                    .font(.system(size: 14))
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(MBColors.card))
                    .overlay(Circle().stroke(MBColors.outline, lineWidth: 2))
                    .padding(.horizontal, 4)
            }
        }
        .buttonStyle(.plain)
    }
}

struct MBTextField: View {
    let caption: String
    let placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            MBTagText(text: caption)
            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(MBColors.inkFaint))
                .font(MBTypography.strong(17))
                .foregroundColor(MBColors.ink)
                .keyboardType(keyboard)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled(true)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .mbSticker(fill: MBColors.card, cornerRadius: 16, depth: 3)
        }
    }
}

struct MBStepperDial: View {
    let caption: String
    let valueLabel: String
    let canDecrease: Bool
    let canIncrease: Bool
    let onDecrease: () -> Void
    let onIncrease: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            MBTagText(text: caption)
            Spacer()
            dialButton(symbol: MBTexts.symbolMinus, isEnabled: canDecrease, action: onDecrease)
            Text(valueLabel)
                .font(MBTypography.scoreboard(22))
                .foregroundColor(MBColors.ink)
                .frame(minWidth: 56)
                .contentTransition(.numericText())
            dialButton(symbol: MBTexts.symbolPlus, isEnabled: canIncrease, action: onIncrease)
        }
        .padding(14)
        .mbSticker(fill: MBColors.card, cornerRadius: 18, depth: 3)
    }

    private func dialButton(symbol: String, isEnabled: Bool, action: @escaping () -> Void) -> some View {
        Button {
            if (isEnabled) {
                MBHaptics.tick()
                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                    action()
                }
            } else {
                MBHaptics.rejected()
            }
        } label: {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .black))
                .foregroundColor(isEnabled ? MBColors.ink : MBColors.inkFaint)
                .frame(width: 38, height: 38)
                .background(Circle().fill(isEnabled ? MBColors.accent : MBColors.paperDeep))
                .overlay(Circle().stroke(MBColors.outline, lineWidth: 2))
        }
        .buttonStyle(MBCardPressStyle())
    }
}

struct MBSwatchPicker: View {
    @Binding var selectedIdentifier: String
    var blockedIdentifier: String?

    var body: some View {
        let swatchColumns = [GridItem(.adaptive(minimum: 46), spacing: 10)]
        return LazyVGrid(columns: swatchColumns, spacing: 10) {
            ForEach(MBColors.teamSwatches) { swatch in
                swatchDot(swatch: swatch)
            }
        }
    }

    private func swatchDot(swatch: MBTeamSwatch) -> some View {
        let isSelected = swatch.identifier == selectedIdentifier
        let isBlocked = swatch.identifier == blockedIdentifier
        return Button {
            if (isBlocked) {
                MBHaptics.rejected()
            } else {
                MBHaptics.tick()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    selectedIdentifier = swatch.identifier
                }
            }
        } label: {
            ZStack {
                Circle()
                    .fill(swatch.strongColor)
                    .frame(width: 42, height: 42)
                    .overlay(Circle().stroke(MBColors.outline, lineWidth: 2))
                if (isSelected) {
                    Image(systemName: MBTexts.symbolCheck)
                        .font(.system(size: 15, weight: .black))
                        .foregroundColor(MBColors.onStrong)
                }
                if (isBlocked) {
                    Image(systemName: MBTexts.symbolBlocked)
                        .font(.system(size: 15, weight: .black))
                        .foregroundColor(MBColors.onStrong.opacity(0.8))
                }
            }
            .scaleEffect(isSelected ? 1.12 : 1)
            .opacity(isBlocked ? 0.45 : 1)
        }
        .buttonStyle(.plain)
    }
}
