import Foundation
import UIKit


/// Privacy: Lets our users Opt Out from any (and all) trackers.
///
class SPPrivacyViewController: SPTableViewController {

    /// Switch Control: Rules the Analytics State
    ///
    private let analyticsSwitch = UISwitch()

    /// FooterView: Legend displayed below the Switch Row
    ///
    private let footerView = UITableViewHeaderFooterView()



    // MARK: - Overridden Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setupTableView()
        setupFooterView()
        setupSwitch()
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return Defaults.sectionsCount
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Defaults.rowCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        setupAnalyticsCell(cell)
        return cell
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footerView
    }

    var isAnalyticsEnabled: Bool {
        guard let simperium = SPAppDelegate.shared()?.simperium, let preferences = simperium.preferencesObject() else {
            return true
        }

        return preferences.analytics_enabled?.boolValue ==  true
    }
}


// MARK - Event Handlers
//
extension SPPrivacyViewController {

    /// Updates the Analytics Setting
    ///
    @objc func switchDidChange(sender: UISwitch) {
        guard let simperium = SPAppDelegate.shared()?.simperium, let preferences = simperium.preferencesObject() else {
            return
        }

        preferences.analytics_enabled = NSNumber(booleanLiteral: sender.isOn)
        simperium.save()
    }

    /// Opens the `kAutomatticAnalyticLearnMoreURL` in Apple's Safari.
    ///
    @objc func displayPrivacyLink() {
        guard let url = URL(string: kAutomatticAnalyticLearnMoreURL) else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
        tableView.applyDefaultGroupedStyling()
    }

    /// Setup: Switch
    ///
    func setupSwitch() {
        let theme = VSThemeManager.shared()?.theme()
        analyticsSwitch.onTintColor = theme?.color(forKey: "switchOnTintColor")
        analyticsSwitch.tintColor = theme?.color(forKey: "switchTintColor")
        analyticsSwitch.addTarget(self, action: #selector(switchDidChange(sender:)), for: .valueChanged)
        analyticsSwitch.isOn = isAnalyticsEnabled
    }

    /// Setup: Footer View
    ///
    func setupFooterView() {
        let textLabel = footerView.textLabel
        textLabel?.text = NSLocalizedString("Help us improve Simplenote by sharing usage data with our analytics tool. Learn More.", comment: "Privacy Footer Text")
        textLabel?.numberOfLines = 0
        textLabel?.font = UIFont.preferredFont(forTextStyle: .footnote)
        textLabel?.isUserInteractionEnabled = true

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(displayPrivacyLink))
        footerView.addGestureRecognizer(recognizer)
    }

    /// Setup: UITableViewCell so that the current Analytics Settings are displayed
    ///
    func setupAnalyticsCell(_ cell: UITableViewCell) {
        cell.textLabel?.text = NSLocalizedString("Share Analytics", comment: "Option to disable Analytics.")
        cell.selectionStyle = .none
        cell.accessoryView = analyticsSwitch
    }
}


// MARK: - Constants
//
private enum Defaults {
    static let rowCount = 1
    static let sectionsCount = 1
}
