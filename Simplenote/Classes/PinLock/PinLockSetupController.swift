import Foundation

class PinLockSetupController: PinLockController {
    private var configuration: PinLockControllerConfiguration = PinLockControllerConfiguration(title: Localization.createPasscode, message: nil)

    var isCancellable: Bool {
        return false
    }

    var configurationObserver: ((PinLockControllerConfiguration, PinLockControllerTransition) -> Void)? {
        didSet {
            configurationObserver?(configuration, .none)
        }
    }

    private var pin: String?

    func handlePin(_ pin: String) {
        guard let _ = self.pin else {
            self.pin = pin
            self.switchToPinConfirmation()
            return
        }

        self.pin = nil
        configuration = PinLockControllerConfiguration(title: Localization.createPasscode, message: nil)
        configurationObserver?(configuration, .slideRight)
    }

    private func switchToPinConfirmation() {
        configuration = PinLockControllerConfiguration(title: Localization.confirmPasscode, message: nil)
        configurationObserver?(configuration, .slideLeft)
    }
}

// MARK: - Localization
//
private enum Localization {
    static let createPasscode = NSLocalizedString("Choose a 4 digit passcode", comment: "Title on the PinLock screen asking to create a passcode")
    static let confirmPasscode = NSLocalizedString("Confirm your passcode", comment: "Title on the PinLock screen asking to confirm a passcode")

}

