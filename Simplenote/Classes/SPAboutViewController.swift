import UIKit

class SPAboutViewController: UIViewController {

    private let tableView = HuggableTableView(frame: .zero, style: .grouped)
    private let containerView = UIStackView()
    private let doneButton = RoundedCrossButton()
    private var viewSpinner: ViewSpinner?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .simplenoteBlue50Color

        setupContainerView()
        setupDoneButton()

        setupHeaderView()
        setupTableView()
        setupFooterView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewSpinner?.stop()
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
            doneButton.widthAnchor.constraint(equalToConstant: Constants.doneButtonSideSize),
            doneButton.heightAnchor.constraint(equalToConstant: Constants.doneButtonSideSize),
        ])
    }

    func setupContainerView() {
        let scrollView = UIScrollView()

        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.axis = .vertical
        containerView.alignment = .fill
        containerView.spacing = Constants.containerSpacing

        scrollView.addFillingSubview(containerView, edgeInsets: Constants.containerEdgeInsets)
        view.addFillingSubview(scrollView)

        containerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -(Constants.containerEdgeInsets.left + Constants.containerEdgeInsets.right)).isActive = true
    }

    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .simplenoteBlue30Color
        tableView.backgroundColor = UIColor.clear
        // Removing unneeded paddings
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        tableView.indicatorStyle = .white

        containerView.addArrangedSubview(tableView)
    }
}

// MARK: - Header Configuration
//
private extension SPAboutViewController {
    func setupHeaderView() {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = Constants.headerViewSpacing

        let logoView = self.logoView()
        setupSpinner(with: logoView)

        stackView.addArrangedSubview(logoView)
        stackView.addArrangedSubview(appNameLabel())
        stackView.addArrangedSubview(versionLabel())

        containerView.addArrangedSubview(stackView)
    }

    func logoView() -> UIView {
        let imageView = UIImageView(image: .image(name: .simplenoteLogo))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .white
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: Constants.logoWidth),
            imageView.heightAnchor.constraint(equalToConstant: Constants.logoWidth)
        ])
        return imageView
    }

    func appNameLabel() -> UIView {
        let label = UILabel()
        label.text = Bundle.main.infoDictionary!["CFBundleName"] as? String
        label.textColor = UIColor.white
        label.font = UIFont.preferredFont(for: .largeTitle, weight: .bold)
        label.textAlignment = .center
        return label
    }

    func versionLabel() -> UIView {
        let label = UILabel()
        let versionNumber = Bundle.main.shortVersionString
        label.text = String(format: NSLocalizedString("Version %@", comment: "App version number"), versionNumber)
        label.textColor = UIColor.white
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .center
        return label
    }
}

// MARK: - Footer Configuration
//
private extension SPAboutViewController {
    func setupFooterView() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = Constants.footerViewSpacing

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

        textView.attributedText = footerAttributedText()

