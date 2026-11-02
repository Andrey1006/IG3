
import SwiftUI

struct MBTabItem: Identifiable, Hashable {
    let identifier: String
    let title: String
    let artworkName: String
    let fallbackSymbol: String

    var id: String {
        return identifier
    }

    static let archive = MBTabItem(identifier: "archive", title: MBTexts.tabArchive, artworkName: MBArtworkNames.tabArchive, fallbackSymbol: MBArtworkNames.tabArchiveSymbol)
    static let season = MBTabItem(identifier: "season", title: MBTexts.tabSeason, artworkName: MBArtworkNames.tabSeason, fallbackSymbol: MBArtworkNames.tabSeasonSymbol)
    static let live = MBTabItem(identifier: "live", title: MBTexts.tabLive, artworkName: MBArtworkNames.tabLive, fallbackSymbol: MBArtworkNames.tabLiveSymbol)
    static let squad = MBTabItem(identifier: "squad", title: MBTexts.tabSquad, artworkName: MBArtworkNames.tabSquad, fallbackSymbol: MBArtworkNames.tabSquadSymbol)
    static let club = MBTabItem(identifier: "club", title: MBTexts.tabClub, artworkName: MBArtworkNames.tabClub, fallbackSymbol: MBArtworkNames.tabClubSymbol)
    static let orderedItems: [MBTabItem] = [archive, season, live, squad, club]
}

struct MBShellView: View {
    @EnvironmentObject private var liveSession: MBLiveSession
    @State private var selectedTabIdentifier = MBTabItem.live.identifier
    @State private var archivePath = NavigationPath()
    @State private var seasonPath = NavigationPath()
    @State private var livePath = NavigationPath()
    @State private var squadPath = NavigationPath()
    @State private var clubPath = NavigationPath()

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTabIdentifier) {
                MBArchiveScreen(navigationPath: $archivePath)
                    .tag(MBTabItem.archive.identifier)
                MBSeasonScreen(navigationPath: $seasonPath)
                    .tag(MBTabItem.season.identifier)
                MBLiveScreen(navigationPath: $livePath)
                    .tag(MBTabItem.live.identifier)
                MBSquadScreen(navigationPath: $squadPath)
                    .tag(MBTabItem.squad.identifier)
                MBClubScreen(navigationPath: $clubPath)
                    .tag(MBTabItem.club.identifier)
            }
            if (isTabBarVisible) {
                MBTabBar(selectedTabIdentifier: $selectedTabIdentifier, showsLiveBadge: liveSession.hasMatchInProgress)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 6)
                    .mbReadableWidth(maximumWidth: MBLayout.tabBarMaximumWidth)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isTabBarVisible)
    }

    private var isTabBarVisible: Bool {
        if (selectedTabIdentifier == MBTabItem.archive.identifier) {
            return archivePath.isEmpty
        } else if (selectedTabIdentifier == MBTabItem.season.identifier) {
            return seasonPath.isEmpty
        } else if (selectedTabIdentifier == MBTabItem.live.identifier) {
            return livePath.isEmpty
        } else if (selectedTabIdentifier == MBTabItem.squad.identifier) {
            return squadPath.isEmpty
        }
        return clubPath.isEmpty
    }
}

struct MBTabBar: View {
    @Binding var selectedTabIdentifier: String
    let showsLiveBadge: Bool

    var body: some View {
        HStack(spacing: 4) {
            ForEach(MBTabItem.orderedItems) { tabItem in
                tabButton(tabItem: tabItem)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .mbSticker(fill: MBColors.card, cornerRadius: 26, depth: 4)
    }

    private func tabButton(tabItem: MBTabItem) -> some View {
        let isSelected = tabItem.identifier == selectedTabIdentifier
        let showsBadge = tabItem.identifier == MBTabItem.live.identifier && showsLiveBadge
        return Button {
            if (isSelected == false) {
                MBHaptics.tick()
                selectedTabIdentifier = tabItem.identifier
            }
        } label: {
            VStack(spacing: 3) {
                ZStack(alignment: .topTrailing) {
                    MBTabGlyph(artworkName: tabItem.artworkName, fallbackSymbol: tabItem.fallbackSymbol, tint: MBColors.ink)
                        .frame(width: 44, height: 30)
                        .background(Capsule().fill(isSelected ? MBColors.accent : Color.clear))
                        .overlay(Capsule().stroke(isSelected ? MBColors.outline : Color.clear, lineWidth: 1.5))
                    if (showsBadge) {
                        Circle()
                            .fill(MBColors.alarm)
                            .frame(width: 10, height: 10)
                            .overlay(Circle().stroke(MBColors.card, lineWidth: 2))
                            .offset(x: 2, y: -2)
                    }
                }
                Text(tabItem.title)
                    .font(MBTypography.tag(10))
                    .foregroundColor(isSelected ? MBColors.ink : MBColors.inkSoft)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}
