import Foundation
import XCTest
@testable import Simplenote

// MARK: - NSString+Condensing Unit Tests
//
class NSStringCondensingTests: XCTestCase {

    /// Verifies that `replacingNewlinesWithSpaces` returns an empty string, whenever the receiver is an empty string
    ///
    func testReplaceNewlinesWithSpacesDoesNotBreakWithEmptyStrings() {
        let sample: NSString = ""

        XCTAssertEqual(sample.replacingNewlinesWithSpaces(), "")
    }

    /// Verifies that `replacingNewlinesWithSpaces` returns an empty string, whenever the receiver is a string containing a single Newline
    ///
    func testReplaceNewlinesWithSpacesProperlyHandlesSingleNewlineString() {
        let sample: NSString = "\n"

        XCTAssertEqual(sample.replacingNewlinesWithSpaces(), "")
    }

    /// Verifies that `replacingNewlinesWithSpaces` returns an empty string, whenever the receiver is a string containing *Multiple* Newline(s)
    ///
    func testReplaceNewlinesWithSpacesProperlyHandlesMultipleNewlineString() {
        let sample: NSString = "\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r"

        XCTAssertEqual(sample.replacingNewlinesWithSpaces(), "")
    }

    /// Verifies that `replacingNewlinesWithSpaces` replaces consecutive newlines with a single space
    ///
    func testReplaceNewlinesWithSpacesTurnMultipleConsecutiveNewlinesIntoSingleSpace() {
        let sample: NSString = "WORD1\n\n\n\r\nWORD2\nWORD3\n\r\n\r\n\rWORD4"

        XCTAssertEqual(sample.replacingNewlinesWithSpaces(), "WORD1 WORD2 WORD3 WORD4")
    }

    /// Verifies that `replacingNewlinesWithSpaces` trims leading and trailing newlines
    ///
    func testReplaceNewlinesWithSpacesTrimsLeadingAndTrailingNewlines() {
        let sample: NSString = "\n\r\n\r\n\n\nWORD1\nWORD2\n\nWORD3\n\n\n\n"

        XCTAssertEqual(sample.replacingNewlinesWithSpaces(), "WORD1 WORD2 WORD3")
    }
}
