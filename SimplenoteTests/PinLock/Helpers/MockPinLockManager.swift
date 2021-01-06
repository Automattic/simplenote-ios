import Foundation
@testable import Simplenote

// MARK: - MockPinLockManager
//
class MockPinLockManager: SPPinLockManager {
    var setPinInvocations: [String] = []

    override func setPin(_ pin: String) {
        setPinInvocations.append(pin)
    }
}