        return textView
    }

    func footerAttributedText() -> NSMutableAttributedString {
        let privacyText = footerAttributedText(Constants.privacyString, withLink: Constants.privacyURLString)
        let termsOfServiceText = footerAttributedText(Constants.termsString, withLink: Constants.termsURLString)
        let californiaStringText = footerAttributedText(Constants.californiaString, withLink: Constants.californiaURLString)

        let text = NSMutableAttributedString()
        text.append(privacyText)
        text.append(footerAttributedText(", "))
        text.append(termsOfServiceText)
        text.append(footerAttributedText(","))
        text.append(footerAttributedText("\n"))
        text.append(californiaStringText)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = Constants.footerLineSpacing

        text.addAttribute(.paragraphStyle, value: paragraphStyle, range: text.fullRange)

        return text
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
            .font: UIFont.preferredFont(forTextStyle: .footnote)
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
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: nil)

        cell.textLabel?.text = Constants.titles[indexPath.row]
        cell.detailTextLabel?.text = Constants.descriptions[indexPath.row]

        cell.textLabel?.textColor = .white
        cell.detailTextLabel?.textColor = .simplenoteBlue10Color
        cell.detailTextLabel?.font = .preferredFont(forTextStyle: .subheadline)
        cell.backgroundColor = .clear

        let bgColorView = UIView()
        bgColorView.backgroundColor = .simplenoteBlue30Color
        cell.selectedBackgroundView = bgColorView

        let arrowAccessoryView = UIImageView(image: .image(name: .arrowTopRight))
        arrowAccessoryView.tintColor = .simplenoteBlue10Color
        arrowAccessoryView.frame = CGRect(x: 0, y: 0, width: Constants.cellAccessorySideSize, height: Constants.cellAccessorySideSize)
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

    @objc func onDoneTap(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

// MARK: - Header Spinner
//
private extension SPAboutViewController {
    func setupSpinner(with view: UIView) {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleSpinnerGestureRecognizer(_:)))
        gestureRecognizer.minimumPressDuration = Constants.logoMinPressDuration
        view.addGestureRecognizer(gestureRecognizer)
        view.isUserInteractionEnabled = true

        viewSpinner = ViewSpinner(view: view)
        viewSpinner?.onMaxVelocity = { [weak self] in
            self?.viewSpinner?.stop()
            self?.showSpinnerMessage()
        }
    }

    @objc
    func handleSpinnerGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            viewSpinner?.start()
        case .ended, .cancelled, .failed:
            viewSpinner?.stop()
        case .possible, .changed:
            break
        @unknown default:
            break
        }
    }

    func showSpinnerMessage() {
        guard let message = randomSpinnerMessage else {
            return
        }

        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addCancelActionWithTitle(NSLocalizedString("OK", comment: "Closes alert controller for spinner on About view"))
        present(alertController, animated: true, completion: nil)
    }

    var randomSpinnerMessage: String? {
        Constants.spinnerMessages.randomElement().map {
            let preparedString = $0.replacingOccurrences(of: "&#x(..);", with: #"\\u00$1"#, options: .regularExpression, range: $0.fullRange)

            let resultString = NSMutableString(string: preparedString)
            CFStringTransform(resultString, nil, "Any-Hex/Java" as CFString, true)
            return resultString as String
        }
    }
}

// MARK: - Constants
//
private enum Constants {

    static let doneButtonSideSize: CGFloat = 30
    static let doneButtonTopMargin: CGFloat = 13
    static let logoWidth: CGFloat = 60
    static let cellAccessorySideSize: CGFloat = 24

    static let containerEdgeInsets = UIEdgeInsets(top: 72, left: 0, bottom: 14, right: 0)
    static let containerSpacing: CGFloat = 36
    static let headerViewSpacing: CGFloat = 6
    static let footerViewSpacing: CGFloat = 20
    static let footerLineSpacing: CGFloat = 15

    static let logoMinPressDuration: TimeInterval = 0.5

    static let privacyString    = NSLocalizedString("Privacy Policy", comment: "Simplenote privacy policy")
    static let privacyURLString = "https://automattic.com/privacy/"
    static let termsString      = NSLocalizedString("Terms of Service", comment: "Simplenote terms of service")
    static let termsURLString   = "https://simplenote.com/terms/"
    static let californiaString = NSLocalizedString("Privacy Notice for California Users", comment: "Simplenote terms of service")
    static let californiaURLString = "https://automattic.com/privacy/#us-privacy-laws"

    static let titles: [String] = [
        NSLocalizedString("Blog", comment: "The Simplenote blog"),
        "Twitter",
        NSLocalizedString("Get Help", comment: "FAQ or contact us"),
        NSLocalizedString("Rate Us", comment: "Rate on the App Store"),
        NSLocalizedString("Contribute", comment: "Contribute to the Simplenote apps on github"),
        NSLocalizedString("Careers", comment: "Work at Automattic")
    ]

    static let descriptions: [String] = [
        "simplenote.com/blog",
        "@simplenoteapp",
        NSLocalizedString("FAQ or contact us", comment: "Get Help Description Label"),
        "App Store",
        "github.com",
        NSLocalizedString("Are you a developer? We’re hiring.", comment: "Automattic hiring description")
    ]

    static let urls: [URL] = [
        URL(string: "https://simplenote.com/blog/")!,
        URL(string: "https://twitter.com/simplenoteapp")!,
        URL(string: "https://simplenote.com/help/")!,
        URL(string: "https://apps.apple.com/app/id289429962")!,
        URL(string: "https://github.com/automattic/simplenote-ios")!,
        URL(string: "https://automattic.com/work-with-us/")!
    ]

