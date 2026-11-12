import UIKit

extension UIColor {
    static let brand = UIColor(red: 0.78, green: 0.15, blue: 0.35, alpha: 1)   // rose
    static let leaf  = UIColor(red: 0.18, green: 0.49, blue: 0.36, alpha: 1)   // green
}
enum Lang: String { case en, pt }

extension Notification.Name { static let languageChanged = Notification.Name("languageChanged") }
****
/// English <-> Portuguese. Every screen calls `L.t("key")` and re-renders on `.languageChanged`.
enum L {
    static var lang: Lang = {
        if let s = UserDefaults.standard.string(forKey: "lang"), let l = Lang(rawValue: s) { return l }
        return (Locale.preferredLanguages.first ?? "en").hasPrefix("pt") ? .pt : .en
    }() {
        didSet {
            UserDefaults.standard.set(lang.rawValue, forKey: "lang")
            NotificationCenter.default.post(name: .languageChanged, object: nil)
        }
    }
    static var locale: Locale { Locale(identifier: lang == .pt ? "pt_BR" : "en_US") }
    static func toggle() { lang = (lang == .en) ? .pt : .en }
    static func t(_ k: String) -> String { (lang == .en ? en : pt)[k] ?? k }

    static func letter(name: String, city: String, zip: String) -> String {
        let n = name.isEmpty ? (lang == .en ? "[your name]" : "[seu nome]") : name
        let c = city.isEmpty ? (lang == .en ? "[your city]" : "[sua cidade]") : city
        let z = zip.isEmpty ? "" : " (\(zip))"
        return lang == .en ? """
        Dear Legislator,

        My name is \(n) and I am a constituent in \(c)\(z).

        I am writing to ask you to support funding for free menstrual products in schools, shelters, and public buildings. Menstrual poverty is real: when people cannot afford pads or tampons, they miss school and work, and their health and dignity suffer.

        Please co-sponsor or vote for legislation that removes the cost barrier to period care. Access to menstrual products should not depend on income.

        Thank you for your time. I would appreciate a reply telling me where you stand.

        Sincerely,
        \(n)
        """ : """
        Prezado(a) Legislador(a),

        Meu nome é \(n) e sou eleitor(a) em \(c)\(z).

        Escrevo para pedir seu apoio ao financiamento de produtos menstruais gratuitos em escolas, abrigos e prédios públicos. A pobreza menstrual é real: quando as pessoas não podem comprar absorventes, faltam à escola e ao trabalho, e sua saúde e dignidade sofrem.

        Peço que apoie ou vote em leis que eliminem a barreira de custo do cuidado menstrual. O acesso a esses produtos não deve depender da renda.

        Agradeço sua atenção e peço uma resposta informando sua posição.

        Atenciosamente,
        \(n)
        """
    }

