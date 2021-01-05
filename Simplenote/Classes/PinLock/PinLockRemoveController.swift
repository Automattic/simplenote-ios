import Foundation

// MARK: - PinLockRemoveControllerDelegate
//
protocol PinLockRemoveControllerDelegate: class {
    func pinLockRemoveControllerDidComplete(_ controller: PinLockRemoveController)
    func pinLockRemoveControllerDidCancel(_ controller: PinLockRemoveController)
}

// MARK: - PinLockRemoveController
//
final class PinLockRemoveController: PinLockBaseController, PinLockController {

    var isCancellable: Bool {
        return true
    }

    private var attempts: Int = 1
    private weak var delegate: PinLockRemoveControllerDelegate?

    init(delegate: PinLockRemoveControllerDelegate) {
        self.delegate = delegate

        super.init()
        configuration = PinLockControllerConfiguration(title: Localization.title, message: nil)
    }

    func handlePin(_ pin: String) {
        guard SPPinLockManager.validatePin(pin) else {
            switchToFailedAttempt(withTitle: Localization.title, attempts: attempts)
            attempts += 1
            return
        }

        SPPinLockManager.removePin()
        delegate?.pinLockRemoveControllerDidComplete(self)
    }

    func handleCancellation() {
        delegate?.pinLockRemoveControllerDidCancel(self)
    }
}

// MARK: - Localization
//
private enum Localization {
    static let title = NSLocalizedString("Turn off Passcode", comment: "Prompt when disabling passcode")
}
