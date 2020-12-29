import UIKit

// MARK: - Pin
//
extension SPSettingsViewController {

    /// Show view controller to setup pin
    ///
    @objc
    func showPinLockSetupViewController() {
        let controller = PinLockSetupController(delegate: self)
        let viewController = PinLockViewController(controller: controller)
        viewController.modalPresentationStyle = .formSheet

        navigationController?.present(viewController, animated: true, completion: nil)
    }
}

// MARK: - PinLockSetupControllerDelegate
//
extension SPSettingsViewController: PinLockSetupControllerDelegate {
    func pinLockSetupController(_ controller: PinLockSetupController, didSelectPin pin: String) {
        SPTracker.trackSettingsPinlockEnabled(true)

        SPAppDelegate.shared().setPin(pin)

        dismissPresentedViewController()
    }

    func pinLockSetupControllerDidCancel(_ controller: PinLockSetupController) {
        SPAppDelegate.shared().allowBiometryInsteadOfPin = false
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
