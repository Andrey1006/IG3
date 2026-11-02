
import SwiftUI

struct MBTeamPad: View {
    let teamName: String
    let swatch: MBTeamSwatch
    let goals: Int
    let isPrimarySide: Bool
    let compactLayout: Bool
    let onMoment: (MBEventKind, Bool) -> Bool
    let onSubstitution: (Bool) -> Void

    var body: some View {
        VStack(spacing: compactLayout ? 6 : 8) {
            padHeader
            VStack(spacing: compactLayout ? 6 : 8) {
                HStack(spacing: 8) {
                    ForEach(MBEventKind.padKinds.prefix(3), id: \.self) { eventKind in
                        padButton(eventKind: eventKind)
                    }
                }
                HStack(spacing: 8) {
                    ForEach(MBEventKind.padKinds.suffix(3), id: \.self) { eventKind in
                        padButton(eventKind: eventKind)
                    }
                }
            }
        }
        .padding(10)
        .background(mowingStripes.clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous)))
        .mbSticker(fill: swatch.paleColor, cornerRadius: 24, depth: 4)
    }

    private var padHeader: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(swatch.strongColor)
                .frame(width: 14, height: 14)
                .overlay(Circle().stroke(MBColors.outline, lineWidth: 1.5))
            Text(teamName.uppercased())
                .font(MBTypography.poster(compactLayout ? 16 : 19))
                .foregroundColor(MBColors.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text("\(goals)")
                .font(MBTypography.scoreboard(compactLayout ? 15 : 17))
                .foregroundColor(MBColors.onStrong)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Capsule().fill(swatch.strongColor))
                .overlay(Capsule().stroke(MBColors.outline, lineWidth: 1.5))
                .contentTransition(.numericText())
            Spacer(minLength: 4)
            Button {
                onSubstitution(isPrimarySide)
            } label: {
                Text(MBTexts.padSubstitution)
                    .font(MBTypography.tag(11))
                    .foregroundColor(MBColors.ink)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(MBColors.card))
                    .overlay(Capsule().stroke(MBColors.outline, lineWidth: 1.5))
            }
            .buttonStyle(MBCardPressStyle())
        }
    }

    private var mowingStripes: some View {
        HStack(spacing: 0) {
            ForEach(0..<8, id: \.self) { stripeIndex in
                Rectangle()
                    .fill(stripeIndex % 2 == 0 ? swatch.paleColor : swatch.stripeColor)
            }
        }
    }

    private func padButton(eventKind: MBEventKind) -> some View {
        MBPadButton(eventKind: eventKind, swatch: swatch, compactLayout: compactLayout, onFire: fireAction(eventKind: eventKind))
    }

    private func fireAction(eventKind: MBEventKind) -> () -> Bool {
        let sideIsPrimary = isPrimarySide
        let momentHandler = onMoment
        return {
            return momentHandler(eventKind, sideIsPrimary)
        }
    }
}

struct MBPadButton: View {
    let eventKind: MBEventKind
    let swatch: MBTeamSwatch
    let compactLayout: Bool
    let onFire: () -> Bool

    @State private var isPressed = false
    @State private var rippleLocation = CGPoint.zero
    @State private var rippleProgress: CGFloat = 1
    @State private var holdProgress: CGFloat = 0
    @State private var rejectionShake: CGFloat = 0
    @GestureState private var isHolding = false

    private let holdDuration = 0.6
    private let stickerDepth: CGFloat = 3

    var body: some View {
        let buttonOutline = RoundedRectangle(cornerRadius: 16, style: .continuous)
        let pressTravel: CGFloat = (isPressed || isHolding) ? stickerDepth : 0
        return buttonFace
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(buttonOutline.fill(eventKind.needsHoldToConfirm ? MBColors.accent : MBColors.card))
            .overlay(rippleLayer.clipShape(buttonOutline))
            .overlay(buttonOutline.stroke(MBColors.outline, lineWidth: 2))
            .offset(x: pressTravel + rejectionShake, y: pressTravel)
            .background(buttonOutline.fill(MBColors.hardShadow).offset(x: stickerDepth, y: stickerDepth))
            .contentShape(Rectangle())
            .gesture(padGesture)
            .onChange(of: isHolding) { holding in
                reactToHold(holding: holding)
            }
            .animation(.spring(response: 0.14, dampingFraction: 0.6), value: pressTravel)
    }

    private var buttonFace: some View {
        VStack(spacing: compactLayout ? 0 : 3) {
            ZStack {
                if (eventKind.needsHoldToConfirm) {
                    Circle()
                        .stroke(MBColors.ink.opacity(0.15), lineWidth: 4)
                        .frame(width: compactLayout ? 30 : 38, height: compactLayout ? 30 : 38)
                    Circle()
                        .trim(from: 0, to: holdProgress)
                        .stroke(MBColors.ink, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: compactLayout ? 30 : 38, height: compactLayout ? 30 : 38)
                }
                Text(eventKind.emoji)
                    .font(.system(size: compactLayout ? 17 : 22))
            }
            Text((eventKind.needsHoldToConfirm ? MBTexts.padHoldGoal : eventKind.title).uppercased())
                .font(MBTypography.tag(compactLayout ? 9 : 10))
                .tracking(0.8)
                .foregroundColor(MBColors.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 4)
    }

    private var rippleLayer: some View {
        Circle()
            .fill(swatch.strongColor.opacity(0.45))
            .frame(width: 70, height: 70)
            .scaleEffect(0.2 + rippleProgress * 2.4)
            .opacity(Double(1 - rippleProgress))
            .position(rippleLocation)
            .allowsHitTesting(false)
    }

    private var padGesture: AnyGesture<Void> {
        if (eventKind.needsHoldToConfirm) {
            return AnyGesture(holdGesture.map(MBPadButton.discardGestureValue))
        }
        return AnyGesture(tapGesture.map(MBPadButton.discardGestureValue))
    }

    nonisolated private static func discardGestureValue<GestureValue>(_ gestureValue: GestureValue) {
        return
    }

    private var tapGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { _ in
                if (isPressed == false) {
                    isPressed = true
                }
            }
            .onEnded { dragValue in
                isPressed = false
                fire(location: dragValue.location)
            }
    }

    private var holdGesture: some Gesture {
        LongPressGesture(minimumDuration: holdDuration, maximumDistance: 40)
            .updating($isHolding) { currentlyPressing, holdingState, _ in
                holdingState = currentlyPressing
            }
            .onEnded { _ in
                fire(location: CGPoint(x: 40, y: 30))
            }
    }

    private func reactToHold(holding: Bool) {
        if (holding) {
            MBHaptics.tick()
            withAnimation(.linear(duration: holdDuration)) {
                holdProgress = 1
            }
        } else {
            withAnimation(.easeOut(duration: 0.2)) {
                holdProgress = 0
            }
        }
    }

    private func fire(location: CGPoint) {
        let accepted = onFire()
        if (accepted == false) {
            withAnimation(.spring(response: 0.12, dampingFraction: 0.2)) {
                rejectionShake = 6
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                    rejectionShake = 0
                }
            }
            return
        }
        rippleLocation = location
        rippleProgress = 0
        withAnimation(.easeOut(duration: 0.5)) {
            rippleProgress = 1
        }
    }
}
