import Foundation

// MARK: - PinLockVerifyControllerDelegate
//
protocol PinLockVerifyControllerDelegate: AnyObject {
    func pinLockVerifyControllerDidComplete(_ controller: PinLockVerifyController)
}

final class PinLockVerifyController: PinLockBaseController, PinLockController {

    var isCancellable: Bool {
        return false
    }

    private var attempts: Int = 1
    private var hasShownBiometryVerification: Bool = false
    private let pinLockManager: SPPinLockManager
    private let application: ApplicationStateProvider
    private weak var delegate: PinLockVerifyControllerDelegate?

    private var onSuccesBlocks = [(() -> Void)]()

    init(pinLockManager: SPPinLockManager = .shared,
         application: ApplicationStateProvider = UIApplication.shared,
         delegate: PinLockVerifyControllerDelegate) {
        self.pinLockManager = pinLockManager
        self.application = application
        self.delegate = delegate

        super.init()
        configuration = PinLockControllerConfiguration(title: Localization.title, message: nil)
    }

    func handlePin(_ pin: String) {
        guard pinLockManager.validatePin(pin) else {
            switchToFailedAttempt(withTitle: Localization.title, attempts: attempts)
            attempts += 1
            return
        }

        delegate?.pinLockVerifyControllerDidComplete(self)
        runOnSuccessBlocks()
    }

    func handleCancellation() {

    }

    func viewDidAppear() {
        verifyBiometry()
    }

    func applicationDidBecomeActive() {
        verifyBiometry()
    }

    private func runOnSuccessBlocks() {
        onSuccesBlocks.forEach({
            $0()
        })
        removeSuccesBlocks()
    }

    func addOnSuccesBlock(block: @escaping () -> Void) {
        onSuccesBlocks.append(block)
    }

    func removeSuccesBlocks() {
        onSuccesBlocks.removeAll()
    }
}

// MARK: - Biometry
//
private extension PinLockVerifyController {

    func verifyBiometry() {
        guard application.applicationState == .active,
              !hasShownBiometryVerification else {
            return
        }

        hasShownBiometryVerification = true

        pinLockManager.evaluateBiometry { [weak self] (success) in
            guard let self = self else {
                return
            }

            if success {
                self.delegate?.pinLockVerifyControllerDidComplete(self)
                self.runOnSuccessBlocks()
            }
        }
    }
}

// MARK: - Localization
//
private enum Localization {
    static let title = NSLocalizedString("Enter your passcode", comment: "Title on the PinLock screen asking to enter a passcode")
}
