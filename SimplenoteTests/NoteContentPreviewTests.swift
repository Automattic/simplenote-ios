import XCTest
@testable import Simplenote

// MARK: - NoteContentPreviewTests Tests
//
class NoteContentPreviewTests: XCTestCase {
    /// InMemory Storage!
    ///
    private let storage = MockupStorageManager()

    /// Verifies that Markdown Title Markers are stripped from the title
    ///
    func testTrimsLeadingMarkdown() {
        let sample = "# Title"
        let note = storage.insertSampleNote(contents: sample)
        note.createPreview()

        XCTAssertEqual(note.titlePreview, "Title")
    }

    /// Verifies that newlines and multiple spaces in body are replaced with a single space
    ///
    func testReplacesNewlinesWithSingleSpace() {
        let sample = "\n\r\n# Title\n\n\n\nLINE1\n\n\r\n\nLINE2\n\nLINE3\n\r\n\n"
        let note = storage.insertSampleNote(contents: sample)
        note.createPreview()

        XCTAssertEqual(note.titlePreview, "Title")
        XCTAssertEqual(note.bodyPreview, "LINE1 LINE2 LINE3")
    }
}
