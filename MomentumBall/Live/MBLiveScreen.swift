
import SwiftUI

struct MBLiveScreen: View {
    @EnvironmentObject private var ledger: MBLedger
    @EnvironmentObject private var liveSession: MBLiveSession
    @Binding var navigationPath: NavigationPath

    @State private var isSetupPresented = false
    @State private var setupStartsWithBroadcast = false

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                if (liveSession.hasMatchInProgress) {
                    MBLivePitch(onMatchArchived: openReport)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    lobby
                        .transition(.opacity)
                }
            }
            .animation(.spring(response: 0.45, dampingFraction: 0.85), value: liveSession.hasMatchInProgress)
            .mbScreenBackground()
            .toolbar(.hidden, for: .tabBar)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: MBReportRoute.self) { reportRoute in
                MBMatchReportScreen(matchIdentifier: reportRoute.matchIdentifier)
            }
            .sheet(isPresented: $isSetupPresented) {
                MBMatchSetupSheet(startsWithBroadcast: setupStartsWithBroadcast, onStart: beginMatch)
            }
        }
    }

    private var lobby: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                MBScreenHeader(kicker: MBTexts.liveLobbyKicker, title: MBTexts.liveLobbyTitle, trailingEmoji: MBTexts.emojiWhistle)
                kickoffCard
                HStack(spacing: 12) {
                    quickStartTile(emoji: MBTexts.emojiClubMode, title: MBTexts.setupTypeClub, startsWithBroadcast: false)
                    quickStartTile(emoji: MBTexts.emojiBroadcastMode, title: MBTexts.setupTypeBroadcast, startsWithBroadcast: true)
                }
                .fixedSize(horizontal: false, vertical: true)
                if let latestMatch = ledger.sortedMatches.first {
                    MBSectionTitle(title: MBTexts.liveLatestTitle)
                    NavigationLink(value: MBReportRoute(matchIdentifier: latestMatch.id)) {
                        MBMatchCard(match: latestMatch, memoryMinutes: ledger.memoryMinutes)
                    }
                    .buttonStyle(MBCardPressStyle())
                }
                MBSectionTitle(title: MBTexts.liveHowTitle)
                howItWorks
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 120)
            .mbReadableWidth()
        }
    }

    private var kickoffCard: some View {
        VStack(spacing: 14) {
            MBArtworkView(artworkName: MBArtworkNames.kickoff, fallbackEmoji: MBTexts.emojiBall, height: 150)
            Text(MBTexts.liveLobbyHeadline)
                .font(MBTypography.poster(30))
                .foregroundColor(MBColors.ink)
                .multilineTextAlignment(.center)
            Text(MBTexts.liveLobbyMessage)
                .font(MBTypography.body(14))
                .foregroundColor(MBColors.inkSoft)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Button(MBTexts.liveLobbyStart) {
                openSetup(startsWithBroadcast: ledger.club?.prefersBroadcastMatches ?? false)
            }
            .buttonStyle(MBStickerButtonStyle())
        }
        .padding(20)
        .mbSticker(fill: MBColors.card, cornerRadius: 26)
    }

    private func quickStartTile(emoji: String, title: String, startsWithBroadcast: Bool) -> some View {
        Button {
            openSetup(startsWithBroadcast: startsWithBroadcast)
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                Text(emoji)
                    .font(.system(size: 28))
                Text(title)
                    .font(MBTypography.strong(15))
                    .foregroundColor(MBColors.ink)
                    .multilineTextAlignment(.leading)
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .mbSticker(fill: startsWithBroadcast ? MBColors.skyPale : MBColors.mint, cornerRadius: 20)
        }
        .buttonStyle(MBCardPressStyle())
    }

    private var howItWorks: some View {
        VStack(alignment: .leading, spacing: 12) {
            howRow(emoji: MBTexts.emojiPointer, title: MBTexts.howTapTitle, detail: MBTexts.howTapDetail)
            howRow(emoji: MBTexts.emojiGoal, title: MBTexts.howHoldTitle, detail: MBTexts.howHoldDetail)
            howRow(emoji: MBTexts.emojiSwipe, title: MBTexts.howSwipeTitle, detail: MBTexts.howSwipeDetail)
            howRow(emoji: MBTexts.emojiWave, title: MBTexts.howWaveTitle, detail: MBTexts.howWaveDetail)
        }
        .padding(16)
        .mbSticker(fill: MBColors.card, cornerRadius: 22)
    }

    private func howRow(emoji: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            MBEmojiBadge(emoji: emoji, diameter: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(MBTypography.strong(15))
                    .foregroundColor(MBColors.ink)
                Text(detail)
                    .font(MBTypography.body(13))
                    .foregroundColor(MBColors.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func openSetup(startsWithBroadcast: Bool) {
        MBHaptics.tick()
        setupStartsWithBroadcast = startsWithBroadcast
        isSetupPresented = true
    }

    private func beginMatch(newMatch: MBMatch) {
        liveSession.begin(match: newMatch)
    }

    private func openReport(matchIdentifier: String) {
        navigationPath.append(MBReportRoute(matchIdentifier: matchIdentifier))
    }
}
