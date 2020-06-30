import UIKit


class SPAboutViewController: UIViewController {
    
    private let headerView = UIView()
    private let footerView = UIView()
    private let tableView = UITableView()
    private let containerView = UIStackView()
    private let doneButton = UIButton(type: .custom)


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
        doneButton.setTitle(NSLocalizedString("Done", comment: "Verb: Close current view"), for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.addTarget(self, action: #selector(onDoneTap(_:)), for: .touchUpInside)
        doneButton.contentHorizontalAlignment = .right

        view.addSubview(doneButton)

        NSLayoutConstraint.activate([
            doneButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            doneButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
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
            containerView.topAnchor.constraint(equalTo: doneButton.bottomAnchor, constant: -14.0),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14.0)
            ])
    }

    func setupHeaderView() {
        headerView.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = 0
        headerView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: headerView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
            ])

        let imageView = UIImageView(image: UIImage(named: "logo_about"))
        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 100)
            ])

        stackView.addArrangedSubview(imageView)

        let appNameLabel = UILabel()
        appNameLabel.translatesAutoresizingMaskIntoConstraints = false
        appNameLabel.text = Bundle.main.infoDictionary!["CFBundleName"] as? String
        appNameLabel.textColor = UIColor.white
        appNameLabel.font = UIFont.systemFont(ofSize: 24)
        appNameLabel.textAlignment = NSTextAlignment.center
        stackView.addArrangedSubview(appNameLabel)

        NSLayoutConstraint.activate([
            appNameLabel.widthAnchor.constraint(equalToConstant: 320),
            appNameLabel.heightAnchor.constraint(equalToConstant: 24)
            ])

        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: 3.0).isActive = true
        stackView.addArrangedSubview(spacer)

        let versionLabel = UILabel()
        let versionNumber = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        versionLabel.text = String(format: NSLocalizedString("Version %@", comment: "App version number"), versionNumber!)
        versionLabel.textColor = UIColor.white
        versionLabel.font = UIFont.systemFont(ofSize: 14)
        versionLabel.textAlignment = NSTextAlignment.center
        stackView.addArrangedSubview(versionLabel)

        NSLayoutConstraint.activate([
            versionLabel.widthAnchor.constraint(equalToConstant: 320),
            versionLabel.heightAnchor.constraint(equalToConstant: 14)
            ])

        containerView.addArrangedSubview(headerView)
    }
    
    func setupFooterView() {
        footerView.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 2.0
        footerView.addSubview(stackView)

        let serviceTextView = UITextView()
        serviceTextView.translatesAutoresizingMaskIntoConstraints = false
        serviceTextView.backgroundColor = UIColor.clear
        serviceTextView.font = UIFont.systemFont(ofSize: 14)
        serviceTextView.textAlignment = NSTextAlignment.center
        serviceTextView.textColor = UIColor.white
        serviceTextView.isEditable = false
        serviceTextView.isScrollEnabled = false

        // Set up attributed string with clickable links for privacy and terms
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let serviceString = String(format: "%@ \u{2022} %@ \n %@", Constants.privacyString, Constants.termsString, Constants.californiaString)
        let serviceAttrString = NSMutableAttributedString(string: serviceString, attributes: [
            .foregroundColor: UIColor.white,
            .paragraphStyle: paragraphStyle,
            .font: UIFont.systemFont(ofSize: 14)
        ])

        let foundationString = serviceAttrString.foundationString
        let rangeOfPrivacy = foundationString.range(of: Constants.privacyString)
        let rangeOfTerms = foundationString.range(of: Constants.termsString)
        let rangeOfNotice = foundationString.range(of: Constants.californiaString)

        serviceAttrString.addAttribute(.link, value: Constants.privacyURLString, range: rangeOfPrivacy)
        serviceAttrString.addAttribute(.link, value: Constants.termsURLString, range: rangeOfTerms)
        serviceAttrString.addAttribute(.link, value: Constants.californiaURLString, range: rangeOfNotice)

        serviceTextView.attributedText = serviceAttrString
        
        let linkAttributes: [String : Any] = [NSAttributedString.Key.foregroundColor.rawValue: UIColor.white]
        serviceTextView.linkTextAttributes = convertToOptionalNSAttributedStringKeyDictionary(linkAttributes)
        
        let copyrightLabel = UILabel()
        copyrightLabel.translatesAutoresizingMaskIntoConstraints = false
        copyrightLabel.font = UIFont.systemFont(ofSize: 14)
        copyrightLabel.textAlignment = NSTextAlignment.center
        copyrightLabel.textColor = UIColor.white
        copyrightLabel.text = createCopyrightString()

        stackView.addArrangedSubview(serviceTextView)
        stackView.addArrangedSubview(copyrightLabel)

        containerView.addArrangedSubview(footerView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: footerView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: footerView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
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

    func createCopyrightString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return String(format: "\u{00A9} %@ Automattic", formatter.string(from: Date()))
    }

    // Helper function inserted by Swift 4.2 migrator.
    func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
        guard let input = input else { return nil }
        return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
    }
}


// MARK: - Constants
//
private enum Constants {

    static let headerHeight: CGFloat    = 170
    static let footerHeight: CGFloat    = 60
    static let doneButtonWidth: CGFloat = 100

    static let privacyString    = NSLocalizedString("Privacy Policy", comment: "Simplenote privacy policy")
    static let privacyURLString = "https://simplenote.com/privacy/"
    static let termsString      = NSLocalizedString("Terms of Service", comment: "Simplenote terms of service")
    static let termsURLString   = "https://simplenote.com/terms/"
    static let californiaString = NSLocalizedString("California Users Privacy Notice", comment: "Simplenote terms of service")
    static let californiaURLString = "https://automattic.com/privacy/#california-consumer-privacy-act-ccpa"

    static let titles: [String] = [
        NSLocalizedString("Blog", comment: "The Simplenote blog"),
        "Twitter",
        NSLocalizedString("Apps", comment: "Other Simplenote apps"),
        NSLocalizedString("Contribute", comment: "Contribute to the Simplenote apps on github"),
        NSLocalizedString("Work With Us", comment: "Work at Automattic")
    ]

    static let descriptions: [String] = [
        "simplenote.com/blog",
        "@simplenoteapp",
        "simplenote.com",
        "GitHub.com",
        NSLocalizedString("Are you a developer? Automattic is hiring.", comment: "Automattic hiring description")
    ]

    static let urls: [URL] = [
        URL(string: "https://simplenote.com/blog")!,
        URL(string: "https://twitter.com/simplenoteapp")!,
        URL(string: "https://simplenote.com")!,
        URL(string: "https://github.com/automattic/simplenote-ios")!,
        URL(string: "https://automattic.com/work-with-us")!
    ]
}
