import UIKit
import SafariServices

/// ZIP code -> official legislator lookups -> editable email draft opened via mailto:.
final class AdvocacyViewController: BaseViewController, UITextFieldDelegate, UITextViewDelegate {
    private let zip = UITextField(), name = UITextField(), city = UITextField(), email = UITextField()
    private lazy var zipLabel = label(.headline), draftLabel = label(.headline), noteLabel = label(.footnote, color: .secondaryLabel)
    private lazy var error = label(.subheadline, color: .brand)
    private lazy var findBtn = filledButton(#selector(findTapped))
    private lazy var openBtn = filledButton(#selector(openMail))
    private lazy var copyBtn = filledButton(#selector(copyDraft), filled: false)
    private let linkStack = UIStackView()
    private let draft = UITextView()
    private var linkButtons: [UIButton] = []
    private let urls = ["https://www.house.gov/representatives/find-your-representative",
                        "https://www.senate.gov/senators/senators-contact.htm",
                        "https://openstates.org/find_your_legislator/"]

    override func viewDidLoad() {
        super.viewDidLoad()
        let stack = makeScrollStack()
        zip.keyboardType = .numberPad; zip.textContentType = .postalCode
        name.textContentType = .name; city.textContentType = .addressCity
        email.keyboardType = .emailAddress; email.autocapitalizationType = .none; email.textContentType = .emailAddress
        for f in [zip, name, city, email] {
            f.borderStyle = .roundedRect; f.delegate = self; f.heightAnchor.constraint(equalToConstant: 44).isActive = true
            f.addTarget(self, action: #selector(fieldsChanged), for: .editingChanged)
        }
        linkStack.axis = .vertical; linkStack.spacing = 8
        for (i, _) in urls.enumerated() {
            var c = UIButton.Configuration.bordered(); c.baseForegroundColor = .leaf; c.cornerStyle = .large
            let b = UIButton(configuration: c); b.tag = i; b.contentHorizontalAlignment = .leading
            b.addTarget(self, action: #selector(openLink(_:)), for: .touchUpInside)
            linkButtons.append(b); linkStack.addArrangedSubview(b)
        }
        linkStack.isHidden = true
        draft.font = .preferredFont(forTextStyle: .body); draft.layer.cornerRadius = 8
        draft.layer.borderWidth = 1; draft.layer.borderColor = UIColor.separator.cgColor
        draft.delegate = self; draft.heightAnchor.constraint(equalToConstant: 300).isActive = true

        let zipRow = UIStackView(arrangedSubviews: [zip, findBtn]); zipRow.spacing = 8
        zip.widthAnchor.constraint(equalToConstant: 110).isActive = true
        let btnRow = UIStackView(arrangedSubviews: [openBtn, copyBtn]); btnRow.spacing = 8; btnRow.distribution = .fillEqually
        [zipLabel, zipRow, error, linkStack, name, city, email, draftLabel, draft, btnRow, noteLabel].forEach { stack.addArrangedSubview($0) }
        applyLanguage()
    }

    override func applyLanguage() {
        zipLabel.text = L.t("zip"); draftLabel.text = L.t("draft"); noteLabel.text = L.t("note")
        findBtn.configuration?.title = L.t("find"); openBtn.configuration?.title = L.t("open"); copyBtn.configuration?.title = L.t("copy")
        for (i, k) in ["l1", "l2", "l3"].enumerated() { linkButtons[i].configuration?.title = L.t(k) }
        name.placeholder = L.t("name"); city.placeholder = L.t("city"); email.placeholder = L.t("email")
        error.text = nil
        draft.text = L.letter(name: name.text ?? "", city: city.text ?? "", zip: validZip ? zip.text! : "")
    }

    private var validZip: Bool { (zip.text ?? "").range(of: #"^\d{5}$"#, options: .regularExpression) != nil }

    @objc private func fieldsChanged() {
        if zip.text?.count ?? 0 > 5 { zip.text = String(zip.text!.prefix(5)) }
        draft.text = L.letter(name: name.text ?? "", city: city.text ?? "", zip: validZip ? zip.text! : "")
    }
    @objc private func findTapped() {
        view.endEditing(true)
        error.text = validZip ? nil : L.t("badzip")
        linkStack.isHidden = !validZip
        fieldsChanged()
    }
    @objc private func openLink(_ b: UIButton) {
        if let u = URL(string: urls[b.tag]) { present(SFSafariViewController(url: u), animated: true) }
    }
    @objc private func openMail() {
        var c = URLComponents(); c.scheme = "mailto"; c.path = (email.text ?? "").trimmingCharacters(in: .whitespaces)
        c.queryItems = [URLQueryItem(name: "subject", value: L.t("subject")), URLQueryItem(name: "body", value: draft.text)]
        if let u = c.url { UIApplication.shared.open(u) }
    }
    @objc private func copyDraft() {
        UIPasteboard.general.string = draft.text
        copyBtn.configuration?.title = L.t("copied")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in self?.copyBtn.configuration?.title = L.t("copy") }
    }
    func textFieldShouldReturn(_ tf: UITextField) -> Bool { tf.resignFirstResponder(); return true }
}
