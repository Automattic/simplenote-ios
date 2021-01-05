import UIKit

// MARK: - Pin
//
extension SPSettingsViewController {

    /// Show pin setup or pin remove view controller
    @objc
    func showPinLockViewController() {
        let controller: PinLockController
        if let pin = SPPinLockManager.pin {
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

        SPPinLockManager.pin = pin

        dismissPresentedViewController()
    }

    func pinLockSetupControllerDidCancel(_ controller: PinLockSetupController) {
        SPPinLockManager.shouldUseBiometry = false
        dismissPresentedViewController()
    }
}

// MARK: - PinLockRemoveControllerDelegate
//
extension SPSettingsViewController: PinLockRemoveControllerDelegate {
    func pinLockRemoveControllerDidComplete(_ controller: PinLockRemoveController) {
        SPTracker.trackSettingsPinlockEnabled(false)

        SPPinLockManager.removePin()

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
        SPPinLockManager.supportedBiometry != nil
    }

    @objc
    var biometryTitle: String? {
        SPPinLockManager.supportedBiometry?.title
    }
}

// MARK: - SPPinLockManager.Biometry
//
private extension SPPinLockManager.Biometry {
    var title: String {
        switch self {
        case .touchID:
            return NSLocalizedString("Touch ID", comment: "Offer to enable Touch ID support if available and passcode is on.")
        case .faceID:
            return NSLocalizedString("Face ID", comment: "Offer to enable Face ID support if available and passcode is on.")
        }
    }
}
