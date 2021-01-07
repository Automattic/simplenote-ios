import UIKit

// MARK: - Pin
//
extension SPSettingsViewController {

    /// Show pin setup or pin remove view controller
    @objc
    func showPinLockViewController() {
        let controller: PinLockController
        if let pin = SPAppDelegate.shared().getPin() {
            controller = PinLockRemoveController(pin: pin, delegate: self)
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

// MARK: - PinLockRemoveControllerDelegate
//
extension SPSettingsViewController: PinLockRemoveControllerDelegate {
    func pinLockRemoveControllerDidComplete(_ controller: PinLockRemoveController) {
        SPTracker.trackSettingsPinlockEnabled(false)

        SPAppDelegate.shared().removePin()
        SPAppDelegate.shared().allowBiometryInsteadOfPin = false

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
