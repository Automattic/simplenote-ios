import XCTest
@testable import Simplenote

// MARK: - PinLockVerifyControllerTests
//
class PinLockVerifyControllerTests: XCTestCase {
    private lazy var delegate = MockPinLockVerifyControllerDelegate()
    private lazy var pinLockManager = MockPinLockManager()
    private lazy var controller = PinLockVerifyController(pinLockManager: pinLockManager, delegate: delegate)

    private lazy var configurationObserver = PinLockControllerConfigurationObserver()

    func testProvidingInvalidPinShakesUI() {
        // Given
        controller.configurationObserver = configurationObserver.handler

        // When
        controller.handlePin(UUID().uuidString)

        // Then
        XCTAssertEqual(configurationObserver.animations, [nil, .shake])
    }

    func testProvidingInvalidPinDoesntCallDelegate() {
        // When
        controller.handlePin(UUID().uuidString)

        // Then
        XCTAssertEqual(delegate.numberOfTimesCompleteIsCalled, 0)
    }

    func testProvidingValidPinCallsDelegate() {
        // When
        controller.handlePin(pinLockManager.actualPin)

        // Then
        XCTAssertEqual(delegate.numberOfTimesCompleteIsCalled, 1)
    }

    func testCancelDoesntCallDelegate() {
        // When
        controller.handleCancellation()

        // Then
        XCTAssertEqual(delegate.numberOfTimesCompleteIsCalled, 0)
    }

    func testBiometryIsEvaluatedWhenApplicationBecomesActive() {
        // When
        controller.applicationDidBecomeActive()

        // Then
        XCTAssertEqual(pinLockManager.evaluateBiometryCompletions.count, 1)
    }

    func testBiometryIsEvaluatedWhenViewAppears() {
        // When
        controller.viewDidAppear()

        // Then
        XCTAssertEqual(pinLockManager.evaluateBiometryCompletions.count, 1)
    }

    func testEvaluationIsPresentedOnlyOnce() {
        // When
        controller.viewDidAppear()
        controller.viewDidAppear()

        // Then
        XCTAssertEqual(pinLockManager.evaluateBiometryCompletions.count, 1)
    }

    func testEvaluationIsNotPresentedAgainAfterItIsCancelled() throws {
        // When
        controller.viewDidAppear()
        try pinLockManager.evaluateBiometry(withSuccess: false)
        controller.viewDidAppear()

        // Then
        XCTAssertEqual(pinLockManager.evaluateBiometryCompletions.count, 0)
    }

    func testFailedBiometryEvaluationDoesntCallDelegate() throws {
        // When
        controller.viewDidAppear()
        try pinLockManager.evaluateBiometry(withSuccess: false)

        // Then
        XCTAssertEqual(delegate.numberOfTimesCompleteIsCalled, 0)
    }

    func testSuccessfulBiometryEvaluationCallsDelegate() throws {
        // When
        controller.viewDidAppear()
        try pinLockManager.evaluateBiometry(withSuccess: true)

        // Then
        XCTAssertEqual(delegate.numberOfTimesCompleteIsCalled, 1)
    }
}

// MARK: - MockPinLockVerifyControllerDelegate
//
private class MockPinLockVerifyControllerDelegate: PinLockVerifyControllerDelegate {
    var numberOfTimesCompleteIsCalled: Int = 0

    func pinLockVerifyControllerDidComplete(_ controller: PinLockVerifyController) {
        numberOfTimesCompleteIsCalled += 1
    }
}
