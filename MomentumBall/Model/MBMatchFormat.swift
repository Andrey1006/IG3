
import Foundation

struct MBMatchFormat: Hashable {
    var periodCount: Int
    var periodMinutes: Int

    static let fullTime = MBMatchFormat(periodCount: 2, periodMinutes: 45)
    static let presets: [MBMatchFormat] = [MBMatchFormat(periodCount: 2, periodMinutes: 45), MBMatchFormat(periodCount: 2, periodMinutes: 40), MBMatchFormat(periodCount: 2, periodMinutes: 35), MBMatchFormat(periodCount: 2, periodMinutes: 30), MBMatchFormat(periodCount: 2, periodMinutes: 25), MBMatchFormat(periodCount: 4, periodMinutes: 12)]
    static let shortestPeriodMinutes = 8
    static let longestPeriodMinutes = 50

    var title: String {
        return MBTexts.formatTitle(periodCount: periodCount, periodMinutes: periodMinutes)
    }

    var nominalPeriodSeconds: Int {
        return periodMinutes * 60
    }

    var nominalMatchSeconds: Int {
        return periodCount * nominalPeriodSeconds
    }

    func minuteLabel(periodIndex: Int, periodSecond: Int) -> String {
        if (periodSecond < nominalPeriodSeconds) {
            return MBTexts.minuteMark(minute: periodIndex * periodMinutes + periodSecond / 60 + 1)
        }
        let addedMinute = (periodSecond - nominalPeriodSeconds) / 60 + 1
        return MBTexts.addedMinuteMark(baseMinute: (periodIndex + 1) * periodMinutes, addedMinute: addedMinute)
    }

    func periodTitle(periodIndex: Int) -> String {
        if (periodCount == 2) {
            return periodIndex == 0 ? MBTexts.periodFirstHalf : MBTexts.periodSecondHalf
        }
        return MBTexts.periodNumbered(number: periodIndex + 1)
    }

    init(periodCount: Int, periodMinutes: Int) {
        self.periodCount = periodCount
        self.periodMinutes = periodMinutes
    }

    init(plistDictionary: [String: Any]?) {
        let storedCount = plistDictionary?["count"] as? Int ?? 2
        let storedMinutes = plistDictionary?["minutes"] as? Int ?? 45
        self.periodCount = max(1, storedCount)
        self.periodMinutes = max(MBMatchFormat.shortestPeriodMinutes, storedMinutes)
    }

    var plistDictionary: [String: Any] {
        return ["count": periodCount, "minutes": periodMinutes]
    }
}
