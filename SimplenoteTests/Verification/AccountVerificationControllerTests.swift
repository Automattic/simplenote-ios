import XCTest
import SimplenoteEndpoints
@testable import Simplenote

// MARK: - AccountVerificationControllerTests
//
class AccountVerificationControllerTests: XCTestCase {

    private let email = UUID().uuidString
    private lazy var remote = MockAccountVerificationRemote()
    private lazy var controller = AccountVerificationController(email: email, remote: remote)

    private lazy var invalidVerification: [String: Any] = [:]
    private lazy var unverifiedVerification: [String: Any] = ["token": #"{"username": "123"}"#]
    private lazy var inProgressVerification: [String: Any] = ["sent_to": "123"]
    private lazy var verifiedVerification: [String: Any] = ["token": "{\"username\": \"\(email)\"}"]
}

// MARK: - Verify
//
extension AccountVerificationControllerTests {
    func testVerifyCallsRemoteWithProvidedEmail() {
        // When
        let expectedResult = Remote.randomResult()
        var verificationResult: Result<Data?, RemoteError>?
        controller.verify { (result) in
            verificationResult = result
        }

        remote.processVerification(for: email, with: expectedResult)

        // Then
        XCTAssertEqual(verificationResult, expectedResult)
    }
}

// MARK: - State
//
extension AccountVerificationControllerTests {
    func testInitialStateIsUnknown() {
        XCTAssertEqual(controller.state, .unknown)
    }

    func testStateIsUnverifiedWhenUpdatingWithInvalidData() {
        controller.update(with: nil)
        XCTAssertEqual(controller.state, .unverified)

        controller.update(with: "verified")
        XCTAssertEqual(controller.state, .unverified)

        controller.update(with: invalidVerification)
        XCTAssertEqual(controller.state, .unverified)
    }

    func testStateIsUnverifiedIfTokenEmailDoesntMatchAccountEmail() {
        controller.update(with: unverifiedVerification)
        XCTAssertEqual(controller.state, .unverified)
    }

    func testStateIsInProgressIfStatusIsSent() {
        controller.update(with: inProgressVerification)
        XCTAssertEqual(controller.state, .verificationInProgress)
    }

    func testStateIsVerifiedIfTokenEmailMatchesAccountEmail() {
        controller.update(with: verifiedVerification)
        XCTAssertEqual(controller.state, .verified)
    }
}

// MARK: - OnStateChange
//
extension AccountVerificationControllerTests {
    func testOnStateChangeIsCalledWhenStateChanges() {
        // Given
        let expectedStateChangeHistory: [AccountVerificationController.State] = [
            .unknown, .unverified,
            .unverified, .verified
        ]
        var stateChangeHistory: [AccountVerificationController.State] = []
        controller.onStateChange = { (oldState, state) in
            stateChangeHistory.append(oldState)
            stateChangeHistory.append(state)
        }

        // When
        controller.update(with: unverifiedVerification)
        controller.update(with: verifiedVerification)

        // Then
        XCTAssertEqual(stateChangeHistory, expectedStateChangeHistory)
    }

    func testOnlyUniqueStateChangesAreReportedViaCallback() {
        // Given
        let expectedStateChangeHistory: [AccountVerificationController.State] = [
            .unknown, .unverified
        ]
        var stateChangeHistory: [AccountVerificationController.State] = []
        controller.onStateChange = { (oldState, state) in
            stateChangeHistory.append(oldState)
            stateChangeHistory.append(state)
        }

        // When
        controller.update(with: unverifiedVerification)
        controller.update(with: unverifiedVerification)

        // Then
        XCTAssertEqual(stateChangeHistory, expectedStateChangeHistory)
    }
}
