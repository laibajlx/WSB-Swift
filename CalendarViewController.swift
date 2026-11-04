import UIKit

// date based menstrual calendar (UICalendarView, iOS 16+). tap dates to mark period days
final class CalendarViewController: BaseViewController, UICalendarViewDelegate, UICalendarSelectionMultiDateDelegate {
    private let calendarView = UICalendarView()
    private lazy var subtitle = label(.subheadline, color: .secondaryLabel)
    private lazy var status = label(.headline)
    private var selection: UICalendarSelectionMultiDate!

   