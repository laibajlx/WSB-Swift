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
    static func components(_ key: String) -> DateComponents? {
        let p = key.split(separator: "-").compactMap { Int($0) }
        return p.count == 3 ? DateComponents(calendar: cal, year: p[0], month: p[1], day: p[2]) : nil
    }
    static func toggle(_ key: String, on: Bool) { if on { days.insert(key) } else { days.remove(key) } }

    //next expected start date and the average cycle length (default 28 days).
    static func prediction() -> (next: Date, length: Int)? {
        let dates = days.compactMap { fmt.date(from: $0) }.sorted()
        var starts: [Date] = []; var prev: Date?
        for d in dates {
            if let p = prev, (cal.dateComponents([.day], from: p, to: d).day ?? 9) <= 1 { } else { starts.append(d) }
            prev = d
        }
        guard let last = starts.last else { return nil }
        var gaps: [Int] = []
        for i in 1..<starts.count { // starts.count >= 1, so the range is valid
            let g = cal.dateComponents([.day], from: starts[i - 1], to: starts[i]).day ?? 0
            if (15...60).contains(g) { gaps.append(g) }
        }
        let n = gaps.isEmpty ? 28 : gaps.reduce(0, +) / gaps.count
        return cal.date(byAdding: .day, value: n, to: last).map { ($0, n) }
    }
    //five predicted period days
    static func predictedKeys() -> Set<String> {
        guard let p = prediction() else { return [] }
        return Set((0..<5).compactMap { cal.date(byAdding: .day, value: $0, to: p.next) }.map { fmt.string(from: $0) })
    }
}
