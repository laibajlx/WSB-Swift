import UIKit

final class MainTabBarController: UITabBarController {
    private let vcs: [(BaseViewController, String, String)] = [
        (HomeViewController(), "home", "house"),
        (CalendarViewController(), "calendar", "calendar"),
        (AdvocacyViewController(), "act", "envelope")
    ]
    