    static let spinnerMessages: [String] = [
        "&#x49;&#x74;\\u0020&#x66;\\u0065\\u0065&#x6c;\\u0073&#x20;&#x6c;\\u0069&#x6b;\\u0065\\u0020&#x49;\\u0020\\u006f&#x6e;\\u006c&#x79;\\u0020&#x67;\\u006f&#x20;\\u0062\\u0061\\u0063&#x6b;\\u0077\\u0061&#x72;\\u0064&#x73;\\u002c\\u0020\\u0062&#x61;\\u0062\\u0079",
        "&#x54;\\u0075&#x72;&#x6e;\\u0020&#x61;&#x72;\\u006f&#x75;\\u006e&#x64;\\u002c\\u0020\\u0062\\u0072&#x69;\\u0067\\u0068\\u0074\\u0020&#x65;&#x79;&#x65;\\u0073\n&#x45;\\u0076\\u0065&#x72;\\u0079&#x20;&#x6e;&#x6f;\\u0077&#x20;\\u0061&#x6e;&#x64;&#x20;\\u0074&#x68;\\u0065\\u006e\\u0020&#x49;\\u0020&#x66;&#x61;\\u006c&#x6c;\\u0020\\u0061&#x70;&#x61;\\u0072&#x74;",
        "\\u0054&#x6f;\\u0020&#x65;&#x76;\\u0065&#x72;&#x79;&#x74;&#x68;\\u0069&#x6e;\\u0067&#x20;&#x28;&#x74;&#x75;\\u0072\\u006e&#x2c;\\u0020&#x74;&#x75;&#x72;\\u006e&#x2c;\\u0020&#x74;\\u0075&#x72;\\u006e\\u0029\n\\u0054\\u0068&#x65;\\u0072\\u0065&#x20;\\u0069\\u0073\\u0020\\u0061&#x20;\\u0073&#x65;\\u0061\\u0073&#x6f;\\u006e&#x20;\\u0028&#x74;\\u0075\\u0072&#x6e;\\u002c\\u0020\\u0074&#x75;\\u0072\\u006e\\u002c\\u0020&#x74;\\u0075\\u0072&#x6e;\\u0029",
        "&#x59;\\u006f\\u0075&#x20;\\u0073\\u0070\\u0069&#x6e;\\u0020&#x6d;\\u0065&#x20;\\u0072\\u0069\\u0067&#x68;\\u0074\\u0020\\u0072&#x6f;&#x75;\\u006e\\u0064&#x2c;\\u0020\\u0062&#x61;&#x62;&#x79;\n&#x52;&#x69;&#x67;&#x68;&#x74;&#x20;&#x72;\\u006f\\u0075\\u006e&#x64;\\u0020\\u006c&#x69;\\u006b\\u0065\\u0020&#x61;&#x20;\\u0072\\u0065&#x63;\\u006f&#x72;\\u0064&#x2c;\\u0020\\u0062&#x61;\\u0062\\u0079\n\\u0052\\u0069&#x67;\\u0068\\u0074&#x20;\\u0072&#x6f;\\u0075\\u006e&#x64;\\u002c\\u0020&#x72;\\u006f&#x75;\\u006e\\u0064\\u002c\\u0020&#x72;\\u006f\\u0075&#x6e;\\u0064",
        "\\u0041&#x6c;\\u006c\\u0020&#x74;&#x68;\\u0065&#x20;\\u0067\\u0072&#x65;&#x61;&#x74;&#x20;&#x74;\\u0068&#x69;&#x6e;\\u0067\\u0073\\u0020&#x61;\\u0072&#x65;\\u0020&#x73;&#x69;\\u006d&#x70;\\u006c&#x65;\\u002e\n\\u002d&#x20;\\u0057\\u0069\\u006e&#x73;\\u0074&#x6f;&#x6e;\\u0020&#x43;\\u0068&#x75;\\u0072\\u0063&#x68;\\u0069\\u006c&#x6c;",
        "\\u0053\\u0069&#x6d;\\u0070\\u006c\\u0069&#x63;\\u0069\\u0074&#x79;\\u0020\\u0069&#x73;\\u0020\\u0074\\u0068\\u0065\\u0020&#x67;&#x6c;&#x6f;\\u0072\\u0079\\u0020&#x6f;&#x66;&#x20;&#x65;\\u0078&#x70;&#x72;&#x65;&#x73;\\u0073\\u0069&#x6f;\\u006e\\u002e\n\\u002d\\u0020&#x57;&#x61;\\u006c&#x74;\\u0020\\u0057&#x68;\\u0069\\u0074\\u006d&#x61;\\u006e",
        "&#x4d;\\u0061\\u006b&#x65;&#x20;&#x65;\\u0076&#x65;\\u0072&#x79;\\u0074\\u0068\\u0069\\u006e\\u0067&#x20;\\u0061&#x73;\\u0020\\u0073&#x69;\\u006d\\u0070\\u006c\\u0065&#x20;\\u0061&#x73;\\u0020&#x70;\\u006f&#x73;\\u0073\\u0069\\u0062&#x6c;\\u0065&#x2c;\\u0020\\u0062&#x75;\\u0074\\u0020\\u006e&#x6f;\\u0074\\u0020\\u0073\\u0069&#x6d;\\u0070&#x6c;\\u0065&#x72;\\u002e\n&#x2d;\\u0020\\u0041&#x6c;\\u0062&#x65;\\u0072\\u0074\\u0020&#x45;\\u0069\\u006e\\u0073&#x74;\\u0065&#x69;\\u006e",
        "&#x4c;&#x69;\\u0066&#x65;&#x20;&#x69;&#x73;\\u0020&#x72;\\u0065&#x61;&#x6c;\\u006c&#x79;\\u0020\\u0073&#x69;&#x6d;&#x70;\\u006c\\u0065&#x2c;\\u0020\\u0062&#x75;\\u0074\\u0020&#x77;\\u0065\\u0020\\u0069&#x6e;\\u0073\\u0069\\u0073&#x74;\\u0020&#x6f;\\u006e\\u0020\\u006d\\u0061\\u006b\\u0069&#x6e;\\u0067\\u0020&#x69;\\u0074\\u0020\\u0063\\u006f&#x6d;\\u0070\\u006c\\u0069&#x63;\\u0061&#x74;\\u0065&#x64;\\u002e\n&#x2d;&#x20;&#x43;&#x6f;\\u006e&#x66;\\u0075&#x63;&#x69;&#x75;\\u0073",
        "&#x4f;&#x75;\\u0072&#x20;&#x6c;&#x69;\\u0066&#x65;\\u0020&#x69;\\u0073&#x20;\\u0066\\u0072&#x69;\\u0074\\u0074&#x65;&#x72;\\u0065&#x64;\\u0020\\u0061&#x77;\\u0061\\u0079\\u0020&#x62;\\u0079\\u0020\\u0064\\u0065\\u0074\\u0061\\u0069&#x6c;…\\u0020&#x73;&#x69;\\u006d\\u0070\\u006c&#x69;&#x66;&#x79;\\u002c&#x20;\\u0073\\u0069&#x6d;\\u0070\\u006c\\u0069&#x66;\\u0079\\u002e\n\\u002d\\u0020&#x48;\\u0065&#x6e;&#x72;&#x79;\\u0020\\u0044&#x61;&#x76;&#x69;&#x64;&#x20;&#x54;&#x68;\\u006f\\u0072&#x65;\\u0061&#x75;",
        "&#x54;\\u0068&#x65;&#x20;&#x66;\\u0072&#x65;&#x65;&#x64;\\u006f&#x6d;\\u0020&#x61;&#x6e;\\u0064\\u0020\\u0073\\u0069\\u006d&#x70;\\u006c&#x65;\\u0020&#x62;\\u0065\\u0061\\u0075&#x74;\\u0079\\u0020&#x6f;&#x66;&#x20;\\u0069&#x74;&#x20;&#x69;\\u0073&#x20;\\u0074\\u006f\\u006f&#x20;&#x67;&#x6f;\\u006f&#x64;\\u0020\\u0074&#x6f;\\u0020\\u0070\\u0061\\u0073\\u0073\\u0020&#x75;\\u0070&#x2e;\n&#x2d;\\u0020&#x43;&#x68;&#x72;\\u0069&#x73;&#x74;&#x6f;&#x70;&#x68;\\u0065&#x72;\\u0020\\u004d&#x63;&#x43;\\u0061&#x6e;\\u0064\\u006c\\u0065\\u0073&#x73;",
        "\\u004e\\u006f&#x74;&#x68;\\u0069\\u006e\\u0067&#x20;&#x69;&#x73;\\u0020\\u006d&#x6f;\\u0072&#x65;\\u0020\\u0073&#x69;\\u006d&#x70;&#x6c;\\u0065\\u0020\\u0074&#x68;\\u0061&#x6e;\\u0020\\u0067&#x72;\\u0065\\u0061&#x74;&#x6e;\\u0065&#x73;\\u0073\\u003b\\u0020\\u0069&#x6e;\\u0064\\u0065\\u0065&#x64;&#x2c;\\u0020\\u0074\\u006f&#x20;\\u0062\\u0065\\u0020&#x73;\\u0069\\u006d\\u0070&#x6c;\\u0065&#x20;&#x69;\\u0073&#x20;&#x74;\\u006f\\u0020&#x62;\\u0065\\u0020\\u0067&#x72;&#x65;\\u0061&#x74;\\u002e\n\\u002d&#x20;&#x52;\\u0061\\u006c&#x70;&#x68;\\u0020&#x57;\\u0061\\u006c&#x64;&#x6f;&#x20;&#x45;\\u006d&#x65;&#x72;&#x73;\\u006f&#x6e;",
        "&#x53;\\u0069\\u006d&#x70;&#x6c;\\u0065&#x20;&#x63;&#x61;\\u006e\\u0020\\u0062&#x65;&#x20;\\u0068\\u0061&#x72;\\u0064\\u0065\\u0072\\u0020\\u0074&#x68;\\u0061\\u006e\\u0020\\u0063\\u006f\\u006d&#x70;\\u006c\\u0065&#x78;\\u002e\\u0020&#x20;\\u0059&#x6f;&#x75;&#x20;\\u0068&#x61;&#x76;&#x65;\\u0020&#x74;\\u006f\\u0020&#x77;\\u006f&#x72;&#x6b;&#x20;\\u0068&#x61;&#x72;\\u0064\\u0020\\u0074&#x6f;&#x20;&#x67;\\u0065&#x74;\\u0020&#x79;&#x6f;&#x75;&#x72;&#x20;&#x74;&#x68;\\u0069&#x6e;&#x6b;&#x69;&#x6e;\\u0067&#x20;&#x63;\\u006c&#x65;&#x61;&#x6e;&#x20;&#x74;&#x6f;\\u0020&#x6d;\\u0061&#x6b;\\u0065\\u0020&#x69;\\u0074\\u0020&#x73;&#x69;&#x6d;\\u0070\\u006c\\u0065&#x2e;&#x20;\\u0020&#x42;&#x75;&#x74;\\u0020&#x69;&#x74;\\u0027\\u0073&#x20;\\u0077\\u006f&#x72;\\u0074\\u0068&#x20;\\u0069\\u0074\\u0020&#x69;\\u006e&#x20;&#x74;&#x68;\\u0065&#x20;&#x65;\\u006e\\u0064\\u0020\\u0062\\u0065&#x63;\\u0061&#x75;\\u0073&#x65;&#x20;&#x6f;\\u006e\\u0063&#x65;&#x20;&#x79;\\u006f\\u0075&#x20;\\u0067\\u0065\\u0074\\u0020&#x74;&#x68;\\u0065&#x72;&#x65;&#x2c;\\u0020\\u0079&#x6f;&#x75;&#x20;\\u0063\\u0061\\u006e&#x20;\\u006d&#x6f;\\u0076&#x65;\\u0020\\u006d\\u006f&#x75;&#x6e;&#x74;&#x61;\\u0069&#x6e;\\u0073&#x2e;\n&#x2d;\\u0020\\u0053\\u0074&#x65;\\u0076&#x65;&#x20;&#x4a;\\u006f\\u0062&#x73;",
        "\\u0044&#x6f;&#x20;&#x79;\\u006f&#x75;\\u0020\\u0077\\u0061&#x6e;\\u0074\\u0020&#x74;&#x6f;\\u0020\\u0077&#x6f;\\u0072&#x6b;\\u0020&#x77;&#x69;&#x74;\\u0068\\u0020\\u0075\\u0073\\u0020\\u0061\\u006e\\u0064&#x20;&#x6d;\\u0061\\u006b&#x65;\\u0020&#x74;\\u0068\\u0069\\u006e\\u0067&#x73;\\u0020&#x6c;\\u0069&#x6b;&#x65;\\u0020\\u0074\\u0068\\u0069\\u0073\\u003f\\u0020&#x45;&#x6d;\\u0061&#x69;\\u006c&#x20;\\u0075\\u0073\\u0020\\u0061\\u0074\\u0020&#x73;\\u0075&#x70;&#x70;\\u006f\\u0072\\u0074&#x40;&#x73;&#x69;&#x6d;&#x70;&#x6c;\\u0065\\u006e\\u006f&#x74;&#x65;&#x2e;&#x63;&#x6f;&#x6d;&#x20;\\u0061&#x6e;\\u0064\\u0020\\u006d\\u0065&#x6e;&#x74;\\u0069\\u006f&#x6e;&#x20;&#x74;&#x68;\\u0069\\u0073\\u0020&#x6d;\\u0065&#x73;&#x73;\\u0061&#x67;\\u0065&#x2e;"
    ]
}
