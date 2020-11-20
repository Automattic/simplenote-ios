import UIKit


class SPAboutViewController: UIViewController {

    private let tableView = UITableView()
    private let containerView = UIStackView()
    private let doneButton = RoundedCrossButton()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .simplenoteBlue50Color

        setupDoneButton()
        setupContainerView()
        setupHeaderView()
        setupTableView()
        setupFooterView()
    }
}


// MARK: - Configuration
//
private extension SPAboutViewController {

    func setupDoneButton() {
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(onDoneTap(_:)), for: .touchUpInside)

        doneButton.style = .blue

        view.addSubview(doneButton)

        NSLayoutConstraint.activate([
            doneButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: Constants.doneButtonTopMargin),
            doneButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            doneButton.widthAnchor.constraint(equalToConstant: Constants.doneButtonWidth),
            doneButton.heightAnchor.constraint(equalToConstant: Constants.doneButtonWidth),
        ])
    }

    func setupContainerView() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.axis = .vertical
        containerView.alignment = .fill
        containerView.spacing = 10.0
        view.insertSubview(containerView, belowSubview: doneButton)

        let bottomAnchor = view.safeAreaLayoutGuide.bottomAnchor
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: doneButton.bottomAnchor, constant: 29),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14.0)
            ])
    }

    func setupHeaderView() {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = 6

        let imageView = UIImageView(image: .image(name: .simplenoteLogo))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .white
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.heightAnchor.constraint(equalToConstant: 60)
        ])

        stackView.addArrangedSubview(imageView)

        let appNameLabel = UILabel()
        appNameLabel.translatesAutoresizingMaskIntoConstraints = false
        appNameLabel.text = Bundle.main.infoDictionary!["CFBundleName"] as? String
        appNameLabel.textColor = UIColor.white
        appNameLabel.font = UIFont.preferredFont(for: .largeTitle, weight: .bold)
        appNameLabel.textAlignment = .center
        stackView.addArrangedSubview(appNameLabel)

        let versionLabel = UILabel()
        let versionNumber = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        versionLabel.text = String(format: NSLocalizedString("Version %@", comment: "App version number"), versionNumber!)
        versionLabel.textColor = UIColor.white
        versionLabel.font = UIFont.preferredFont(forTextStyle: .body)
        versionLabel.textAlignment = .center
        stackView.addArrangedSubview(versionLabel)

        containerView.addArrangedSubview(stackView)
    }
    
    func setupFooterView() {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 20.0

        stackView.addArrangedSubview(footerServiceTextView())
        stackView.addArrangedSubview(footerCopyrightLabel())

        containerView.addArrangedSubview(stackView)
    }

    func footerServiceTextView() -> UITextView {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = UIColor.clear
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.linkTextAttributes = [.foregroundColor: UIColor.simplenoteBlue10Color]

        let privacyText = footerAttributedText(Constants.privacyString, withLink: Constants.privacyURLString)
        let termsOfServiceText = footerAttributedText(Constants.termsString, withLink: Constants.termsURLString)
        let californiaStringText = footerAttributedText(Constants.californiaString, withLink: Constants.californiaURLString)

        let text = NSMutableAttributedString()
        text.append(privacyText)
        text.append(footerAttributedText(", "))
        text.append(termsOfServiceText)
        text.append(footerAttributedText("\n"))
        text.append(californiaStringText)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 15

        text.addAttribute(.paragraphStyle, value: paragraphStyle, range: text.fullRange)
        textView.attributedText = text

        return textView
    }

    func footerAttributedText(_ text: String, withLink link: String) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: [
            .font: UIFont.preferredFont(forTextStyle: .footnote),
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .link: link
        ])
    }

    func footerAttributedText(_ text: String) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: [
            .foregroundColor: UIColor.simplenoteBlue10Color,
            .font: UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 13))
        ])
    }

    func footerCopyrightLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textAlignment = .center
        label.textColor = .white
        label.text = footerCopyrightString()
        return label
    }

    func footerCopyrightString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return String(format: "\u{00A9} Automattic %@", formatter.string(from: Date()))
    }

    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        tableView.separatorColor = .simplenoteBlue30Color
        tableView.backgroundColor = UIColor.clear
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.indicatorStyle = .white

        containerView.addArrangedSubview(tableView)
    }
}


// MARK: - UITableViewDataSource Conformance
//
extension SPAboutViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.titles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "reuseIdentifier")

        cell.textLabel?.text = Constants.titles[indexPath.row]
        cell.detailTextLabel?.text = Constants.descriptions[indexPath.row]
        
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.textColor = UIColor.white
        cell.backgroundColor = UIColor.clear
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = .simplenoteBlue30Color
        cell.selectedBackgroundView = bgColorView
        
        let arrowAccessoryView = UIImageView(image: UIImage(named: "icon_arrow_top_right"))
        arrowAccessoryView.tintColor = .white
        arrowAccessoryView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        cell.accessoryView = arrowAccessoryView
        
        return cell
    }
}


// MARK: - UITableViewDelegate Conformance
//
extension SPAboutViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIApplication.shared.open(Constants.urls[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    @objc func onDoneTap(_ sender:UIButton) {
        dismiss(animated: true)
    }
}


// MARK: - Private Helpers
//
private extension SPAboutViewController {


}


// MARK: - Constants
//
private enum Constants {

    static let headerHeight: CGFloat        = 170
    static let footerHeight: CGFloat        = 60
    static let doneButtonWidth: CGFloat     = 30
    static let doneButtonTopMargin: CGFloat = 13

    static let privacyString    = NSLocalizedString("Privacy Policy", comment: "Simplenote privacy policy")
    static let privacyURLString = "https://automattic.com/privacy/"
    static let termsString      = NSLocalizedString("Terms of Service", comment: "Simplenote terms of service")
    static let termsURLString   = "https://simplenote.com/terms/"
    static let californiaString = NSLocalizedString("Privacy Notice for California Users", comment: "Simplenote terms of service")
    static let californiaURLString = "https://automattic.com/privacy/#california-consumer-privacy-act-ccpa"

    static let titles: [String] = [
        NSLocalizedString("Blog", comment: "The Simplenote blog"),
        "Twitter",
        NSLocalizedString("Get Help", comment: "FAQ or contact us"),
        NSLocalizedString("Apps", comment: "Other Simplenote apps"),
        NSLocalizedString("Contribute", comment: "Contribute to the Simplenote apps on github"),
        NSLocalizedString("Work With Us", comment: "Work at Automattic")
    ]

    static let descriptions: [String] = [
        "simplenote.com/blog",
        "@simplenoteapp",
        NSLocalizedString("FAQ or contact us", comment: "Get Help Description Label"),
        "simplenote.com",
        "GitHub.com",
        NSLocalizedString("Are you a developer? Automattic is hiring.", comment: "Automattic hiring description")
    ]

    static let urls: [URL] = [
        URL(string: "https://simplenote.com/blog")!,
        URL(string: "https://twitter.com/simplenoteapp")!,
        URL(string: "https://simplenote.com/help")!,
        URL(string: "https://simplenote.com")!,
        URL(string: "https://github.com/automattic/simplenote-ios")!,
        URL(string: "https://automattic.com/work-with-us")!
    ]
}
