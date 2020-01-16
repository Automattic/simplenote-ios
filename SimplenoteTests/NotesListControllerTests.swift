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
        noteListController.performFetch()
    }

    override func tearDown() {
        super.tearDown()
        storage.reset()
    }

    /// Verifies that the Filter property properly filters out non matching entities
    ///
    func testListControllerProperlyAppliesFiltersToNotesWhenInResultsMode() {
        let note = storage.insertSampleNote()

        storage.save()
        XCTAssertEqual(noteListController.numberOfObjects, 1)

        note.deleted = true
        storage.save()
        XCTAssertEqual(noteListController.numberOfObjects, 0)

        noteListController.filter = .deleted
        XCTAssertEqual(noteListController.numberOfObjects, 0)

        noteListController.performFetch()
        XCTAssertEqual(noteListController.numberOfObjects, 1)
    }

    /// Verifies that the SortMode property properly applies the specified order mode to the retrieved entities
    ///
    func testListControllerProperlyAppliesSortModeToRetrievedNotes() {
        let (notes, _, _) = insertSampleEntities(count: 100)

        storage.save()
        XCTAssertEqual(noteListController.numberOfObjects, notes.count)

        noteListController.sortMode = .alphabeticallyDescending
        noteListController.performFetch()

        let reversedNotes = Array(notes.reversed())
        let retrievedNotes = noteListController.sections.first!.objects!.compactMap { $0 as? Note }

        for (index, note) in retrievedNotes.enumerated() {
            XCTAssertEqual(note.content, reversedNotes[index].content)
        }
    }

    /// Verifies that the Tag Entities aren't fetched when in Results Mode
    ///
    func testListControllerIgnoresTagsEntitiesWhenInResultsMode() {
        let (notes, _, _) = insertSampleEntities(count: 100)

        XCTAssertEqual(noteListController.numberOfObjects, 0)
        XCTAssertEqual(noteListController.sections.count, 1)
        XCTAssertEqual(noteListController.sections[0].numberOfObjects, 0)

        storage.save()

        XCTAssertEqual(noteListController.numberOfObjects, notes.count)
        XCTAssertEqual(noteListController.sections.count, 1)
        XCTAssertEqual(noteListController.sections[0].numberOfObjects, notes.count)
    }

    /// Verifies that the Tag Entities are fetched when in search mode
    ///
    func testListControllerRetrievesTagEntitiesWhenInSearchMode() {
        storage.insertSampleTag(name: "12345")
        storage.insertSampleNote(contents: "12345")

        storage.save()

        noteListController.beginSearch()
        noteListController.refreshSearchResults(keyword: "34")

        XCTAssertEqual(noteListController.numberOfObjects, 2)
        XCTAssertEqual(noteListController.sections.count, 2)
        XCTAssertEqual(noteListController.sections[0].numberOfObjects, 1)
        XCTAssertEqual(noteListController.sections[1].numberOfObjects, 1)
    }

    /// Verifies that the `endSearch` switches the NotesList back to a single section
    ///
    func testEndSearchSwitchesBackToSingleSectionMode() {
        let (notes, tags, _) = insertSampleEntities(count: 100)
        storage.save()

        XCTAssertEqual(noteListController.numberOfObjects, notes.count)

        noteListController.beginSearch()
        noteListController.refreshSearchResults(keyword: "0")
        XCTAssertEqual(noteListController.numberOfObjects, notes.count + tags.count)

        noteListController.endSearch()
        XCTAssertEqual(noteListController.numberOfObjects, notes.count)

    }

    /// Verifies that `object(at: IndexPath)` returns the proper Note when in results mode
    ///
    func testObjectAtIndexPathReturnsTheProperEntityWhenInResultsMode() {
        let (_, _, expected) = insertSampleEntities(count: 100)

        storage.save()

        for (index, payload) in expected.enumerated() {
            let note = noteListController.object(at: IndexPath(row: index, section: 0)) as! Note
            XCTAssertEqual(note.content, payload)
        }
    }

    /// Verifies that `object(at: IndexPath)` returns the proper Note when in Search Mode (without Keywords)
    ///
    func testObjectAtIndexPathReturnsTheProperEntityWhenInSearchModeWithoutKeywords() {
        let (_, _, expected) = insertSampleEntities(count: 100)

        storage.save()
        noteListController.beginSearch()

        // This is a specific keyword contained by eeeevery siiiiinnnnngle entity!
        noteListController.refreshSearchResults(keyword: "0")

        for (index, payload) in expected.enumerated() {
            let tag = noteListController.object(at: IndexPath(row: index, section: 0)) as! Tag
            let note = noteListController.object(at: IndexPath(row: index, section: 1)) as! Note
            XCTAssertEqual(note.content, payload)
            XCTAssertEqual(tag.name, payload)
        }
    }

    /// Verifies that `object(at: IndexPath)` returns the proper Note when in Search Mode (with Keywords)
    ///
    func testObjectAtIndexPathReturnsTheProperEntityWhenInSearchModeWithSomeKeyword() {
        insertSampleEntities(count: 100)
        storage.save()

        noteListController.beginSearch()
        noteListController.refreshSearchResults(keyword: "055")
        XCTAssertEqual(noteListController.numberOfObjects, 2)

        let tag = noteListController.object(at: IndexPath(row: 0, section: 0)) as! Tag
        let note = noteListController.object(at: IndexPath(row: 0, section: 1)) as! Note

        XCTAssertEqual(tag.name, "055")
        XCTAssertEqual(note.content, "055")
    }

    /// Verifies that `indexPath(forObject:)` returns the proper Note when in Results Mode
    ///
    func testIndexPathForObjectReturnsTheProperPathWhenInResultsMode() {
        let (notes, _, _) = insertSampleEntities(count: 100)
        storage.save()

        for (row, note) in notes.enumerated() {
            let expected = IndexPath(row: row, section: 0)
            XCTAssertEqual(noteListController.indexPath(forObject: note), expected)
        }
    }

    /// Verifies that `indexPath(forObject:)` returns the proper Note/Tag when in Search Mode
    ///
    func testIndexPathForObjectReturnsTheProperPathWhenInSearchMode() {
        let (notes, tags, _) = insertSampleEntities(count: 100)

        storage.save()
        noteListController.beginSearch()

        // This is a specific keyword contained by eeeevery siiiiinnnnngle entity!
        noteListController.refreshSearchResults(keyword: "0")

        for (row, tag) in tags.enumerated() {
            XCTAssertEqual(noteListController.indexPath(forObject: tag), IndexPath(row: row, section: 0))
        }

        for (row, note) in notes.enumerated() {
            XCTAssertEqual(noteListController.indexPath(forObject: note), IndexPath(row: row, section: 1))
        }
    }
}


// MARK: - Private APIs
//
private extension NotesListControllerTests {

    /// Inserts `N` entities  with ascending payloads (Name / Contents)
    ///
    @discardableResult
    func insertSampleEntities(count: Int) -> ([Note], [Tag], [String]) {
        var notes = [Note]()
        var tags = [Tag]()
        var expected = [String]()

        for index in 0..<100 {
            let payload = String(format: "%03d", index)

            tags.append( storage.insertSampleTag(name: payload) )
            notes.append( storage.insertSampleNote(contents: payload) )
            expected.append( payload )
        }

        return (notes, tags, expected)
    }
}
