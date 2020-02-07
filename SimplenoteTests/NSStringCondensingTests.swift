import Foundation
import XCTest
@testable import Simplenote


// MARK: - NSString+Condensing Unit Tests
//
class NSStringCondensingTests: XCTestCase {

    /// Verifies that `generatePreviewStrings` yields an empty title and null body whenever the receiver is an empty string
    ///
    func testGeneratePreviewStringsYieldEmptyStringAndNullBodyWheneverTheReceiverIsEmpty() {
        let sample: NSString = ""

        let expectation = self.expectation(description: "generatePreviewStrings")
        sample.generatePreviewStrings { (title, body) in
            XCTAssertEqual(title, "")
            XCTAssertNil(body)
            expectation.fulfill()
        }

        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }

    /// Verifies that `generatePreviewStrings` yields a Null Body when the receiver contains no newline marker
    ///
    func testGeneratePreviewStringsYieldNullBodyWhenThereIsJustOneString() {
        let sample: NSString = "A lala lala long long le long long long YEAH!"

        let expectation = self.expectation(description: "generatePreviewStrings")
        sample.generatePreviewStrings { (title, body) in
            XCTAssertEqual(title as NSString, sample)
            XCTAssertNil(body)
            expectation.fulfill()
        }

        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }

    /// Verifies that `generatePreviewStrings` trims leading and trailing Newlines / Spaces
    ///
    func testGeneratePreviewStringsTrimsNewlinesAndSpacesAtLeadingAndTail() {
        let sample: NSString = " \n\r\n\r\n\nMwah ha ha\n\n\n\n   \n  \n"

        let expectation = self.expectation(description: "generatePreviewStrings")
        sample.generatePreviewStrings { (title, body) in
            XCTAssertEqual(title, "Mwah ha ha")
            XCTAssertNil(body)
            expectation.fulfill()
        }

        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }

    /// Verifies that `generatePreviewStrings` strips the title from Markdown Title Markers `#`
    ///
    func testGeneratePreviewStringsTrimsLeadingMarkdown() {
        let sample: NSString = "# Title"

        let expectation = self.expectation(description: "generatePreviewStrings")
        sample.generatePreviewStrings { (title, body) in
            XCTAssertEqual(title, "Title")
            XCTAssertNil(body)
            expectation.fulfill()
        }

        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }

    /// Verifies that `generatePreviewStrings` correctly splits the receiver in Title and Body
    ///
    func testGeneratePreviewStringsEffectivelySplitsTitleAndBody() {
        let sample: NSString = "\n\r\n# Title\n\n\n\nLINE1\n\n\r\n\nLINE2\n\nLINE3\n\r\n\n"

        let expectation = self.expectation(description: "generatePreviewStrings")
        sample.generatePreviewStrings { (title, body) in
            XCTAssertEqual(title, "Title")
            XCTAssertEqual(body, "LINE1 LINE2 LINE3")
            expectation.fulfill()
        }

        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }

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
