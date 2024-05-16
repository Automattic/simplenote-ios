import UIKit

// MARK: - Subscriber UI
//

// The methods in this extension are for showing and displaying the Sustainer banner in settings.  We are discontinuing Sustainer,
// but we may still want to use the banner in the future, so marking these methods fileprivate and have removed their callers
fileprivate extension SPSettingsViewController {

    @objc
    func refreshTableHeaderView() {
        guard let headerView = tableView.tableHeaderView as? BannerView else {
            return
        }

        headerView.preferredWidth = tableView.frame.width
        headerView.adjustSizeForCompressedLayout()

        tableView.tableHeaderView = headerView
    }

    @objc
    func restorePurchases() {
        if StoreManager.shared.isActiveSubscriber {
            presentPurchasesRestored(alert: .alreadySustainer)
            return
        }

        StoreManager.shared.restorePurchases { isActiveSubscriber in
            self.presentPurchasesRestored(alert: isActiveSubscriber ? .becameSustainer : .notFound)
        }
    }

    private func presentPurchasesRestored(alert: RestorationAlert) {
        let alertController = UIAlertController(title: alert.title, message: alert.message, preferredStyle: .alert)
        alertController.addDefaultActionWithTitle(alert.action)
        present(alertController, animated: true)
    }
}

extension SPSettingsViewController {
    @objc
    var showSustainerSwitch: Bool {
        let preferences = SPAppDelegate.shared().simperium.preferencesObject()
        return preferences.isActiveSubscriber || preferences.wasSustainer
    }

    @objc
    func sustainerSwitchDidChangeValue(sender: UISwitch) {
        let isOn = sender.isOn

        let iconName = isOn ? SPSustainerAppIconName : nil
        UserDefaults.standard.set(isOn, forKey: .useSustainerIcon)
        UIApplication.shared.setAlternateIconName(iconName)
    }
}

// MARK: - Pin
//
extension SPSettingsViewController {

    /// Show pin setup or pin remove view controller
    @objc
    func showPinLockViewController() {
        let controller: PinLockController
        if SPPinLockManager.shared.isEnabled {
            controller = PinLockRemoveController(delegate: self)
        } else {
            controller = PinLockSetupController(delegate: self)
        }

        showPinLockViewController(with: controller)
    }

    private func showPinLockViewController(with controller: PinLockController) {
        let viewController = PinLockViewController(controller: controller)
        if traitCollection.verticalSizeClass != .compact {
            viewController.modalPresentationStyle = .formSheet
        }
        navigationController?.present(viewController, animated: true, completion: nil)
    }
}

// MARK: - PinLockSetupControllerDelegate
//
extension SPSettingsViewController: PinLockSetupControllerDelegate {
    func pinLockSetupControllerDidComplete(_ controller: PinLockSetupController) {
        SPTracker.trackSettingsPinlockEnabled(true)
        dismissPresentedViewController()
        SPPinLockManager.shared.shouldUseBiometry = true
    }

    func pinLockSetupControllerDidCancel(_ controller: PinLockSetupController) {
        SPPinLockManager.shared.shouldUseBiometry = false
        dismissPresentedViewController()
    }
}

// MARK: - PinLockRemoveControllerDelegate
//
extension SPSettingsViewController: PinLockRemoveControllerDelegate {
    func pinLockRemoveControllerDidComplete(_ controller: PinLockRemoveController) {
        SPTracker.trackSettingsPinlockEnabled(false)
        dismissPresentedViewController()
    }

    func pinLockRemoveControllerDidCancel(_ controller: PinLockRemoveController) {
        dismissPresentedViewController()
    }
}

