import XCTest
@testable import Simplenote

// MARK: - PinLockRemoveControllerTests
//
class PinLockRemoveControllerTests: XCTestCase {
    private lazy var delegate = MockPinLockRemoveControllerDelegate()
    private lazy var pinLockManager = MockPinLockManager()
    private lazy var controller = PinLockRemoveController(pinLockManager: pinLockManager, delegate: delegate)

    private lazy var configurationObserver = PinLockControllerConfigurationObserver()

    func testProvidingInvalidPinShakesUI() {
        // Given
        controller.configurationObserver = configurationObserver.handler

        // When
        controller.handlePin(UUID().uuidString)

        // Then
        XCTAssertEqual(configurationObserver.animations, [nil, .shake])
    }

    func testProvidingInvalidPinDoesntRemovePin() {
        // When
        controller.handlePin(UUID().uuidString)

        // Then
        delegate.assertNotCalled()
        XCTAssertEqual(pinLockManager.numberOfTimesRemovePinIsCalled, 0)
    }

    func testProvidingValidPinRemovesIt() {
        // When
        controller.handlePin(pinLockManager.actualPin)

        // Then
        XCTAssertEqual(delegate.numberOfTimesCompleteIsCalled, 1)
        XCTAssertEqual(delegate.numberOfTimesCancelIsCalled, 0)

        XCTAssertEqual(pinLockManager.numberOfTimesRemovePinIsCalled, 1)
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

// MARK: - MockPinLockRemoveControllerDelegate
//
private class MockPinLockRemoveControllerDelegate: PinLockRemoveControllerDelegate {
    var numberOfTimesCompleteIsCalled: Int = 0
    var numberOfTimesCancelIsCalled: Int = 0

    func pinLockRemoveControllerDidComplete(_ controller: PinLockRemoveController) {
        numberOfTimesCompleteIsCalled += 1
    }

    func pinLockRemoveControllerDidCancel(_ controller: PinLockRemoveController) {
        numberOfTimesCancelIsCalled += 1
    }

    func assertNotCalled() {
        XCTAssertEqual(numberOfTimesCompleteIsCalled, 0)
        XCTAssertEqual(numberOfTimesCancelIsCalled, 0)
    }
}
