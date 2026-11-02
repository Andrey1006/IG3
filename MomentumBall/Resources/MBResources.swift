
import SwiftUI

struct MBColors {
    static let paper = Color(mbHex: 0xF4EFE4)
    static let paperDeep = Color(mbHex: 0xE7DDC8)
    static let card = Color(mbHex: 0xFFFCF4)
    static let ink = Color(mbHex: 0x1C1B29)
    static let inkSoft = Color(mbHex: 0x5F5B70)
    static let inkFaint = Color(mbHex: 0xA59F92)
    static let outline = Color(mbHex: 0x1C1B29)
    static let hardShadow = Color(mbHex: 0x1C1B29)
    static let onStrong = Color(mbHex: 0xFFFCF4)
    static let accent = Color(mbHex: 0xFF8A1F)
    static let grass = Color(mbHex: 0x37A34A)
    static let grassInk = Color(mbHex: 0x1F7A33)
    static let mint = Color(mbHex: 0xCFEFD6)
    static let alarm = Color(mbHex: 0xE5484D)
    static let alarmInk = Color(mbHex: 0xC0262D)
    static let alarmPale = Color(mbHex: 0xFBD9D6)
    static let skyPale = Color(mbHex: 0xD4E4FB)
    static let splashBackdrop = Color(mbHex: 0xF4EFE4)
    static let splashBall = Color(mbHex: 0xFF8A1F)
    static let splashPulse = Color(mbHex: 0xFF8A1F)
    static let splashPitchLine = Color(mbHex: 0xA59F92)
    static let splashWaveUpper = Color(mbHex: 0x37A34A)
    static let splashWaveLower = Color(mbHex: 0xE5484D)
    static let splashTrack = Color(mbHex: 0xE7DDC8)

    static let defaultPrimarySwatchIdentifier = "tomato"
    static let defaultRivalSwatchIdentifier = "cobalt"
    static let teamSwatches: [MBTeamSwatch] = assembleTeamSwatches()

    private static func assembleTeamSwatches() -> [MBTeamSwatch] {
        var assembledSwatches: [MBTeamSwatch] = []
        assembledSwatches.append(MBTeamSwatch(identifier: "tomato", strongColor: Color(mbHex: 0xE84A27), paleColor: Color(mbHex: 0xFBDCCF), stripeColor: Color(mbHex: 0xF6CDBE)))
        assembledSwatches.append(MBTeamSwatch(identifier: "cobalt", strongColor: Color(mbHex: 0x2F5BEA), paleColor: Color(mbHex: 0xD8E1FC), stripeColor: Color(mbHex: 0xC9D5FA)))
        assembledSwatches.append(MBTeamSwatch(identifier: "grass", strongColor: Color(mbHex: 0x2E8B3E), paleColor: Color(mbHex: 0xD5EED8), stripeColor: Color(mbHex: 0xC4E6C9)))
        assembledSwatches.append(MBTeamSwatch(identifier: "violet", strongColor: Color(mbHex: 0x7445E0), paleColor: Color(mbHex: 0xE4DBFA), stripeColor: Color(mbHex: 0xD8CCF6)))
        assembledSwatches.append(MBTeamSwatch(identifier: "teal", strongColor: Color(mbHex: 0x0E8C80), paleColor: Color(mbHex: 0xCDEEEA), stripeColor: Color(mbHex: 0xBCE6E0)))
        assembledSwatches.append(MBTeamSwatch(identifier: "ink", strongColor: Color(mbHex: 0x2B2A3A), paleColor: Color(mbHex: 0xDDDBE4), stripeColor: Color(mbHex: 0xD0CED9)))
        assembledSwatches.append(MBTeamSwatch(identifier: "berry", strongColor: Color(mbHex: 0xC2266B), paleColor: Color(mbHex: 0xF7D4E3), stripeColor: Color(mbHex: 0xF2C3D7)))
        assembledSwatches.append(MBTeamSwatch(identifier: "amber", strongColor: Color(mbHex: 0xD9821A), paleColor: Color(mbHex: 0xF9E6C8), stripeColor: Color(mbHex: 0xF4DAB2)))
        return assembledSwatches
    }
}

