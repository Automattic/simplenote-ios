import Foundation

struct PinLockControllerConfiguration {
    let title: String
    let message: String?
}

enum PinLockControllerTransition {
    case slideLeft
    case slideRight
    case shake
    case none
}

protocol PinLockController: class {
    var configurationObserver: ((PinLockControllerConfiguration, PinLockControllerTransition) -> Void)? { get set }

    var isCancellable: Bool { get }

    func handlePin(_ pin: String)
}
