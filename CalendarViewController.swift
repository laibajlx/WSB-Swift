import UIKit

// date based menstrual calendar (UICalendarView, iOS 16+). tap dates to mark period days
final class CalendarViewController: BaseViewController, UICalendarViewDelegate, UICalendarSelectionMultiDateDelegate {
    private let calendarView = UICalendarView()
    private lazy var subtitle = label(.subheadline, color: .secondaryLabel)
    private lazy var status = label(.headline)
    private var selection: UICalendarSelectionMultiDate!

    override func viewDidLoad() {
        super.viewDidLoad()
        calendarView.calendar = Calendar(identifier: .gregorian)
        calendarView.tintColor = .brand
        calendarView.delegate = self
        selection = UICalendarSelectionMultiDate(delegate: self)
        selection.selectedDates = CycleStore.days.compactMap { CycleStore.components($0) }
        calendarView.selectionBehavior = selection

        let pad = UIView(); pad.backgroundColor = UIColor.brand.withAlphaComponent(0.12); pad.layer.cornerRadius = 12
        status.translatesAutoresizingMaskIntoConstraints = false; pad.addSubview(status)
        NSLayoutConstraint.activate([
            status.topAnchor.constraint(equalTo: pad.topAnchor, constant: 12), status.bottomAnchor.constraint(equalTo: pad.bottomAnchor, constant: -12),
            status.leadingAnchor.constraint(equalTo: pad.leadingAnchor, constant: 14), status.trailingAnchor.constraint(equalTo: pad.trailingAnchor, constant: -14)])

        let stack = UIStackView(arrangedSubviews: [subtitle, calendarView, pad])
        stack.axis = .vertical; stack.spacing = 14; stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)])
        applyLanguage()
    }

    override func applyLanguage() {
        subtitle.text = L.t("calsub")
        calendarView.locale = L.locale
        updateStatus()
    }

    private func updateStatus() {
        guard let p = CycleStore.prediction() else { status.text = L.t("nodata"); return }
        let f = DateFormatter(); f.locale = L.locale; f.setLocalizedDateFormatFromTemplate("dMMMM")
        status.text = String(format: L.t("next"), f.string(from: p.next), p.length)
    }

    private func toggle(_ dc: DateComponents, on: Bool) {
        guard let key = CycleStore.key(dc) else { return }
        let old = CycleStore.predictedKeys()
        CycleStore.toggle(key, on: on)
        let changed = old.union(CycleStore.predictedKeys()).union([key]).compactMap { CycleStore.components($0) }
        calendarView.reloadDecorations(forDateComponents: changed, animated: true)
        updateStatus()
    }

    // mark delegates
    func multiDateSelection(_ s: UICalendarSelectionMultiDate, didSelectDate dc: DateComponents) { toggle(dc, on: true) }
    func multiDateSelection(_ s: UICalendarSelectionMultiDate, didDeselectDate dc: DateComponents) { toggle(dc, on: false) }

    func calendarView(_ v: UICalendarView, decorationFor dc: DateComponents) -> UICalendarView.Decoration? {
        guard let k = CycleStore.key(dc), CycleStore.predictedKeys().contains(k), !CycleStore.days.contains(k) else { return nil }
        return .default(color: .brand, size: .large)
    }
}
