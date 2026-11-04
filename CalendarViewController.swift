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

 