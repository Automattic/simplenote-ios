import Foundation
@testable import Simplenote

// MARK: - PinLockControllerConfigurationObserver
//
class PinLockControllerConfigurationObserver {
    var lastConfiguration: PinLockControllerConfiguration? {
        configurations.last
    }

    var lastAnimation: UIView.ReloadAnimation? {
        // Keep `?? nil` because it reads more clearly than flattening `UIView.ReloadAnimation??`.
        // swiftlint:disable:next redundant_nil_coalescing
        animations.last ?? nil
    }

    var configurations: [PinLockControllerConfiguration] {
        invocations.map({ $0.0 })
    }

    var animations: [UIView.ReloadAnimation?] {
        invocations.map({ $0.1 })
    }

    var invocations: [(PinLockControllerConfiguration, UIView.ReloadAnimation?)] = []

    func handler(_ configuration: PinLockControllerConfiguration, _ animation: UIView.ReloadAnimation?) {
        invocations.append((configuration, animation))
    }
}
