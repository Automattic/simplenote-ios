import Foundation
@testable import Simplenote

// MARK: - PinLockControllerConfiguration
//
extension PinLockControllerConfiguration {
    static func random() -> PinLockControllerConfiguration {
        return PinLockControllerConfiguration(title: UUID().uuidString,
                                              message: UUID().uuidString)
    }
}
