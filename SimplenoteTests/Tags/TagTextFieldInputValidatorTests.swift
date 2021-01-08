import XCTest
@testable import Simplenote

// MARK: - TagTextFieldInputValidatorTests
//
class TagTextFieldInputValidatorTests: XCTestCase {
    let validator = TagTextFieldInputValidator()

    func testValidationFailsWhenTagHasWhiteSpaceOrNewline() {
        let expectedResult = TagTextFieldInputValidator.Result.invalid
        let tags = [
            " tag",
            "t ag",
            " tag ",
            "tag  ",
            "\ntag",
            "t\nag",
            "\ntag\n",
            "\ntag ",
        ]

        for tag in tags {
            XCTAssertEqual(validator.validate(tag: tag), expectedResult)
        }
    }

    func testSpecialCaseWhenTagOnlyHasWhitespaceAtTheEnd() {
        let expectedResult = TagTextFieldInputValidator.Result.endingWithWhitespace("tag")

        let tags = [
            "tag ",
            "tag\n",
        ]

        for tag in tags {
            XCTAssertEqual(validator.validate(tag: tag), expectedResult)
        }
    }

    func testValidationFailsWhenTagExceedsLengthLimit() {
        let tag = String(repeating: "a", count: 257)
        let expectedResult = TagTextFieldInputValidator.Result.invalid

        XCTAssertEqual(validator.validate(tag: tag), expectedResult)
    }

    func testValidationSucceeds() {
        let expectedResult = TagTextFieldInputValidator.Result.valid
        let tags = [
            "",
            "t",
            "tag",
            String(repeating: "a", count: 256)
        ]

        for tag in tags {
            XCTAssertEqual(validator.validate(tag: tag), expectedResult)
        }
    }

    func testSanitizationReplacesWhitespacesAndNewlines() {
        let cases = [
            "tag": "tag",
            " tag ": "tag",
            "\nt \n ag": "t-ag"
        ]

        for (tag, expected) in cases {
            XCTAssertEqual(validator.sanitize(tag: tag), expected)
        }
    }
}
