
import Foundation

struct MBPlistList {
    static func decode<Element>(rawValue: Any?, transform: ([String: Any]) -> Element?) -> [Element] {
        guard let rawItems = rawValue as? [Any] else {
            return []
        }
        var decodedItems: [Element] = []
        collect(rawItems: rawItems[...], decodedItems: &decodedItems, transform: transform)
        return decodedItems
    }

    private static func collect<Element>(rawItems: ArraySlice<Any>, decodedItems: inout [Element], transform: ([String: Any]) -> Element?) {
        guard let rawItem = rawItems.first else {
            return
        }
        if let itemDictionary = rawItem as? [String: Any], let decodedItem = transform(itemDictionary) {
            decodedItems.append(decodedItem)
        }
        collect(rawItems: rawItems.dropFirst(), decodedItems: &decodedItems, transform: transform)
    }

    static func sum(values: ArraySlice<Int>) -> Int {
        guard let firstValue = values.first else {
            return 0
        }
        return firstValue + sum(values: values.dropFirst())
    }
}
