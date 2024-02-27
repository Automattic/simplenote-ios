import XCTest
@testable import Simplenote

// MARK: - AuthenticationValidator Tests
//
class AuthenticationValidatorTests: XCTestCase {

    /// Testing Validator
    ///
    let validator = AuthenticationValidator()

    /// Verifies that `performUsernameValidation` returns `true` when the input string is valid
    ///
    func testPerformUsernameValidationReturnsTrueWheneverInputEmailIsValid() {
        let results = [
            validator.performUsernameValidation(username: "j@j.com"),
            validator.performUsernameValidation(username: "something@simplenote.blog"),
            validator.performUsernameValidation(username: "something@simplenote.blog"),
            validator.performUsernameValidation(username: "something@simplenote.blog.ar")
        ]

        for result in results {
            XCTAssertEqual(result, .success)
        }
    }

    /// Verifies that `performPasswordValidation` returns `passwordTooShort` whenever the password doesn't meet the length requirement.
    ///
    func testPerformPasswordValidationReturnsErrorWheneverInputStringIsShorterThanExpected() {
        guard case .passwordTooShort = validator.performPasswordValidation(username: "", password: "") else {
            XCTFail()
            return
        }

        // We can't really perform a straightforward comparison, because of the associated value!
    }

    /// Verifies that `performPasswordValidation` returns `passwordMatchesUsername` whenever the password matches the username.
    ///
    func testPerformPasswordValidationReturnsErrorWheneverPasswordMatchesUsername() {
        let result = validator.performPasswordValidation(username: "somethinghere", password: "somethinghere")
        XCTAssertEqual(result, .passwordMatchesUsername)
    }

    /// Verifies that `performPasswordValidation` returns `passwordContainsInvalidCharacter` whenever the password contains
    /// either Tabs or Newlines.
    ///
    func testPerformPasswordValidationReturnsErrorWheneverPasswordContainsInvalidCharacters() {
        let results = [
            validator.performPasswordValidation(username: "somethinghere", password: "\t12345678"),
            validator.performPasswordValidation(username: "somethinghere", password: "\n12345678"),
            validator.performPasswordValidation(username: "somethinghere", password: "1234\n5678\t"),
            validator.performPasswordValidation(username: "somethinghere", password: "12345678\t")
        ]

        for result in results {
            XCTAssertEqual(result, .passwordContainsInvalidCharacter)
        }
    }
}
