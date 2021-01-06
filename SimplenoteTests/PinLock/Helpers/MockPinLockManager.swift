import XCTest
@testable import Simplenote

// MARK: - MockPinLockManager
//
class MockPinLockManager: SPPinLockManager {
    var actualPin: String = UUID().uuidString

    var setPinInvocations: [String] = []
    var numberOfTimesRemovePinIsCalled: Int = 0

    var evaluateBiometryCompletions: [(Bool) -> Void] = []

    override func setPin(_ pin: String) {
        setPinInvocations.append(pin)
    }

    override func validatePin(_ pin: String) -> Bool {
        return pin == actualPin
    }

    override func removePin() {
        numberOfTimesRemovePinIsCalled += 1
    }

    override func evaluateBiometry(completion: @escaping (Bool) -> Void) {
        evaluateBiometryCompletions.append(completion)
    }

    func evaluateBiometry(withSuccess success: Bool) throws {
        let completion = try XCTUnwrap(evaluateBiometryCompletions.popLast())
        completion(success)
    }
}
