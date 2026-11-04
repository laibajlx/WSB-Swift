import Foundation

// stores period days ("yyyy-MM-dd") in UserDefaults and predicts the next period.
enum CycleStore {
    private static let storeKey = "periodDays"
    private static let cal = Calendar(identifier: .gregorian)
    private static let fmt: DateFormatter = {
        let f = DateFormatter(); f.calendar = cal; f.locale = Locale(identifier: "en_US_POSIX"); f.dateFormat = "yyyy-MM-dd"; return f
    }()

    static var days: Set<String> {
        get { Set(UserDefaults.standard.stringArray(forKey: storeKey) ?? []) }
        set { UserDefaults.standard.set(Array(newValue), forKey: storeKey) }
    }
    static func key(_ c: DateComponents) -> String? {
        guard let y = c.year, let m = c.month, let d = c.day else { return nil }
        return String(format: "%04d-%02d-%02d", y, m, d)
    }
}