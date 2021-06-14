import Foundation

// MARK: - PinLockSetupControllerDelegate
//
protocol PinLockSetupControllerDelegate: AnyObject {
    func pinLockSetupControllerDidComplete(_ controller: PinLockSetupController)
    func pinLockSetupControllerDidCancel(_ controller: PinLockSetupController)
}

// MARK: - PinLockSetupController
//
final class PinLockSetupController: PinLockBaseController, PinLockController {
    var isCancellable: Bool {
        return true
    }

    private var pin: String?
    private let pinLockManager: SPPinLockManager
    private weak var delegate: PinLockSetupControllerDelegate?

    init(pinLockManager: SPPinLockManager = .shared,
         delegate: PinLockSetupControllerDelegate) {
        self.pinLockManager = pinLockManager
        self.delegate = delegate

        super.init()
        configuration = PinLockControllerConfiguration(title: Localization.createPasscode, message: nil)
    }

    func handlePin(_ pin: String) {
        guard !pin.isEmpty else {
            self.pin = nil
            switchTo(PinLockControllerConfiguration(title: Localization.createPasscode, message: nil),
                     with: .shake)
            return
        }

        guard let firstPin = self.pin else {
            self.pin = pin
            switchToPinConfirmation()
            return
        }

        guard pin == firstPin else {
            self.pin = nil
            switchTo(PinLockControllerConfiguration(title: Localization.createPasscode, message: Localization.passcodesDontMatch),
                     with: .slideTrailing)
            return
        }

        pinLockManager.setPin(pin)
        delegate?.pinLockSetupControllerDidComplete(self)
    }

    func handleCancellation() {
        delegate?.pinLockSetupControllerDidCancel(self)
    }
}

// MARK: - Private
//
private extension PinLockSetupController {
    func switchToPinConfirmation() {
        let configuration = PinLockControllerConfiguration(title: Localization.confirmPasscode, message: nil)
        switchTo(configuration, with: .slideLeading)
    }
}

// MARK: - Localization
//
private enum Localization {
    static let createPasscode = NSLocalizedString("Choose a 4 digit passcode", comment: "Title on the PinLock screen asking to create a passcode")
    static let confirmPasscode = NSLocalizedString("Confirm your passcode", comment: "Title on the PinLock screen asking to confirm a passcode")
    static let passcodesDontMatch = NSLocalizedString("Passcodes did not match. Try again.", comment: "Pin Lock")
}