struct MBArtworkNames {
    static let onboardingMode = "MBArtOnboardingMode"
    static let onboardingClub = "MBArtOnboardingClub"
    static let onboardingFormat = "MBArtOnboardingFormat"
    static let onboardingSquad = "MBArtOnboardingSquad"
    static let kickoff = "MBArtKickoff"
    static let fullTime = "MBArtFullTime"
    static let emptyArchive = "MBArtEmptyArchive"
    static let emptySeason = "MBArtEmptySeason"
    static let emptySquad = "MBArtEmptySquad"

    static let tabArchive = "MBTabArchive"
    static let tabSeason = "MBTabSeason"
    static let tabLive = "MBTabLive"
    static let tabSquad = "MBTabSquad"
    static let tabClub = "MBTabClub"

    static let tabArchiveSymbol = "tray.full.fill"
    static let tabSeasonSymbol = "chart.bar.xaxis"
    static let tabLiveSymbol = "waveform.path.ecg"
    static let tabSquadSymbol = "person.3.fill"
    static let tabClubSymbol = "shield.lefthalf.filled"
}

struct MBTexts {
    static let splashTagline = "Every match\nhas a pulse"
    static let splashSubline = "Tap the moments. Watch the swing."
    static let splashBallEmoji = "⚽️"
    static let splashBurstEmojis = ["⚡️", "🎯", "🚩", "🔥", "🛡️"]

    static func splashCountdown(seconds: Int) -> String {
        return "Kick-off in \(seconds)"
    }

    static let symbolBack = "chevron.left"
    static let symbolForward = "chevron.right"
    static let symbolClose = "xmark"
    static let symbolCheck = "checkmark"
    static let symbolBlocked = "nosign"
    static let symbolMinus = "minus"
    static let symbolPlus = "plus"
    static let symbolMore = "ellipsis"
    static let symbolTrash = "trash.fill"

    static let emojiAttack = "🏃"
    static let emojiShot = "🎯"
    static let emojiCorner = "🚩"
    static let emojiDanger = "🔥"
    static let emojiLoss = "💨"
    static let emojiGoal = "⚽️"
    static let emojiSubstitution = "🔁"
    static let emojiGoalkeeper = "🧤"
    static let emojiDefender = "🧱"
    static let emojiMidfielder = "🧭"
    static let emojiForward = "🚀"
    static let emojiClubMode = "🥅"
    static let emojiBroadcastMode = "📺"
    static let emojiBothMode = "🔀"
    static let emojiWelcome = "👋"
    static let emojiCrest = "🛡️"
    static let emojiShirt = "👕"
    static let emojiStopwatch = "⏱️"
    static let emojiSquad = "👥"
    static let emojiSample = "🧪"
    static let emojiToggleOn = "✓"
    static let emojiToggleOff = "·"
    static let emojiWhistle = "📣"
    static let emojiBall = "⚽️"
    static let emojiPointer = "👆"
    static let emojiSwipe = "↔️"
    static let emojiWave = "🌊"
    static let emojiWarning = "⚠️"
    static let emojiArchive = "🗂️"
    static let emojiSeason = "📅"
    static let emojiBench = "🪑"
    static let emojiSlump = "📉"
    static let emojiStrong = "💪"
    static let emojiWatch = "👀"
    static let emojiRecovery = "🩹"
    static let emojiControl = "🎛️"
    static let emojiSwing = "🔄"
    static let emojiRecord = "🏆"
    static let emojiArrowOff = "⬅️"
    static let emojiArrowOn = "➡️"
    static let emojiBroom = "🧹"
    static let emojiReset = "🧨"
    static let emojiHaptics = "📳"
    static let emojiStadium = "🏟️"

    static let tabArchive = "Archive"
    static let tabSeason = "Season"
    static let tabLive = "Live"
    static let tabSquad = "Squad"
    static let tabClub = "Club"

