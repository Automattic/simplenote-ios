import Foundation
import UIKit
import Gridicons
//import AutomatticTracks

/// Privacy: Lets our users Opt Out from any (and all) trackers.
///
class SPPrivacyViewController: SPTableViewController {

    /// Switch Control: Rules the Analytics State
    ///
    private let analyticsSwitch = UISwitch()

    /// TableView Sections
    ///
    private var sections: [Section] {
        var sections = [ Section(rows: [.share, .legend, .learn]) ]

        if BuildConfiguration.is(.debug) {
            sections.append(Section(rows: [.crash]))
        }

        return sections
    }

    /// Indicates if Analytics are Enabled
    ///
    private var isAnalyticsEnabled: Bool {
        let simperium = SPAppDelegate.shared().simperium
        guard let isAnalyticsEnabled = simperium.preferencesObject().analytics_enabled else {
            return true
        }

        return isAnalyticsEnabled.boolValue
    }


    // MARK: - Overridden Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setupTableView()
        setupSwitch()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        switch rowAtIndexPath(indexPath) {
        case .share:
            setupAnalyticsCell(cell)
        case .legend:
            setupLegendCell(cell)
        case .learn:
            setupLearnMoreCell(cell)
        case .crash:
            setupCrashCell(cell)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch rowAtIndexPath(indexPath) {
        case .learn:
            displayPrivacyLink()
        case .crash:
            CrashLoggingShim.shared.crash()
        default:
            break
        }
    }

    /// Returns the Row at the specified IndexPath
    ///
    private func rowAtIndexPath(_ indexPath: IndexPath) -> Row {
        return sections[indexPath.section].rows[indexPath.row]
    }
}


// MARK: - Event Handlers
//
extension SPPrivacyViewController {

    /// Updates the Analytics Setting
    ///
    @objc func switchDidChange(sender: UISwitch) {
        let simperium = SPAppDelegate.shared().simperium
        let preferences = simperium.preferencesObject()

        preferences.analytics_enabled = NSNumber(booleanLiteral: sender.isOn)
        simperium.save()
    }

    /// Opens the `kAutomatticAnalyticLearnMoreURL` in Apple's Safari.
    ///
    @objc func displayPrivacyLink() {
        guard let url = URL(string: kAutomatticAnalyticLearnMoreURL) else {
            return
        }

        UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
    }
}


// MARK: - Initialization Methods
//
private extension SPPrivacyViewController {

    /// Setup: NavigationItem
    ///
    func setupNavigationItem() {
        title = NSLocalizedString("Privacy Settings", comment: "Privacy Settings")
    }

    /// Setup: TableView
    ///
    func setupTableView() {
        tableView.applySimplenoteGroupedStyle()
    }

    /// Setup: Switch
    ///
    func setupSwitch() {
        analyticsSwitch.onTintColor = .simplenoteSwitchOnTintColor
        analyticsSwitch.tintColor = .simplenoteSwitchTintColor
        analyticsSwitch.addTarget(self, action: #selector(switchDidChange(sender:)), for: .valueChanged)
        analyticsSwitch.isOn = isAnalyticsEnabled
    }

    /// Setup: UITableViewCell so that the current Analytics Settings are displayed
    ///
    func setupAnalyticsCell(_ cell: UITableViewCell) {
        cell.imageView?.image = Gridicon.iconOfType(.stats)
        cell.textLabel?.text = NSLocalizedString("Share Analytics", comment: "Option to disable Analytics.")
        cell.selectionStyle = .none
        cell.accessoryView = analyticsSwitch
    }

    /// Setup: Legend
    ///
    func setupLegendCell(_ cell: UITableViewCell) {
        cell.imageView?.image = Gridicon.iconOfType(.info)
        cell.textLabel?.text = NSLocalizedString("Help us improve Simplenote by sharing usage data with our analytics tool.", comment: "Privacy Details")
        cell.textLabel?.numberOfLines = 0
        cell.selectionStyle = .none
    }

    /// Setup: Learn More
    ///
    func setupLearnMoreCell(_ cell: UITableViewCell) {
        // Placeholder: This way we'll get an even left padding
        UIGraphicsBeginImageContext(Gridicon.defaultSize)
        cell.imageView?.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        // And the actual text!
        cell.textLabel?.text = NSLocalizedString("Learn more", comment: "Learn More Action")
        cell.textLabel?.textColor = .simplenoteTintColor
    }

    /// Setup: Crash
    ///
    func setupCrashCell(_ cell: UITableViewCell) {
        cell.imageView?.image = Gridicon.iconOfType(.bug)
        cell.textLabel?.text = NSLocalizedString("Send a Test Crash", comment: "For debugging use")
        cell.textLabel?.numberOfLines = 0
        cell.selectionStyle = .none
    }
}


// MARK: - Private Types
//
private struct Section {
    let rows: [Row]
}

private enum Row {
    case share
    case crash
    case legend
    case learn
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
