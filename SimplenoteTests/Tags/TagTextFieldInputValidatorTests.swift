import XCTest
@testable import Simplenote

// MARK: - TagTextFieldInputValidatorTests
//
class TagTextFieldInputValidatorTests: XCTestCase {
    let validator = TagTextFieldInputValidator()

    func testValidationSucceeds() {
        let text = ""
        let range = text.endIndex..<text.endIndex

        let expectedResult = TagTextFieldInputValidator.Result.valid
        let replacements = [
            "",
            "t",
            "tag",
            String(repeating: "a", count: 256)
        ]

        for replacement in replacements {
            XCTAssertEqual(validator.validateInput(originalText: text, range: range, replacement: replacement), expectedResult)
        }
    }

    func testValidationFailsWhenReplacementHasWhiteSpaceOrNewline() {
        let text = "tag"
        let range = text.endIndex..<text.endIndex

        let expectedResult = TagTextFieldInputValidator.Result.invalid
        let replacements = [
            " tag",
            "t ag",
            " tag ",
            "tag  ",
            "\ntag",
            "t\nag",
            "\ntag\n",
            "\ntag ",
        ]

        for replacement in replacements {
            XCTAssertEqual(validator.validateInput(originalText: text, range: range, replacement: replacement), expectedResult)
        }
    }
    
    func testValidationFailsWhenReplacementHasComma() {
        let text = "tag"
        let range = text.endIndex..<text.endIndex

        let expectedResult = TagTextFieldInputValidator.Result.invalid
        let replacements = [
            ",tag",
            "ta,g",
            ",tag,",
            "tag,,"
        ]

        for replacement in replacements {
            XCTAssertEqual(validator.validateInput(originalText: text, range: range, replacement: replacement), expectedResult)
        }
    }

    func testValidationFailsWhenReplacingTextInTheMiddleAndReplacementHasWhiteSpaceOrNewline() {
        let text = "tag"
        let midIndex = text.index(text.startIndex, offsetBy: 1)
        let range = midIndex..<midIndex

        let expectedResult = TagTextFieldInputValidator.Result.invalid
        let replacements = [
            " tag",
            "t ag",
            " tag ",
            "tag  ",
            "tag ",
            "tag\n",
            "\ntag",
            "t\nag",
            "\ntag\n",
            "\ntag ",
        ]

        for replacement in replacements {
            XCTAssertEqual(validator.validateInput(originalText: text, range: range, replacement: replacement), expectedResult)
        }
    }

    func testReplacingTextWithWhitespaceAtTheEnd() {
        let text = "tag"
        let range = text.endIndex..<text.endIndex

        let expectedResult = TagTextFieldInputValidator.Result.endingWithDisallowedCharacter("tagtag")
        let replacements = [
            "tag ",
            "tag\n",
        ]

        for replacement in replacements {
            XCTAssertEqual(validator.validateInput(originalText: text, range: range, replacement: replacement), expectedResult)
        }
    }
    
    func testReplacingTextWithCommaAtTheEnd() {
        let text = "tag"
        let range = text.endIndex..<text.endIndex
        
        let expectedResult = TagTextFieldInputValidator.Result.endingWithDisallowedCharacter("tagtag")
        let replacement = "tag,"
        
        XCTAssertEqual(validator.validateInput(originalText: text, range: range, replacement: replacement), expectedResult)
    }

    func testValidationFailsWhenTagExceedsLengthLimit() {
        let text = "t"
        let range = text.endIndex..<text.endIndex
        let replacement = String(repeating: "a", count: 256)
        let expectedResult = TagTextFieldInputValidator.Result.invalid

        XCTAssertEqual(validator.validateInput(originalText: text, range: range, replacement: replacement), expectedResult)
    }


    func testPreprocessingForPastingTrimsWhitespacesAndNewlinesAndReturnsFirstPart() {
        let cases = [
            "tag": "tag",
            " tag ": "tag",
            "\nt \n ag": "t"
        ]

        for (tag, expected) in cases {
            XCTAssertEqual(validator.preprocessForPasting(tag: tag), expected)
        }
    }
}
