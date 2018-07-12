//
//  SPAboutViewController.swift
//  Simplenote
//  The About view for Simplenote
//

import UIKit

class SPAboutViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let titles: [String] = [
        NSLocalizedString("Blog", comment: "The Simplenote blog"),
        "Twitter",
        NSLocalizedString("Apps", comment: "Other Simplenote apps"),
        "Simperium",
        NSLocalizedString("Contribute", comment: "Contribute to the Simplenote apps on github"),
        NSLocalizedString("Work With Us", comment: "Work at Automattic")
    ]
    
    private let descriptions: [String] = [
        "simplenote.com/blog",
        "@simplenoteapp",
        "simplenote.com",
        NSLocalizedString("Add data sync to your app", comment: "Simperium description"),
        "GitHub.com",
        NSLocalizedString("Are you a developer? Automattic is hiring.", comment: "Automattic hiring description")
    ]
    
    private let headerHeight: CGFloat = 170
    private let footerHeight: CGFloat = 60
    private let doneButtonWidth: CGFloat = 100
    
    private let headerView = UIView()
    private let footerView = UIView()
    private let tableView = UITableView()
    private let containerView = UIStackView()
    private let doneButton = UIButton(type: UIButtonType.custom)
    
    private let simpleBlue = UIColor(red: 74/255, green: 149/255, blue: 213/255, alpha: 1.0)
    private let lightBlue = UIColor(red: 118/255, green: 175/255, blue: 223/255, alpha: 1.0)

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = simpleBlue

        addDoneButton()
        addContainerView()
        addHeaderView()
        addTableView()
        addFooterView()
    }

    func addDoneButton() {
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.setTitle(NSLocalizedString("Done", comment: "Verb: Close current view"), for: UIControlState.normal)
        doneButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        doneButton.setTitleColor(lightBlue, for: UIControlState.highlighted)
        doneButton.addTarget(self, action: #selector(onDoneTap(_:)), for: UIControlEvents.touchUpInside)
        doneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.right

        view.addSubview(doneButton)

        NSLayoutConstraint.activate([
            doneButton.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15.0)
            ])
    }

    func addContainerView() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.axis = .vertical
        containerView.alignment = .fill
        containerView.spacing = 10.0
        view.insertSubview(containerView, belowSubview: doneButton)

        var bottomAnchor = bottomLayoutGuide.topAnchor
        if #available(iOS 11.0, *) {
            bottomAnchor = view.safeAreaLayoutGuide.bottomAnchor
        }

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: doneButton.bottomAnchor, constant: -14.0),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14.0)
            ])
    }

    func addHeaderView() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = simpleBlue

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
    
    func addFooterView() {
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

        // UITextViews have padding, so height of 26 is needed to accommodate the extra space
        serviceTextView.heightAnchor.constraint(equalToConstant: 26.0).isActive = true
        
        let privacyString = NSLocalizedString("Privacy Policy", comment: "Simplenote privacy policy")
        let termsString = NSLocalizedString("Terms of Service", comment: "Simplenote terms of service")
        
        // Set up attributed string with clickable links for privacy and terms
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let serviceString = NSMutableAttributedString(string: String(format: "%@ \u{2022} %@", privacyString, termsString), attributes: [
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.paragraphStyle: paragraphStyle,
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)
            ])
        
        
        serviceString.addAttribute(NSAttributedStringKey.link, value: "https://simplenote.com/privacy/", range: NSMakeRange(0, privacyString.count))
        serviceString.addAttribute(NSAttributedStringKey.link, value: "https://simplenote.com/terms/", range: NSMakeRange(privacyString.count + 3, termsString.count))
        serviceTextView.attributedText = serviceString
        
        let linkAttributes: [String : Any] = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.white]
        serviceTextView.linkTextAttributes = linkAttributes
        
        let copyrightLabel = UILabel()
        copyrightLabel.translatesAutoresizingMaskIntoConstraints = false
        copyrightLabel.font = UIFont.systemFont(ofSize: 14)
        copyrightLabel.textAlignment = NSTextAlignment.center
        copyrightLabel.textColor = UIColor.white
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        copyrightLabel.text = String(format: "\u{00A9} %@ Automattic", formatter.string(from: Date()))

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

    func addTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        tableView.separatorColor = lightBlue
        tableView.backgroundColor = UIColor.clear
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.indicatorStyle = .white

        containerView.addArrangedSubview(tableView)
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "reuseIdentifier")

        cell.textLabel?.text = titles[indexPath.row]
        cell.detailTextLabel?.text = descriptions[indexPath.row]
        
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.textColor = UIColor.white
        cell.backgroundColor = UIColor.clear
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = lightBlue
        cell.selectedBackgroundView = bgColorView
        
        let arrowAccessoryView = UIImageView(image: UIImage(named: "icon_arrow_top_right"))
        arrowAccessoryView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        cell.accessoryView = arrowAccessoryView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(indexPath.row) {
        case 0:
            UIApplication.shared.open(URL(string: "https://simplenote.com/blog")!)
            break;
        case 1:
            UIApplication.shared.open(URL(string: "https://twitter.com/simplenoteapp")!)
            break;
        case 2:
            UIApplication.shared.open(URL(string: "https://simplenote.com")!)
            break;
        case 3:
            UIApplication.shared.open(URL(string: "https://simperium.com")!)
            break;
        case 4:
            UIApplication.shared.open(URL(string: "https://github.com/automattic/simplenote-ios")!)
            break;
        case 5:
            UIApplication.shared.open(URL(string: "https://automattic.com/work-with-us")!)
            break;
        default:
            break;
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    @objc func onDoneTap(_ sender:UIButton) {
        dismiss(animated: true)
    }
}
