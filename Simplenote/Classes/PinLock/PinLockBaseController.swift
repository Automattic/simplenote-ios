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
}
