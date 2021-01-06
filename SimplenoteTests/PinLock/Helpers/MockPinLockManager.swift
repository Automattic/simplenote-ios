import Foundation
@testable import Simplenote

// MARK: - MockPinLockManager
//
class MockPinLockManager: SPPinLockManager {
    var actualPin: String = UUID().uuidString

    var setPinInvocations: [String] = []
    var numberOfTimesRemovePinIsCalled: Int = 0

    override func setPin(_ pin: String) {
        setPinInvocations.append(pin)
    }

    override func validatePin(_ pin: String) -> Bool {
        return pin == actualPin
    }

    override func removePin() {
        numberOfTimesRemovePinIsCalled += 1
    }
}
