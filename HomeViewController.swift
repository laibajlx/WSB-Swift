import UIKit

final class HomeViewController: BaseViewController {
    private lazy var headline = label(.largeTitle, bold: true, color: .brand)
    private lazy var lead = label(.body, color: .secondaryLabel)
    private lazy var calBtn = filledButton(#selector(goCal))
    private lazy var actBtn = filledButton(#selector(goAct), filled: false)
    private let features = (1...3).map { _ in (UILabel(), UILabel()) }

    override func viewDidLoad() {
        super.viewDidLoad()
        let stack = makeScrollStack()
        [headline, lead, calBtn, actBtn].forEach { stack.addArrangedSubview($0) }
        stack.setCustomSpacing(24, after: actBtn)
        for (t, b) in features {
            t.numberOfLines = 0; b.numberOfLines = 0
            t.font = .preferredFont(forTextStyle: .headline); b.font = .preferredFont(forTextStyle: .subheadline)
            b.textColor = .secondaryLabel
            let box = UIStackView(arrangedSubviews: [t, b]); box.axis = .vertical; box.spacing = 2
            let bar = UIView(); bar.backgroundColor = .brand; bar.widthAnchor.constraint(equalToConstant: 4).isActive = true
            let row = UIStackView(arrangedSubviews: [bar, box]); row.spacing = 12
            stack.addArrangedSubview(row)
        }
        