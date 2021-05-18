import Foundation

// MARK: - PinLockControllerConfiguration
//
struct PinLockControllerConfiguration: Equatable {
    /// PinLock screen title
    let title: String

    /// PinLock screen message
    ///
    let message: String?
}

// MARK: - PinLockController
//
protocol PinLockController: AnyObject {
    /// Observer for configuration changes. Provides updated configuration and optional animation
    ///
    var configurationObserver: ((PinLockControllerConfiguration, UIView.ReloadAnimation?) -> Void)? { get set }

    /// Is the flow cancellable? If cancellable VC should show `cancel` button to dismiss the flow
    ///
    var isCancellable: Bool { get }

    /// Handle pin entered in VC
    ///
    func handlePin(_ pin: String)

    /// Handle tap on `cancel` button in VC
    ///
    func handleCancellation()

    /// Handle view did appear event
    ///
    func viewDidAppear()

    /// Handle application become active
    ///
    func applicationDidBecomeActive()
}

/// Default impementation
///
extension PinLockController {
    func viewDidAppear() {}
    func applicationDidBecomeActive() {}
}