    static let eventAttack = "Attack"
    static let eventShot = "Shot"
    static let eventCorner = "Corner"
    static let eventDanger = "Danger"
    static let eventLoss = "Lost ball"
    static let eventGoal = "Goal"
    static let eventSubstitution = "Substitution"

    static let roleGoalkeeper = "Keeper"
    static let roleDefender = "Defender"
    static let roleMidfielder = "Midfield"
    static let roleForward = "Forward"

    static let modeClubTitle = "I coach a team"
    static let modeClubDetail = "Track your own Sunday league side and build season stats."
    static let modeBroadcastTitle = "I watch matches"
    static let modeBroadcastDetail = "Read the flow of any match on TV or in the stands."
    static let modeBothTitle = "Both"
    static let modeBothDetail = "Your own club first, plus any match you happen to watch."

    static let resultWin = "W"
    static let resultDraw = "D"
    static let resultLoss = "L"
    static let resultBroadcast = "TV"
    static let periodFirstHalf = "1st half"
    static let periodSecondHalf = "2nd half"
    static let clockZero = "00:00"
    static let valueNotAvailable = "—"
    static let fallbackClubName = "My Club"

    static let actionCancel = "Cancel"
    static let actionAddPlayer = "Add to squad"

    static let onboardingStepOneKicker = "Step 1 of 4"
    static let onboardingStepTwoKicker = "Step 2 of 4"
    static let onboardingStepThreeKicker = "Step 3 of 4"
    static let onboardingStepFourKicker = "Step 4 of 4"
    static let onboardingModeTitle = "Who's watching?"
    static let onboardingModeMessage = "Momentum Ball turns your taps into a live wave that shows who is pressing and when the game turns."
    static let onboardingClubTitle = "Your club"
    static let onboardingClubMessage = "Name and kit colour paint your half of the pitch and every report."
    static let onboardingFormatTitle = "Match format"
    static let onboardingFormatMessage = "Amateur football comes in every shape. Pick how long your games last."
    static let onboardingSquadTitle = "The squad"
    static let onboardingSquadMessage = "Players make substitutions meaningful: you'll see how the wave reacts to every change."
    static let onboardingSquadListTitle = "Registered"
    static let onboardingSquadEmpty = "No players yet. You can still track matches and add the squad later."
    static let onboardingSampleTitle = "Load a sample season"
    static let onboardingSampleDetail = "Seven Kreisliga matches from Leipzig plus one international, so every screen has something to show."
    static let onboardingNext = "Next"
    static let onboardingFinish = "Blow the whistle"

    static let fieldClubName = "Club name"
    static let fieldClubNamePlaceholder = "e.g. SV Lindenau 08"
    static let fieldKitColour = "Kit colour"
    static let fieldPeriods = "Periods"
    static let fieldPeriodLength = "Period length"
    static let fieldPlayerName = "Player name"
    static let fieldPlayerNamePlaceholder = "e.g. Jonas Becker"
    static let fieldShirtNumber = "Shirt number"
    static let fieldRole = "Position"
    static let fieldOpponent = "Opponent"
    static let fieldOpponentPlaceholder = "e.g. FC Gohlis 1921"
    static let fieldOpponentColour = "Opponent colour"
    static let fieldHomeTeam = "Home team"
    static let fieldHomeTeamPlaceholder = "e.g. Germany"
    static let fieldAwayTeam = "Away team"
    static let fieldAwayTeamPlaceholder = "e.g. Netherlands"
    static let fieldGround = "Ground"
    static let fieldGroundPlaceholder = "e.g. Sportpark Lindenau"
    static let fieldFormat = "Format"
    static let fieldTrackingMode = "What you track"

