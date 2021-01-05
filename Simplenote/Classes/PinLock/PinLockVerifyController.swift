import Foundation

// MARK: - PinLockVerifyControllerDelegate
//
protocol PinLockVerifyControllerDelegate: class {
    func pinLockVerifyControllerDidComplete(_ controller: PinLockVerifyController)
}

final class PinLockVerifyController: PinLockBaseController, PinLockController {

    var isCancellable: Bool {
        return false
    }

    private var attempts: Int = 1
    private weak var delegate: PinLockVerifyControllerDelegate?

    init(delegate: PinLockVerifyControllerDelegate) {
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

        delegate?.pinLockVerifyControllerDidComplete(self)
    }

    func handleCancellation() {
        
    }
}

// MARK: - Localization
//
private enum Localization {
    static let title = NSLocalizedString("Enter your passcode", comment: "Title on the PinLock screen asking to enter a passcode")
}
