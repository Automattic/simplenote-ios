import XCTest
@testable import Simplenote

// MARK: - String Truncation Tests
//
class NoteBodyExcerptTests: XCTestCase {

    /// InMemory Storage!
    ///
    private let storage = MockupStorageManager()

    private let noteBody = "Download the latest version of Simplenote and you’ll be able to insert links from one note into another note to easily organize and cross-reference\ninformation"

    private lazy var noteBodyWithoutNewlines = noteBody.replacingOccurrences(of: "\n", with: " ")

    private lazy var note = storage.insertSampleNote(contents: "Title \n \(noteBody)")

    private lazy var titleOnlyNote = storage.insertSampleNote(contents: "Title")

    override func setUp() {
        note.ensurePreviewStringsAreAvailable()
        titleOnlyNote.ensurePreviewStringsAreAvailable()
    }

    /// Verifies that nil is returned when keywords are nil
    ///
    func testProvidingNilKeywordsReturnsBodyPreview() {
        let expected = noteBodyWithoutNewlines
        let actual = note.bodyExcerpt(keywords: nil)
        XCTAssertEqual(actual, expected)
    }

    /// Verifies that nil is returned when keywords are empty
    ///
    func testProvidingEmptyKeywordsReturnsBodyPreview() {
        let expected = noteBodyWithoutNewlines
        let actual = note.bodyExcerpt(keywords: [])
        XCTAssertEqual(actual, expected)
    }

    /// Verifies that nil is returned when note has only title
    ///
    func testNoteWithOnlyTitleReturnsNil() {
        let actual = titleOnlyNote.bodyExcerpt(keywords: ["Title"])
        XCTAssertNil(actual)
    }

    /// Verifies that when keywords are not found, body preview is returned
    ///
    func testProvidingNonExistingKeywordsReturnsBodyPreview() {
        let expected = noteBodyWithoutNewlines
        let actual = note.bodyExcerpt(keywords: ["abcdef"])
        XCTAssertEqual(actual, expected)
    }

    /// Verifies that ellipsis is added if excerpt doesn't start at the beginning
    ///
    func testEllipsisIsAddedIfExcerptDoesntStartAtTheBeginning() {
        let expected = "…organize and cross-reference information"
        let actual = note.bodyExcerpt(keywords: ["information"])
        XCTAssertEqual(actual, expected)
    }

    /// Verifies that no ellipsis is added if excerpt starts at the beginning
    ///
    func testNoEllipsisIsAddedIfExcerptStartsAtTheBeginning() {
        let expected = noteBody.replacingOccurrences(of: "\n", with: " ")
        let actual = note.bodyExcerpt(keywords: ["version"])
        XCTAssertEqual(actual, expected)
    }

    /// Verifies that certain character sequence doesn't crash the app
    ///
    func testCertainCharacterSequenceDoesntCrash() {
        let body = "t\n\u{30bf}\nglo\u{0300}b"
        note = storage.insertSampleNote(contents: "Title\n\(body)")

        let expected = body.replacingOccurrences(of: "\n", with: " ")
        let actual = note.bodyExcerpt(keywords: ["t"])
        XCTAssertEqual(actual, expected)
    }
}