    static let en: [String: String] = [
        "home": "Home", "calendar": "Calendar", "act": "Take action",
        "h1": "Period care is a right, not a privilege.",
        "lead": "Millions of girls and women in São Paulo and around the world miss school and work because they can’t afford pads or tampons. Track your cycle and tell your representatives to act.",
        "go.cal": "Track your cycle", "go.act": "Write your legislator",
        "f1t": "English and Portuguese", "f1": "Switch the whole app between English and Português with one tap.",
        "f2t": "Private calendar", "f2": "Tap the days you bleed. Dates stay on this device, and the app estimates your next period.",
        "f3t": "Advocacy letter", "f3": "Enter your ZIP code, find your elected officials, and send a ready-made letter.",
        "nodata": "Mark your first period days to see a prediction.",
        "next": "Next period expected around %@ (average cycle: %d days).",
        "calsub": "Tap a date to mark or unmark a period day. Outlined dates are predicted.",
        "zip": "ZIP code", "find": "Find my legislators", "badzip": "Enter a valid 5-digit ZIP code.",
        "l1": "Find your U.S. Representative", "l2": "Find your U.S. Senators", "l3": "Find state legislators",
        "name": "Your name", "city": "Your city", "email": "Legislator’s email (paste from their site)",
        "draft": "Your email draft", "open": "Open in my email app", "copy": "Copy", "copied": "Copied",
        "subject": "Please support free menstrual products",
        "note": "Your ZIP code only builds the lookup links. Nothing is sent to a server.", "other": "PT"
    ]
    static let pt: [String: String] = [
        "home": "Início", "calendar": "Calendário", "act": "Agir",
        "h1": "Cuidado menstrual é um direito, não um privilégio.",
        "lead": "Milhões de meninas e mulheres em São Paulo e no mundo faltam à escola e ao trabalho por não poderem comprar absorventes. Acompanhe seu ciclo e peça que seus representantes ajam.",
        "go.cal": "Acompanhar meu ciclo", "go.act": "Escrever ao legislador",
        "f1t": "Inglês e português", "f1": "Troque todo o app entre English e Português com um toque.",
        "f2t": "Calendário privado", "f2": "Toque nos dias de menstruação. As datas ficam só neste aparelho, e o app estima a próxima menstruação.",
        "f3t": "Carta de apoio", "f3": "Digite seu ZIP code, encontre seus representantes e envie uma carta pronta.",
        "nodata": "Marque seus primeiros dias de menstruação para ver uma previsão.",
        "next": "Próxima menstruação prevista por volta de %@ (ciclo médio: %d dias).",
        "calsub": "Toque em uma data para marcar ou desmarcar um dia de menstruação. Datas com contorno são previstas.",
        "zip": "ZIP code", "find": "Encontrar meus legisladores", "badzip": "Digite um ZIP code válido de 5 dígitos.",
        "l1": "Encontre seu Deputado (EUA)", "l2": "Encontre seus Senadores (EUA)", "l3": "Encontre legisladores estaduais",
        "name": "Seu nome", "city": "Sua cidade", "email": "E-mail do legislador (copie do site dele)",
        "draft": "Seu rascunho de e-mail", "open": "Abrir no meu e-mail", "copy": "Copiar", "copied": "Copiado",
        "subject": "Peço apoio a absorventes gratuitos",
        "note": "Seu ZIP code só monta os links de busca. Nada é enviado a um servidor.", "other": "EN"
    ]
}

/// Base class: adds the EN/PT toggle to the nav bar and re-applies strings on change.
class BaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: L.t("other"), style: .plain, target: self, action: #selector(toggleLang))
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .languageChanged, object: nil)
    }
    @objc private func toggleLang() { L.toggle() }
    @objc private func refresh() {
        navigationItem.rightBarButtonItem?.title = L.t("other")
        applyLanguage()
    }
    func applyLanguage() {}   // override in subclasses
}

/// Scrolling vertical stack used by Home and Advocacy.
extension BaseViewController {
    func makeScrollStack() -> UIStackView {
        let scroll = UIScrollView(); scroll.keyboardDismissMode = .interactive
        let stack = UIStackView(); stack.axis = .vertical; stack.spacing = 12
        [scroll, stack].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        view.addSubview(scroll); scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 20),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -40),
            stack.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -20)
        ])
        return stack
    }
    func label(_ style: UIFont.TextStyle, bold: Bool = false, color: UIColor = .label) -> UILabel {
        let l = UILabel(); l.numberOfLines = 0; l.textColor = color
        let base = UIFont.preferredFont(forTextStyle: style)
        l.font = bold ? UIFont.systemFont(ofSize: base.pointSize, weight: .bold) : base
        l.adjustsFontForContentSizeCategory = true
        return l
    }
    func filledButton(_ action: Selector, filled: Bool = true) -> UIButton {
        var c: UIButton.Configuration = filled ? .filled() : .bordered()
        c.cornerStyle = .large; c.baseBackgroundColor = filled ? .brand : nil; c.baseForegroundColor = filled ? .white : .brand
        let b = UIButton(configuration: c); b.addTarget(self, action: action, for: .touchUpInside); return b
    }
}
