import XCTest
@testable import Simplenote


// MARK: - NoteContentHelperTests Tests
//
class NoteContentHelperTests: XCTestCase {
    private let emptyRange = NSRange(location: NSNotFound, length: 0)

    /// Empty title and body when content is nil
    ///
    func testEmptyTitleAndBodyRangeWhenContentIsNil() {
        let content: String? = nil

        let structure = NoteContentHelper.structure(of: content)
        XCTAssertEqual(structure.title, emptyRange)
        XCTAssertEqual(structure.body, emptyRange)
    }

    /// Empty title and body when content is empty
    ///
    func testEmptyTitleAndBodyRangeWhenContentIsEmpty() {
        let content = ""

        let structure = NoteContentHelper.structure(of: content)
        XCTAssertEqual(structure.title, emptyRange)
        XCTAssertEqual(structure.body, emptyRange)
    }

    /// Test title and empty body when content has only one line
    ///
    func testTitleAndEmptyBodyRangeWhenContentHasOnlyOneLine() {
        let content = "A lala lala long long le long long long YEAH!"

        let structure = NoteContentHelper.structure(of: content)
        XCTAssertEqual(structure.title, NSRange(location: 0, length: content.nsString.length))
        XCTAssertEqual(structure.body, emptyRange)
    }

    /// Test title and body
    ///
    func testTitleAndBodyRange() {
        let content = "Title!\n\nBody"

        let structure = NoteContentHelper.structure(of: content)
        XCTAssertEqual(structure.title, content.nsString.range(of: "Title!"))
        XCTAssertEqual(structure.body, content.nsString.range(of: "Body"))
    }

    /// Test title doesn't include leading and trailing whitespaces and newlines
    ///
    func testTitleTrimsLeadingAndTrailingWhitespacesAndNewlines() {
        let content = "  \n\n  \n  Title! \n\n\n   \n "

        let structure = NoteContentHelper.structure(of: content)
        XCTAssertEqual(structure.title, content.nsString.range(of: "Title!"))
        XCTAssertEqual(structure.body, emptyRange)
    }

    /// Test body doesn't include leading and trailing whitespaces and newlines
    ///
    func testBodyTrimsLeadingAndTrailingWhitespacesAndNewlines() {
        let content = "\n\r\n# Title!\n\n\n\nLINE1\n\n\r\n\nLINE2\n\nLINE3\n\r\n\n"

        let structure = NoteContentHelper.structure(of: content)
        XCTAssertEqual(structure.title, content.nsString.range(of: "# Title!"))
        XCTAssertEqual(structure.body, content.nsString.range(of: "LINE1\n\n\r\n\nLINE2\n\nLINE3"))
    }
}
