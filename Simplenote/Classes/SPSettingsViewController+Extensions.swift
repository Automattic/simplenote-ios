import UIKit

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
    func deleteAccount() {
        guard let user = SPAppDelegate.shared().simperium.user else {
            return
        }

        let deletionController = accountDeletionController(for: user)

        let alert = UIAlertController(title: AccountDeletion.deleteAccount,
                                      message: AccountDeletion.confirmAlertMessage,
                                      preferredStyle: .alert)
        alert.addDestructiveActionWithTitle(AccountDeletion.deleteAccount) { ( _ ) in
            deletionController.requestAccountDeletion(user)
        }
        alert.addCancelActionWithTitle(AccountDeletion.cancel)

        present(alert, animated: true, completion: nil)
    }

    private func accountDeletionController(for user: SPUser) -> AccountDeletionController {
        let deletionController = AccountDeletionController()
        deletionController.successHandler = {
            self.presentSuccessAlert(for: user)
        }

        return deletionController
    }

    private func presentSuccessAlert(for user: SPUser) {
        let alert = UIAlertController(title: AccountDeletion.succesAlertTitle, message: AccountDeletion.successMessage(email: user.email), preferredStyle: .alert)
        alert.addCancelActionWithTitle(AccountDeletion.ok)
        present(alert, animated: true, completion: nil)
    }
}

private struct AccountDeletion {
    static let deleteAccount = NSLocalizedString("Delete Account", comment: "Delete account title and action")
    static let confirmAlertMessage = NSLocalizedString("By deleting your account, all notes created with this account will be permanently deleted. This action is not reversible", comment: "Delete account confirmation alert message")
    static let cancel = NSLocalizedString("Cancel", comment: "Cancel button title")

    static let succesAlertTitle = NSLocalizedString("Delete Account", comment: "Title for delete account alert")
    static let successAlertMessage = NSLocalizedString("An email has been sent to %@ Check your inbox and follow the instructions to confirm account deletion.", comment: "Delete account confirmation instructions")
    static let ok = NSLocalizedString("Ok", comment: "Confirm alert message")

    static func successMessage(email: String) -> String {
        String(format: successAlertMessage, email)
    }
}