    static let liveLobbyKicker = "Matchday"
    static let liveLobbyTitle = "Live"
    static let liveLobbyHeadline = "Ready when the ref is"
    static let liveLobbyMessage = "Your team gets the bottom half of the screen, the opponent gets the top. One tap per moment, the wave does the rest."
    static let liveLobbyStart = "Set up a match"
    static let liveLatestTitle = "Last match"
    static let liveHowTitle = "How it works"
    static let howTapTitle = "Tap a moment"
    static let howTapDetail = "Attack, shot, corner, danger or lost ball, on the half of the team that did it."
    static let howHoldTitle = "Hold for a goal"
    static let howHoldDetail = "Keep your finger down until the ring closes, so a goal never slips in by accident."
    static let howSwipeTitle = "Swipe to undo"
    static let howSwipeDetail = "Flick the last-moment strip sideways to take it back."
    static let howWaveTitle = "Watch the border move"
    static let howWaveDetail = "The line between the halves leans towards whoever is under pressure."

    static let liveKickOff = "Kick-off"
    static let liveStartPeriod = "Restart"
    static let livePause = "Pause"
    static let liveResume = "Resume"
    static let liveHalfTime = "Interval"
    static let liveFullTime = "Full-time"
    static let liveAddedTime = "Added time"
    static let liveWaveCaption = "Wave"
    static let liveGoalBanner = "GOAL!"
    static let liveEndDialogTitle = "End this match?"
    static let liveEndDialogFinish = "Full-time now and save"
    static let liveEndDialogDiscard = "Discard match"
    static let liveEmptyAlertTitle = "No moments logged"
    static let liveEmptyAlertMessage = "This match has no taps, so the wave is flat. Keep it in the archive anyway?"
    static let liveEmptyAlertKeep = "Keep it"
    static let liveEmptyAlertDiscard = "Discard"

    static let padSubstitution = "🔁 Sub"
    static let padHoldGoal = "Hold · Goal"
    static let tickerEmpty = "Tap a pad to log the first moment"
    static let tickerSwipeHint = "Swipe to undo"
    static let tickerClockStopped = "Start the clock to log moments"

    static let setupTitle = "New match"
    static let setupTypeClub = "Club match"
    static let setupTypeBroadcast = "TV match"
    static let setupLineupTitle = "Starting line-up"
    static let setupLineupMessage = "Tap players to put them on the pitch. Substitutions later keep track of who is out there."
    static let setupStart = "Walk out"

    static let substitutionTitle = "Substitution"
    static let substitutionMessage = "Pick who comes off and who comes on. The report will compare the wave before and after."
    static let substitutionOff = "Off"
    static let substitutionOn = "On"
    static let substitutionNobody = "Nobody here"
    static let substitutionConfirm = "Make the change"
    static let substitutionWithoutNames = "Log without names"
    static let substitutionBefore = "8 min before"
    static let substitutionAfter = "8 min after"

    static let archiveKicker = "Every match you tracked"
    static let archiveTitle = "Archive"
    static let archiveEmptyTitle = "Nothing in the archive"
    static let archiveEmptyMessage = "Track a match on the Live tab and its full momentum report lands here."
    static let archiveFilterAll = "All"
    static let archiveFilterClub = "Club"
    static let archiveFilterBroadcast = "TV"
    static let archiveFilterEmpty = "No matches of this kind yet."

    static let reportKicker = "Match report"
    static let reportMissingTitle = "Match not found"
    static let reportMissingMessage = "It may have been deleted or the archive was cleared."
    static let reportSlumpsTitle = "Where it sank"
    static let reportSlumpsRule = "4+ min under pressure"
    static let reportRecoveryTitle = "After conceding"
    static let reportSubstitutionsTitle = "Substitutions"
    static let reportTallyTitle = "Moment tally"
    static let reportNoSlumps = "No side spent four minutes or more pinned back. A balanced game."
    static let reportNoGoals = "No goals, so nothing to recover from."
    static let reportNoSubstitutions = "No substitutions were logged in this match."
    static let reportSwingsCaption = "Times initiative changed hands"
    static let reportRecoveryCaption = "Average time to recover"
    static let reportDeleteAlertTitle = "Delete this match?"
    static let reportDeleteAlertMessage = "The wave, the report and its share of season stats will be gone for good."
    static let reportDeleteConfirm = "Delete match"
    static let tallyMoment = "Moment"

