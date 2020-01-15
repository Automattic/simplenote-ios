import XCTest
@testable import Simplenote


// MARK: - NotesListControllerTests
//
class NotesListControllerTests: XCTestCase {

    /// InMemory Storage!
    ///
    private let storage = MockupStorageManager()

    /// List Controller
    ///
    private var noteListController: NotesListController!


    // MARK: - Overridden Methods

    override func setUp() {
        super.setUp()
        noteListController = NotesListController(viewContext: storage.viewContext)
    }

    override func tearDown() {
        super.tearDown()
        storage.reset()
    }


    /// Verifies that NoteListController completely ignores Tags Entities while in Results Mode
    ///
    func testListControllerIgnoresTagsEntitiesWhenInResultsMode() {
        var tags = [Tag]()
        var notes = [Note]()

        for _ in 0..<100 {
            tags.append( storage.insertSampleTag() )
            notes.append( storage.insertSampleNote() )
        }

        XCTAssertEqual(noteListController.numberOfObjects, 0)
        XCTAssertEqual(noteListController.sections.count, 1)
        XCTAssertEqual(noteListController.sections[0].numberOfObjects, 0)

        try? storage.viewContext.save()

        XCTAssertEqual(noteListController.numberOfObjects, notes.count)
        XCTAssertEqual(noteListController.sections.count, 1)
        XCTAssertEqual(noteListController.sections[0].numberOfObjects, notes.count)
    }

    /// Verifies that NoteListController returns matchin Tags when in search mode
    ///
    func testListControllerRetrievesTagEntitiesWhenInSearchMode() {
        let tag = storage.insertSampleTag()
        tag.name = "12345"

        let note0 = storage.insertSampleNote()
        note0.content = "12345"

        try? storage.viewContext.save()

        noteListController.beginSearch()
        noteListController.refreshSearchResults(keyword: "34")

        XCTAssertEqual(noteListController.numberOfObjects, 2)
        XCTAssertEqual(noteListController.sections.count, 2)
        XCTAssertEqual(noteListController.sections[0].numberOfObjects, 1)
        XCTAssertEqual(noteListController.sections[1].numberOfObjects, 1)
    }
}