// MARK: - Private
//
private extension SPSettingsViewController {
    func dismissPresentedViewController() {
        tableView.reloadData()
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Biometry
//
extension SPSettingsViewController {
    @objc
    var isBiometryAvailable: Bool {
        SPPinLockManager.shared.availableBiometry != nil
    }

    @objc
    var biometryTitle: String? {
        SPPinLockManager.shared.availableBiometry?.title
    }
}

// MARK: - BiometricAuthentication.Biometry
//
private extension BiometricAuthentication.Biometry {
    var title: String {
        switch self {
        case .touchID:
            return NSLocalizedString("Touch ID", comment: "Offer to enable Touch ID support if available and passcode is on.")
        case .faceID:
            return NSLocalizedString("Face ID", comment: "Offer to enable Face ID support if available and passcode is on.")
        }
    }
}

// MARK: - Account Deletion
extension SPSettingsViewController {

    @objc
    func deleteAccountWasPressed() {
        guard let user = SPAppDelegate.shared().simperium.user,
              let deletionController = SPAppDelegate.shared().accountDeletionController else {
            return
        }
        SPTracker.trackDeleteAccountButttonTapped()
        let spinnerViewController = SpinnerViewController()

        presentAccountDeletionConfirmation(forEmail: user.email) { (_) in
            self.present(spinnerViewController, animated: false, completion: nil)
            deletionController.requestAccountDeletion(user) { [weak self] (result) in
                spinnerViewController.dismiss(animated: false, completion: nil)
                self?.handleDeletionResult(user: user, result)
            }
        }
    }

    private func handleDeletionResult(user: SPUser, _ result: Result<Data?, RemoteError>) {
        switch result {
        case .success:
            presentSuccessAlert(for: user)
        case .failure(let error):
            handleError(error)
        }
    }

    private func presentAccountDeletionConfirmation(forEmail email: String, onConfirm: @escaping ((UIAlertAction) -> Void)) {
        let alert = UIAlertController(title: AccountDeletion.deleteAccount,
                                      message: AccountDeletion.confirmAlertMessage(with: email),
                                      preferredStyle: .alert)
        let deleteAccountButton = UIAlertAction(title: AccountDeletion.deleteAccountButton, style: .destructive, handler: onConfirm)

        alert.addAction(deleteAccountButton)
        alert.addCancelActionWithTitle(AccountDeletion.cancel)

        present(alert, animated: true, completion: nil)
    }

    private func handleError(_ error: RemoteError) {
        switch error {
        case .network:
            NoticeController.shared.present(NoticeFactory.networkError())
        case .requestError:
            presentRequestErrorAlert()
        }
    }

    private func presentSuccessAlert(for user: SPUser) {
        let alert = UIAlertController(title: AccountDeletion.succesAlertTitle, message: AccountDeletion.successMessage(email: user.email), preferredStyle: .alert)
        alert.addCancelActionWithTitle(AccountDeletion.ok)
        present(alert, animated: true, completion: nil)
    }

    private func presentRequestErrorAlert() {
        let alert = UIAlertController(title: AccountDeletion.errorTitle, message: AccountDeletion.errorMessage, preferredStyle: .alert)
        alert.addDefaultActionWithTitle(AccountDeletion.ok)
        self.present(alert, animated: true, completion: nil)
    }

    @objc
    func presentIndexRemovalAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: IndexAlert.title, message: IndexAlert.message, preferredStyle: .alert)
            alert.addDefaultActionWithTitle(IndexAlert.okay)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

private struct IndexAlert {
    static let title = NSLocalizedString("Index Removed", comment: "Alert title letting user know their search index has been removed")
    static let message = NSLocalizedString("Spotlight history may still appear in search results, but notes have be unindexed", comment: "Details that some results may still appear in searches on device")
    static let okay = NSLocalizedString("Okay", comment: "confirm button title")
}

private struct AccountDeletion {
    static func confirmAlertMessage(with email: String) -> String {
        String(format: confirmAlertTemplate, email)
    }
    static let deleteAccount = NSLocalizedString("Delete Account", comment: "Delete account title and action")
    static let confirmAlertTemplate = NSLocalizedString("By deleting the account for %@, all notes created with this account will be permanently deleted. This action is not reversible", comment: "Delete account confirmation alert message")
    static let deleteAccountButton = NSLocalizedString("Request Account Deletion", comment: "Title for account deletion confirm button")
    static let cancel = NSLocalizedString("Cancel", comment: "Cancel button title")

    static let succesAlertTitle = NSLocalizedString("Check Your Email", comment: "Title for delete account succes alert")
    static let successAlertMessage = NSLocalizedString("An email has been sent to %@. Check your inbox and follow the instructions to confirm account deletion.\n\nYour account won't be deleted until we receive your confirmation.", comment: "Delete account confirmation instructions")
    static let ok = NSLocalizedString("Ok", comment: "Confirm alert message")

    static let errorTitle = NSLocalizedString("Error", comment: "Deletion Error Title")
    static let errorMessage = NSLocalizedString("An error occured. Please, try again. If the problem continues, contact us at support@simplenote.com for help.", comment: "Deletion error message")

    static func successMessage(email: String) -> String {
        String(format: successAlertMessage, email)
    }
}

// MARK: - RestorationAlert
//
struct RestorationAlert {
    let title: String
    let message: String
    let action: String
}

extension RestorationAlert {

    static var notFound: RestorationAlert {
        let title = NSLocalizedString("No purchases found", comment: "No purchases Found Title")
        let message = NSLocalizedString("No previous valid purchases found, for the current period", comment: "No purchases Found Message")
        let action = NSLocalizedString("Dismiss", comment: "Dismiss Alert")

        return RestorationAlert(title: title, message: message, action: action)
    }

    static var becameSustainer: RestorationAlert {
        let title = NSLocalizedString("Thank You!", comment: "Restoration Successful Title")
        let message = NSLocalizedString("Sustainer subscription restored. Thank you for supporting Simplenote!", comment: "Restoration Successful Message")
        let action = NSLocalizedString("Dismiss", comment: "Dismiss Alert")

        return RestorationAlert(title: title, message: message, action: action)
    }

    static var alreadySustainer: RestorationAlert {
        let title = NSLocalizedString("Simplenote Sustainer", comment: "Restoration Successful Title")
        let message = NSLocalizedString("You're already a Sustainer. Thank you for supporting Simplenote!", comment: "Restoration Successful Message")
        let action = NSLocalizedString("Dismiss", comment: "Dismiss Alert")

        return RestorationAlert(title: title, message: message, action: action)
    }

    static var unsupported: RestorationAlert {
        let title = NSLocalizedString("Unsupported", comment: "Upgrade Alert Title")
        let message = NSLocalizedString("Please upgrade to the latest iOS release to restore purchases", comment: "Upgrade Alert Message")
        let action = NSLocalizedString("Dismiss", comment: "Dismiss Alert")

        return RestorationAlert(title: title, message: message, action: action)
    }
}