    static let scrubberIdle = "Drag across the wave to replay the match minute by minute."
    static let scrubberAxisHint = "Drag to replay"
    static let scrubberBalanced = "Balanced, nobody on top"
    static let scrubberQuiet = "Quiet spell"

    static let seasonTitle = "Season"
    static let seasonEmptyTitle = "The season starts here"
    static let seasonEmptyMessage = "Season trends are built from club matches. Track your first one on the Live tab."
    static let seasonHeatTitle = "Ten-minute map"
    static let seasonHeatDetail = "Tap a slot"
    static let seasonLegendSink = "Under pressure"
    static let seasonLegendPress = "On top"
    static let seasonInsightsTitle = "What the wave says"
    static let seasonFormTitle = "Recent form"
    static let seasonFormDetail = "Share of time on top"
    static let seasonPlayersTitle = "On-pitch momentum"
    static let seasonPlayersDetail = "45+ min"
    static let seasonRecordCaption = "W-D-L"
    static let seasonGoalsCaption = "Goals"
    static let seasonControlCaption = "Time on top"
    static let insightWeakDetail = "Not a pattern yet, but this is where the wave dips most."
    static let insightStrongDetail = "Your best ten minutes on average."
    static let insightStrongStableDetail = "You own this spell in most matches. Plan to score here."

    static let bucketKicker = "Season slot"
    static let bucketMissingTitle = "Slot not found"
    static let bucketMissingMessage = "There is no data for this part of the match."
    static let bucketAverageCaption = "Average wave"
    static let bucketSinkShareCaption = "Sank here"
    static let bucketMatchesCaption = "Matches covered"
    static let bucketPerMatchTitle = "Match by match"
    static let bucketNoCoverage = "None of your matches reached this minute yet."
    static let bucketVerdictSlump = "A stable slump: most matches sink here. Look at fitness, shape and substitution timing."
    static let bucketVerdictStrong = "A stable strong spell: you usually press here."
    static let bucketVerdictThin = "Too few matches to call it a pattern yet."
    static let bucketVerdictMixed = "No clear pattern: some matches up, some down."

    static let squadTitle = "Squad"
    static let squadAddPlayer = "Sign a player"
    static let squadEmptyTitle = "Empty bench"
    static let squadEmptyMessage = "Add players to log named substitutions and see the wave while each player is on."
    static let squadExplainer = "The number on the right is the team's average wave while that player was on the pitch."

    static let editorNewTitle = "New player"
    static let editorEditTitle = "Edit player"
    static let editorSave = "Save"

    static let playerMissingTitle = "Player not found"
    static let playerMissingMessage = "This player has left the squad."
    static let playerAppearancesCaption = "Games"
    static let playerMinutesCaption = "Minutes"
    static let playerMomentumCaption = "Wave on pitch"
    static let playerMomentumExplainer = "Wave on pitch is the team's average momentum while this player was playing, weighted by minutes."
    static let playerMatchesTitle = "Matches"
    static let playerNoMatches = "No tracked minutes yet."
    static let playerEdit = "Edit"
    static let playerRemove = "Release"
    static let playerRemoveAlertTitle = "Release this player?"
    static let playerRemoveAlertMessage = "They leave the squad. Past reports keep the minutes but lose the name."
    static let playerRemoveConfirm = "Release"

    static let clubKicker = "Settings and data"
    static let clubTitle = "Club"
    static let clubEdit = "Edit club"
    static let clubSettingsTitle = "Feel"
    static let clubHaptics = "Haptics"
    static let clubHapticsDetail = "Taps, goals and initiative changes you can feel without looking."
    static let clubMemory = "Wave memory"
    static let clubMemoryDetail = "How long a moment keeps pushing the wave. Shorter memory reacts faster."
    static let clubDataTitle = "Data"
    static let clubWipeArchive = "Clear the archive"
    static let clubReset = "Fold the club"
    static let clubResetDetail = "Delete the club, squad and every match, then start over."
    static let clubWipeAlertTitle = "Clear the archive?"
    static let clubWipeAlertMessage = "Every match, wave and season stat will be deleted. Club and squad stay."
    static let clubWipeConfirm = "Clear archive"
    static let clubResetAlertTitle = "Fold the club?"
    static let clubResetAlertMessage = "Club, squad, archive and any match in progress will be deleted. You'll go back to the start."
    static let clubResetConfirm = "Delete everything"
    static let clubEditorTitle = "Club"
    static let clubEditorNote = "Past matches keep the name and colour they were played with."

