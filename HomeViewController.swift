import UIKit

final class HomeViewController: BaseViewController {
    private lazy var headline = label(.largeTitle, bold: true, color: .brand)
    private lazy var lead = label(.body, color: .secondaryLabel)
    private lazy var calBtn = filledButton(#selector(goCal))
    private lazy var actBtn = filledButton(#selector(goAct), filled: false)
    private let features = (1...3).map { _ in (UILabel(), UILabel()) }

    override func viewDidLoad() {
        