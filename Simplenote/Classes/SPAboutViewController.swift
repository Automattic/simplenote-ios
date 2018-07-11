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
    private let doneButton = UIButton(type: UIButtonType.custom)
    
    private let simpleBlue = UIColor(red: 74/255, green: 149/255, blue: 213/255, alpha: 1.0)
    private let lightBlue = UIColor(red: 118/255, green: 175/255, blue: 223/255, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = simpleBlue
        self.view.addSubview(tableView)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        self.tableView.separatorColor = lightBlue
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        addHeaderView()
        addFooterView()
        addDoneButton()
    
        self.view.addSubview(doneButton)
    }
    
    func addHeaderView() {
        headerView.backgroundColor = simpleBlue
        
        let imageView = UIImageView(image: UIImage(named: "logo_about"))
        imageView.frame = CGRect(x: 0, y: 20, width: 100, height: 100)
        imageView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        
        let appNameLabel = UILabel(frame:CGRect(x: 0, y: 120, width: 320, height: 24))
        appNameLabel.text = Bundle.main.infoDictionary!["CFBundleName"] as? String
        appNameLabel.textColor = UIColor.white
        appNameLabel.font = UIFont.systemFont(ofSize: 24)
        appNameLabel.textAlignment = NSTextAlignment.center
        appNameLabel.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        
        let versionLabel = UILabel(frame:CGRect(x: 0, y: 146, width: 320, height: 14))
        let versionNumber = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        versionLabel.text = String(format: NSLocalizedString("Version %@", comment: "App version number"), versionNumber!)
        versionLabel.textColor = UIColor.white
        versionLabel.font = UIFont.systemFont(ofSize: 14)
        versionLabel.textAlignment = NSTextAlignment.center
        versionLabel.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        
        headerView.addSubview(imageView)
        headerView.addSubview(appNameLabel)
        headerView.addSubview(versionLabel)
        
        self.view.addSubview(headerView)
    }
    
    func addFooterView() {
        let frame = self.view.frame;
        // UITextViews have padding, so height of 26 is needed to accomodate the extra space
        let serviceTextView = UITextView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 26))
        serviceTextView.backgroundColor = UIColor.clear
        serviceTextView.font = UIFont.systemFont(ofSize: 14)
        serviceTextView.textAlignment = NSTextAlignment.center
        serviceTextView.textColor = UIColor.white
        serviceTextView.isEditable = false
        serviceTextView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        
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
        
        let copyrightLabel = UILabel(frame: CGRect(x: 0, y: 30, width: 200, height: 14))
        copyrightLabel.font = UIFont.systemFont(ofSize: 14)
        copyrightLabel.textAlignment = NSTextAlignment.center
        copyrightLabel.textColor = UIColor.white
        copyrightLabel.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        copyrightLabel.text = String(format: "\u{00A9} %@ Automattic", formatter.string(from: Date()))
        
        footerView.addSubview(serviceTextView)
        footerView.addSubview(copyrightLabel)
        
        self.view.addSubview(footerView)
    }
    
    func addDoneButton() {
        doneButton.setTitle(NSLocalizedString("Done", comment: "Verb: Close current view"), for: UIControlState.normal)
        doneButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        doneButton.setTitleColor(lightBlue, for: UIControlState.highlighted)
        doneButton.addTarget(self, action: #selector(onDoneTap(_:)), for: UIControlEvents.touchUpInside)
        doneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.right
    }
    
    override func viewDidLayoutSubviews() {
        let frame = self.view.frame;
        var headerYPosition: CGFloat = 0
        var adjustedFooterHeight: CGFloat = footerHeight
        var doneButtonXPosition = frame.size.width - doneButtonWidth - 15
        
        // Adjust positioning of view on devices like iPhone X
        if #available(iOS 11.0, *) {
            headerYPosition += self.view.safeAreaInsets.top
            adjustedFooterHeight += self.view.safeAreaInsets.bottom
            doneButtonXPosition -= self.view.safeAreaInsets.right
        }
        let headerSize = headerHeight + headerYPosition
        
        headerView.frame = CGRect(x: 0, y: headerYPosition, width: frame.size.width, height: headerHeight)
        tableView.frame = CGRect(x: frame.origin.x, y: headerSize, width: frame.size.width, height: frame.size.height - adjustedFooterHeight - headerSize)
        footerView.frame = CGRect(x: 0, y: frame.size.height - adjustedFooterHeight, width: frame.size.width, height: adjustedFooterHeight)
        doneButton.frame = CGRect(x: doneButtonXPosition, y: headerYPosition + 10, width: doneButtonWidth, height: 17)
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
        self.dismiss(animated: true)
    }
}
