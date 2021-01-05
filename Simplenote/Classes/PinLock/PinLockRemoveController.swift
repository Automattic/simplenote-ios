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

    private let pin: String
    private weak var delegate: PinLockRemoveControllerDelegate?

    private var attempts: Int = 1

    init(pin: String, delegate: PinLockRemoveControllerDelegate) {
        self.pin = pin
        self.delegate = delegate

        super.init()
        configuration = PinLockControllerConfiguration(title: Localization.title, message: nil)
    }

    func handlePin(_ pin: String) {
        guard pin == self.pin else {
            let configuration = PinLockControllerConfiguration(title: Localization.title, message: Localization.failedAttempts(attempts))
            switchTo(configuration, with: .shake)
            attempts += 1
            return
        }

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

    private static let failedAttemptsSingle = NSLocalizedString("%i Failed Passcode Attempt", comment: "Number of failed entries entering in passcode")
    private static let failedAttemptsPlural = NSLocalizedString("%i Failed Passcode Attempts", comment: "Number of failed entries entering in passcode")

    static func failedAttempts(_ attempts: Int) -> String {
        let template = attempts > 1 ? failedAttemptsPlural : failedAttemptsSingle
        return String(format: template, attempts)
    }
}
