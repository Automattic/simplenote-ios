import XCTest
@testable import Simplenote

// MARK: - PinLockSetupControllerTests
//
class PinLockSetupControllerTests: XCTestCase {
    private lazy var delegate = MockPinLockSetupControllerDelegate()
    private lazy var pinLockManager = MockPinLockManager()
    private lazy var controller = PinLockSetupController(pinLockManager: pinLockManager, delegate: delegate)

    private lazy var configurationObserver = PinLockControllerConfigurationObserver()

    func testProvidingEmptyMatchingPinsDontUpdatePin() {
        // Given
        controller.configurationObserver = configurationObserver.handler

        // When
        controller.handlePin("")
        controller.handlePin("")

        // Then
        delegate.assertNotCalled()
        XCTAssertEqual(configurationObserver.animations, [nil, .shake, .shake])
        XCTAssertEqual(pinLockManager.setPinInvocations, [])
    }

    func testNonMatchingPinsDontUpdatePin() {
        // Given
        controller.configurationObserver = configurationObserver.handler

        // When
        controller.handlePin(UUID().uuidString)
        controller.handlePin(UUID().uuidString)

        // Then
        delegate.assertNotCalled()
        XCTAssertEqual(configurationObserver.animations, [nil, .slideLeading, .slideTrailing])
        XCTAssertEqual(pinLockManager.setPinInvocations, [])
    }

    func testMatchingPinsUpdatePinAndCallDelegate() {
        // Given
        let pin = UUID().uuidString
        controller.configurationObserver = configurationObserver.handler

        // When
        controller.handlePin(pin)
        controller.handlePin(pin)

        // Then
        XCTAssertEqual(delegate.numberOfTimesCompleteIsCalled, 1)
        XCTAssertEqual(delegate.numberOfTimesCancelIsCalled, 0)

        XCTAssertEqual(configurationObserver.animations, [nil, .slideLeading])
        XCTAssertEqual(pinLockManager.setPinInvocations, [pin])
    }

    func testProvidingOnlyOnePinDoesntTriggerUpdate() {
        // Given
        let pin = UUID().uuidString
        controller.configurationObserver = configurationObserver.handler

        // When
        controller.handlePin(pin)

        // Then
        delegate.assertNotCalled()
        XCTAssertEqual(configurationObserver.animations, [nil, .slideLeading])
        XCTAssertEqual(pinLockManager.setPinInvocations, [])
    }

    func testCancelCallsDelegate() {
        // When
        controller.handleCancellation()

        // Then
        XCTAssertEqual(delegate.numberOfTimesCompleteIsCalled, 0)
        XCTAssertEqual(delegate.numberOfTimesCancelIsCalled, 1)

        XCTAssertEqual(pinLockManager.setPinInvocations, [])
    }
}

// MARK: - MockPinLockSetupControllerDelegate
//
private class MockPinLockSetupControllerDelegate: PinLockSetupControllerDelegate {
    var numberOfTimesCompleteIsCalled: Int = 0
    var numberOfTimesCancelIsCalled: Int = 0

    func pinLockSetupControllerDidComplete(_ controller: PinLockSetupController) {
        numberOfTimesCompleteIsCalled += 1
    }

    func pinLockSetupControllerDidCancel(_ controller: PinLockSetupController) {
        numberOfTimesCancelIsCalled += 1
    }

    func assertNotCalled() {
        XCTAssertEqual(numberOfTimesCompleteIsCalled, 0)
        XCTAssertEqual(numberOfTimesCancelIsCalled, 0)
    }
}
