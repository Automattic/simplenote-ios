import XCTest
@testable import Simplenote

// MARK: - NSMutableAttributedString Styling Tests
//
class NSMutableAttributedStringStylingTests: XCTestCase {

    /// Verifies that `NSRegularExpression.regexForChecklists` will not match checklists that are in the middle of a string
    ///
    func testRegexForChecklistsWillNotMatchChecklistsLocatedAtTheMiddleOfTheString() {
        let string = "This is a badly formed todo - [ ] Buy avocados - []"
        let regex = NSRegularExpression.regexForChecklists
        let matches = regex.matches(in: string, options: [], range: string.fullRange)

        XCTAssertTrue(matches.isEmpty)
    }

    /// Verifies that `NSRegularExpression.regexForChecklistsEmbeddedAnywhere` matches multiple checklists in the same line
    ///
    func testRegexForChecklistsEmbeddedAnywhereWillMatchChecklistsLocatedAtTheMiddleOfTheString() {
        let string = "The second regex should consider this as a valid checklist - [ ] Buy avocados - []"
        let regex = NSRegularExpression.regexForChecklistsEmbeddedAnywhere
        let matches = regex.matches(in: string, options: [], range: string.fullRange)

        XCTAssertEqual(matches.count, 2)
    }

    /// Verifies that `NSRegularExpression.regexForChecklists` matches multiple spacing prefixes
    ///
    func testRegexForChecklistsProperlyMatchesMultipleWhitespacePrefixes() {
        let string = "           - [ ] Buy avocados - [ ]"
        let regex = NSRegularExpression.regexForChecklists
        let matches = regex.matches(in: string, options: [], range: string.fullRange)

        XCTAssertEqual(matches.count, 1)
    }

    /// Verifies that `NSRegularExpression.regexForChecklistsEmbeddedAnywhere` matches multiple spacing prefixes
    ///
    func testRegexForChecklistsEverywhereProperlyMatchesMultipleWhitespacePrefixes() {
        let string = "           - [ ] Buy avocados - [ ]"
        let regex = NSRegularExpression.regexForChecklistsEmbeddedAnywhere
        let matches = regex.matches(in: string, options: [], range: string.fullRange)

        XCTAssertEqual(matches.count, 2)
    }

    /// Verifies that `NSRegularExpression.regexForChecklists` only matches corretly formed strings
    ///
    func testRegexForChecklistsMatchProperlyFormattedChecklists() {
        let string = "ToDo\n\n- [ ] Buy avocados\n- [ ] Ship it\n- [x ] Malformed!\n- [x] Correct."
        let regex = NSRegularExpression.regexForChecklists
        let matches = regex.matches(in: string, options: [], range: string.fullRange)

        XCTAssertEqual(matches.count, 3)
    }

    /// Verifies that `NSRegularExpression.regexForChecklists` will not match malformed strings
    ///
    func testRegexForChecklistsWillNotMatchMalformedChecklists() {
        let string = "- [x ] Malformed!"
        let regex = NSRegularExpression.regexForChecklists
        let matches = regex.matches(in: string, options: [], range: string.fullRange)

        XCTAssertTrue(matches.isEmpty)
    }

    /// Verifies that `NSRegularExpression.regexForChecklistsEverywhere` will not match malformed strings
    ///
    func testRegexForChecklistsEverywhereWillNotMatchMalformedChecklists() {
        let string = "- [x ] Malformed!"
        let regex = NSRegularExpression.regexForChecklistsEmbeddedAnywhere
        let matches = regex.matches(in: string, options: [], range: string.fullRange)

        XCTAssertTrue(matches.isEmpty)
    }

    /// Verifies that `NSRegularExpression.regexForChecklists` will match checklists with no spaces between brackets
    ///
    func testRegexForChecklistsWillMatchChecklistsWithNoInternalSpaces() {
        let string = "- [] Item"
        let regex = NSRegularExpression.regexForChecklists
        let matches = regex.matches(in: string, options: [], range: string.fullRange)

        XCTAssertEqual(matches.count, 1)
    }

    /// Verifies that `NSRegularExpression.regexForChecklistsEmbeddedAnywhere` will match checklists with no spaces between brackets
    ///
    func testRegexForChecklistsEverywhereWillMatchChecklistsWithNoInternalSpaces() {
        let string = "- [] Item"
        let regex = NSRegularExpression.regexForChecklistsEmbeddedAnywhere
        let matches = regex.matches(in: string, options: [], range: string.fullRange)

        XCTAssertEqual(matches.count, 1)
    }

    /// Verifies that `NSRegularExpression.regexForChecklists` always produces the expected number of ranges
    ///
    func testRegexForChecklistsAlwaysProduceTwoRanges() {
        let samples = [
            (text: "           - [ ] Buy avocados - [ ]", expected: 1),
            (text: "ToDo\n\n- [ ] Buy avocados\n- [ ] Ship it\n- [x ] Malformed!\n- [x] Correct.", expected: 3),
            (text: "- [] Item", expected: 1)
        ]

        let regex = NSRegularExpression.regexForChecklists
        for (sample, expected) in samples {
            let matches = regex.matches(in: sample, options: [], range: sample.fullRange)
            XCTAssertEqual(matches.count, expected)

            for match in matches where match.numberOfRanges != NSRegularExpression.regexForChecklistsExpectedNumberOfRanges {
                XCTFail()
            }
        }
    }

    /// Verifies that `NSRegularExpression.regexForChecklistsEmbeddedAnywhere` always produces the expected number of ranges
    ///
    func testRegexForChecklistsEverywhereAlwaysProduceTwoRanges() {
        let samples = [
            (text: "           - [ ] Buy avocados - [ ]", expected: 2),
            (text: "ToDo\n\n- [ ] Buy avocados\n- [ ] Ship it\n- [x ] Malformed!\n- [x] Correct.", expected: 3),
            (text: "- [] Item", expected: 1),
            (text: "The second regex should consider this as a valid checklist - [ ] Buy avocados - []", expected: 2)
        ]

        let regex = NSRegularExpression.regexForChecklistsEmbeddedAnywhere
        for (sample, expected) in samples {
            let matches = regex.matches(in: sample, options: [], range: sample.fullRange)
            XCTAssertEqual(matches.count, expected)

            for match in matches where match.numberOfRanges != NSRegularExpression.regexForChecklistsExpectedNumberOfRanges {
                XCTFail()
            }
        }
    }
}
