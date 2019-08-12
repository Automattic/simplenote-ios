import Foundation


// MARK: - Simplenote's Upgrade handling flows
//
class MigrationsHandler: NSObject {

    /// Returns the Runtime version
    ///
    private let runtimeVersion = Bundle.main.shortVersionString

    /// Stores the last known version.
    ///
    /// - Note: When this property is empty, we'll tamper into the `WordPress-Ratings-iOS` framework's internal UserDefaults key.
    ///   Why? Because we ... really need to. *Do NOT* attempt this at home.
    ///
    private var lastKnownVersion: String {
        get {
            return UserDefaults.standard.string(forKey: .lastKnownVersion)
                ?? UserDefaults.standard.string(forKey: .lastKnownVersionByRatingsFramework)
                ?? String()
        }
        set {
            UserDefaults.standard.set(newValue, forKey: .lastKnownVersion)
        }
    }

    /// Processes any routines required to (safely) handle App Version Upgrades.
    ///
    @objc
    func ensureUpdateIsHandled() {
        guard runtimeVersion != lastKnownVersion else {
            return
        }

        processMigrations(from: lastKnownVersion, to: runtimeVersion)
        lastKnownVersion = runtimeVersion
    }
}


// MARK: - Private Methods
//
private extension MigrationsHandler {

    /// Handles a migration *from* a given version, *towards* a given version
    ///
    func processMigrations(from: String, to: String) {
        switch (from, to) {
        case (SimplenoteVersion.mk4_8_0, _):
            processMigrationFromMark4_8_0()
        default:
            break
        }
    }
}


// MARK: - Migration from 4.8.0
//
private extension MigrationsHandler {

    /// Display the Sort Options Reset Alert whenever:
    ///
    /// A.  The user comes from 4.8.0
    /// B.  The user is actually logged
    /// C.  The "bad Sort Mode" flag is detected
    ///
    func processMigrationFromMark4_8_0() {
        let simperium = SPAppDelegate.shared().simperium
        guard Options.shared.listSortMode == .alphabeticallyDescending,
            simperium.user.authenticated() == true
            else {
                    return
        }

        presentSortOptionsResetAlert()
    }

    /// Presents the Sort Options Alert
    ///
    func presentSortOptionsResetAlert() {
        let title = String()
        let message = NSLocalizedString("Our update may have changed the order in which your notes appear. Would you like to review sort settings?",
                                     comment: "AlertController's Payload for the broken Sort Options Fix")

        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let cancelText = NSLocalizedString("No", comment: "Alert's Cancel Action")
        controller.addActionWithTitle(cancelText, style: .cancel)

        let okText = NSLocalizedString("Yes", comment: "Alert's Accept Action")
        controller.addActionWithTitle(okText, style: .default) { _ in
            self.presentSortOptionsViewController()
        }

        controller.presentFromRootViewController()
    }

    /// Presents (Modally) the SortOptions Interface
    ///
    func presentSortOptionsViewController() {
        let sortingViewController = SPSortOrderViewController()
        sortingViewController.displaysDismissButton = true
        sortingViewController.selectedMode = Options.shared.listSortMode
        sortingViewController.onChange = { newMode in
            Options.shared.listSortMode = newMode
        }

        let navigationController = SPNavigationController(rootViewController: sortingViewController)
        navigationController.modalPresentationStyle = .formSheet
        navigationController.presentFromRootViewController()
    }
}


// MARK: - Known App Versions
//
private enum SimplenoteVersion {
    static let mk4_8_0 = "4.8.0"
    static let mk4_8_1 = "4.8.1"
}
