
import SwiftUI

struct MBClubScreen: View {
    @EnvironmentObject private var ledger: MBLedger
    @EnvironmentObject private var liveSession: MBLiveSession
    @Binding var navigationPath: NavigationPath

    @State private var isClubEditorPresented = false
    @State private var isWipeAlertPresented = false
    @State private var isResetAlertPresented = false

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    MBScreenHeader(kicker: MBTexts.clubKicker, title: MBTexts.clubTitle, trailingEmoji: MBTexts.emojiCrest)
                    if let club = ledger.club {
                        clubCard(club: club)
                        MBSectionTitle(title: MBTexts.clubSettingsTitle)
                        hapticsRow()
                        memoryRow()
                        MBSectionTitle(title: MBTexts.clubDataTitle)
                        actionRow(emoji: MBTexts.emojiBroom, title: MBTexts.clubWipeArchive, detail: MBTexts.clubWipeArchiveDetail(count: ledger.matches.count), fill: MBColors.card, action: askToWipe)
                        actionRow(emoji: MBTexts.emojiReset, title: MBTexts.clubReset, detail: MBTexts.clubResetDetail, fill: MBColors.alarmPale, action: askToReset)
                        MBTagText(text: MBTexts.clubVersion(version: appVersion), size: 9)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 120)
                .mbReadableWidth()
            }
            .mbScreenBackground()
            .toolbar(.hidden, for: .tabBar)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $isClubEditorPresented) {
                MBClubEditorSheet()
            }
            .alert(MBTexts.clubWipeAlertTitle, isPresented: $isWipeAlertPresented) {
                Button(MBTexts.clubWipeConfirm, role: .destructive) {
                    wipeArchive()
                }
                Button(MBTexts.actionCancel, role: .cancel) {
                    MBHaptics.tick()
                }
            } message: {
                Text(MBTexts.clubWipeAlertMessage)
            }
            .alert(MBTexts.clubResetAlertTitle, isPresented: $isResetAlertPresented) {
                Button(MBTexts.clubResetConfirm, role: .destructive) {
                    resetClub()
                }
                Button(MBTexts.actionCancel, role: .cancel) {
                    MBHaptics.tick()
                }
            } message: {
                Text(MBTexts.clubResetAlertMessage)
            }
        }
    }

    private var appVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    private func clubCard(club: MBClub) -> some View {
        let trackingMode = MBTrackingMode.everyMode.first { candidateMode in
            return candidateMode.identifier == club.trackingModeIdentifier
        }
        return VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Circle()
                    .fill(club.swatch.strongColor)
                    .frame(width: 34, height: 34)
                    .overlay(Circle().stroke(MBColors.outline, lineWidth: 2))
                Text(club.name.uppercased())
                    .font(MBTypography.poster(28))
                    .foregroundColor(MBColors.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            HStack(spacing: 8) {
                clubBadge(text: club.format.title)
                clubBadge(text: "\(trackingMode?.emoji ?? "") \(trackingMode?.title ?? "")")
                clubBadge(text: MBTexts.playerCount(count: ledger.players.count))
            }
            Button(MBTexts.clubEdit) {
                MBHaptics.tick()
                isClubEditorPresented = true
            }
            .buttonStyle(MBStickerButtonStyle(fillColor: MBColors.card, verticalPadding: 12))
        }
        .padding(18)
        .mbSticker(fill: club.swatch.paleColor, cornerRadius: 26)
    }

    private func clubBadge(text: String) -> some View {
        Text(text)
            .font(MBTypography.tag(11))
            .foregroundColor(MBColors.ink)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(MBColors.card))
            .overlay(Capsule().stroke(MBColors.outline, lineWidth: 1.5))
    }

    private func hapticsRow() -> some View {
        HStack(spacing: 12) {
            MBEmojiBadge(emoji: MBTexts.emojiHaptics, diameter: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(MBTexts.clubHaptics)
                    .font(MBTypography.strong(15))
                    .foregroundColor(MBColors.ink)
                Text(MBTexts.clubHapticsDetail)
                    .font(MBTypography.body(12))
                    .foregroundColor(MBColors.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            MBToggleSwitch(isOn: hapticsBinding())
        }
        .padding(14)
        .mbSticker(fill: MBColors.card, cornerRadius: 20, depth: 3)
    }

    private func memoryRow() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                MBEmojiBadge(emoji: MBTexts.emojiWave, diameter: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text(MBTexts.clubMemory)
                        .font(MBTypography.strong(15))
                        .foregroundColor(MBColors.ink)
                    Text(MBTexts.clubMemoryDetail)
                        .font(MBTypography.body(12))
                        .foregroundColor(MBColors.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            MBChipRow(options: memoryOptions, selectedIdentifier: memoryBinding())
        }
        .padding(14)
        .mbSticker(fill: MBColors.card, cornerRadius: 20, depth: 3)
    }

    private var memoryOptions: [MBChipOption] {
        return MBClub.waveMemoryChoices.map { memoryMinutes in
            return MBChipOption(identifier: "\(memoryMinutes)", title: MBTexts.memoryChoice(minutes: memoryMinutes))
        }
    }

    private func hapticsBinding() -> Binding<Bool> {
        return Binding(get: readHapticsSetting, set: writeHapticsSetting)
    }

    private func readHapticsSetting() -> Bool {
        return ledger.club?.hapticsEnabled ?? true
    }

    private func writeHapticsSetting(isEnabled: Bool) {
        guard var updatedClub = ledger.club else {
            return
        }
        updatedClub.hapticsEnabled = isEnabled
        MBHaptics.isEnabled = isEnabled
        ledger.updateClub(updatedClub)
    }

    private func memoryBinding() -> Binding<String> {
        return Binding(get: readMemorySetting, set: writeMemorySetting)
    }

    private func readMemorySetting() -> String {
        return "\(ledger.memoryMinutes)"
    }

    private func writeMemorySetting(identifier: String) {
        guard var updatedClub = ledger.club, let chosenMinutes = Int(identifier) else {
            return
        }
        updatedClub.waveMemoryMinutes = chosenMinutes
        ledger.updateClub(updatedClub)
    }

    private func actionRow(emoji: String, title: String, detail: String, fill: Color, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack(spacing: 12) {
                MBEmojiBadge(emoji: emoji, diameter: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(MBTypography.strong(15))
                        .foregroundColor(MBColors.ink)
                    Text(detail)
                        .font(MBTypography.body(12))
                        .foregroundColor(MBColors.inkSoft)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                Image(systemName: MBTexts.symbolForward)
                    .font(.system(size: 13, weight: .black))
                    .foregroundColor(MBColors.ink)
            }
            .padding(14)
            .mbSticker(fill: fill, cornerRadius: 20, depth: 3)
        }
        .buttonStyle(MBCardPressStyle())
    }

    private func askToWipe() {
        MBHaptics.tick()
        isWipeAlertPresented = true
    }

    private func askToReset() {
        MBHaptics.tick()
        isResetAlertPresented = true
    }

    private func wipeArchive() {
        MBHaptics.rejected()
        ledger.wipeMatchArchive()
    }

    private func resetClub() {
        MBHaptics.rejected()
        liveSession.discard()
        withAnimation(.easeInOut(duration: 0.35)) {
            ledger.resetEverything()
        }
    }
}
