import Foundation

// MARK: - PinLockBaseController: base functionality for pin lock controller
//
class PinLockBaseController {
    /// Current configuration
    ///
    var configuration = PinLockControllerConfiguration(title: "", message: nil)

    /// Configuration observer
    ///
    var configurationObserver: ((PinLockControllerConfiguration, UIView.ReloadAnimation?) -> Void)? {
        didSet {
            configurationObserver?(configuration, nil)
        }
    }

    /// Switch to another configuration with animation
    ///
    func switchTo(_ configuration: PinLockControllerConfiguration, with animation: UIView.ReloadAnimation) {
        self.configuration = configuration
        configurationObserver?(configuration, animation)
    }

    /// Switch to failed attempt configuration
    ///
    func switchToFailedAttempt(withTitle title: String, attempts: Int) {
        let configuration = PinLockControllerConfiguration(title: title, message: Localization.failedAttempts(attempts))
        switchTo(configuration, with: .shake)
    }
}

// MARK: - Localization
//
private enum Localization {
    private static let failedAttemptsSingle = NSLocalizedString("%i Failed Passcode Attempt", comment: "Number of failed entries entering in passcode")
    private static let failedAttemptsPlural = NSLocalizedString("%i Failed Passcode Attempts", comment: "Number of failed entries entering in passcode")

    static func failedAttempts(_ attempts: Int) -> String {
        let template = attempts > 1 ? failedAttemptsPlural : failedAttemptsSingle
        return String(format: template, attempts)
    }
}