    static func formatTitle(periodCount: Int, periodMinutes: Int) -> String {
        return "\(periodCount) × \(periodMinutes)'"
    }

    static func minuteMark(minute: Int) -> String {
        return "\(minute)'"
    }

    static func addedMinuteMark(baseMinute: Int, addedMinute: Int) -> String {
        return "\(baseMinute)+\(addedMinute)'"
    }

    static func minuteRange(startMinute: Int, endMinute: Int) -> String {
        return "\(startMinute)–\(endMinute)'"
    }

    static func periodNumbered(number: Int) -> String {
        return "Period \(number)"
    }

    static func clockFace(minutes: Int, seconds: Int) -> String {
        return String(format: "%02d:%02d", minutes, seconds)
    }

    static func liveWaitingCaption(periodName: String) -> String {
        return "\(periodName) · waiting"
    }

    static func livePausedCaption(periodName: String) -> String {
        return "\(periodName) · paused"
    }

    static func tickerLine(kindTitle: String, teamName: String, minuteLabel: String) -> String {
        return "\(kindTitle) · \(teamName) · \(minuteLabel)"
    }

    static func onboardingFormatHint(totalMinutes: Int) -> String {
        return "That's \(totalMinutes) minutes of football plus whatever the ref adds."
    }

    static func playerCount(count: Int) -> String {
        return count == 1 ? "1 player" : "\(count) players"
    }

    static func setupLineupCount(count: Int) -> String {
        return "\(count) on the pitch"
    }

    static func momentCount(count: Int) -> String {
        return count == 1 ? "1 moment" : "\(count) moments"
    }

    static func matchCardDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_GB")
        dateFormatter.dateFormat = "EEE d MMM yyyy · HH:mm"
        return dateFormatter.string(from: date)
    }

    static func versusLine(primaryName: String, rivalName: String) -> String {
        return "\(primaryName) vs \(rivalName)"
    }

    static func versusRival(rivalName: String) -> String {
        return "vs \(rivalName)"
    }

    static func scoreLine(primaryGoals: Int, rivalGoals: Int) -> String {
        return "\(primaryGoals):\(rivalGoals)"
    }

    static func recordLine(wins: Int, draws: Int, losses: Int) -> String {
        return "\(wins)-\(draws)-\(losses)"
    }

    static func groundAndFormat(ground: String, format: String) -> String {
        return "\(ground) · \(format)"
    }

    static func groundLine(ground: String) -> String {
        return "📍 \(ground)"
    }

    static func signedMomentum(value: Double?) -> String {
        guard let value = value else {
            return valueNotAvailable
        }
        let roundedValue = (value * 100).rounded() / 100
        if (roundedValue > 0) {
            return String(format: "+%.2f", roundedValue)
        } else if (roundedValue < 0) {
            return String(format: "−%.2f", abs(roundedValue))
        }
        return "0.00"
    }

    static func percentValue(share: Double) -> String {
        return "\(Int((share * 100).rounded()))%"
    }

    static func minutesValue(minutes: Double) -> String {
        return String(format: "%.1f min", minutes)
    }

    static func memoryChoice(minutes: Int) -> String {
        return "\(minutes) min"
    }

    static func reportControlCaption(teamName: String) -> String {
        return "Time \(teamName) was on top"
    }

    static func reportSlumpsCaption(teamName: String) -> String {
        return "Slumps for \(teamName)"
    }

    static func slumpRange(start: String, end: String) -> String {
        return "\(start)–\(end)"
    }

    static func slumpHeadline(teamName: String) -> String {
        return "\(teamName) pinned back"
    }

    static func slumpDetail(minutes: Double, depth: Double) -> String {
        return String(format: "Lasted %.1f min · lowest %@", minutes, signedMomentum(value: depth))
    }

    static func recoveryHeadline(concedingName: String) -> String {
        return "\(concedingName) conceded"
    }

    static func recoveryDetail(seconds: Int?) -> String {
        guard let seconds = seconds else {
            return "Never got back level before the whistle"
        }
        if (seconds <= 30) {
            return "Shrugged it off straight away"
        }
        return String(format: "Back level after %.1f min", Double(seconds) / 60)
    }

    static func substitutionLine(outgoingName: String?, incomingName: String?, teamName: String) -> String {
        if let outgoingName = outgoingName, let incomingName = incomingName {
            return "\(outgoingName) ⬅️  ➡️ \(incomingName)"
        }
        return "\(teamName) made a change"
    }

    static func substitutionVerdict(swing: Double?) -> String {
        guard let swing = swing else {
            return "Too late in the game to judge"
        }
        if (swing > 0.1) {
            return "The wave rose after the change"
        } else if (swing < -0.1) {
            return "The wave dropped after the change"
        }
        return "Barely moved the wave"
    }

    static func scrubberPressing(teamName: String) -> String {
        return "\(teamName) pressing"
    }

    static func scrubberSideLabel(teamName: String) -> String {
        return "▲ \(teamName)"
    }

    static func seasonFewMatches(needed: Int) -> String {
        return needed == 1 ? "One more club match and the map starts calling stable patterns." : "\(needed) more club matches and the map starts calling stable patterns."
    }

    static func insightSlumpHeadline(range: String) -> String {
        return "You consistently dip at \(range)"
    }

    static func insightSlumpDetail(sinkingMatches: Int, totalMatches: Int) -> String {
        return "The wave sank here in \(sinkingMatches) of \(totalMatches) matches."
    }

    static func insightWeakHeadline(range: String) -> String {
        return "Weakest spell: \(range)"
    }

    static func insightStrongHeadline(range: String) -> String {
        return "Strongest spell: \(range)"
    }

    static func insightRecoveryHeadline(minutes: Double) -> String {
        return String(format: "%.1f min to recover after conceding", minutes)
    }

    static func insightRecoveryDetail(unrecovered: Int) -> String {
        if (unrecovered == 0) {
            return "You got back level after every goal against."
        }
        return unrecovered == 1 ? "Once the team never got back level before full-time." : "\(unrecovered) times the team never got back level before full-time."
    }

    static func insightBenchHeadline(swing: Double) -> String {
        return "Substitutions move the wave by \(signedMomentum(value: swing))"
    }

    static func insightBenchDetail(count: Int) -> String {
        return "Average change across \(count) substitutions, 8 minutes before vs after."
    }

    static func bucketGoalsLine(scored: Int, conceded: Int) -> String {
        return "Goals in this slot: \(scored) scored, \(conceded) conceded"
    }

    static func rivalInitials(name: String) -> String {
        let letterWords = name.split(separator: " ").filter { nameWord in
            return nameWord.allSatisfy { character in
                return character.isLetter
            }
        }
        let longestWord = letterWords.max { firstWord, secondWord in
            return firstWord.count < secondWord.count
        }
        return String((longestWord ?? Substring(name)).prefix(3)).uppercased()
    }

    static func playerRowDetail(minutes: Int, appearances: Int) -> String {
        if (appearances == 0) {
            return "No tracked minutes yet"
        }
        return "\(minutes) min · \(appearances) apps"
    }

    static func stintLine(fromLabel: String, toLabel: String) -> String {
        return "On the pitch \(fromLabel)–\(toLabel)"
    }

    static func clubWipeArchiveDetail(count: Int) -> String {
        return "Delete all \(count) matches. Club and squad stay."
    }

    static func clubVersion(version: String) -> String {
        return "Momentum Ball \(version)"
    }
}
