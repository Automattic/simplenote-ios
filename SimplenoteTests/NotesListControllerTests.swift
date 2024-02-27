import XCTest
import SimplenoteFoundation
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

    // MARK: - Tests: Filters

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

    // MARK: - Tests: Sorting

    /// Verifies that the SortMode property properly applies the specified order mode to the retrieved entities
    ///
    func testListControllerProperlyAppliesSortModeToRetrievedNotes() {
        let (notes, _, _) = insertSampleEntities(count: 100)

        storage.save()
        XCTAssertEqual(noteListController.numberOfObjects, notes.count)

        noteListController.sortMode = .alphabeticallyDescending
        noteListController.performFetch()

        let reversedNotes = Array(notes.reversed())
        let retrievedNotes = noteListController.sections.first!.objects.compactMap { $0 as? Note }

        for (index, note) in retrievedNotes.enumerated() {
            XCTAssertEqual(note.content, reversedNotes[index].content)
        }
    }

    // MARK: - Tests: Sections

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

    // MARK: - Tests: Search

    /// Verifies that the Tag Entities are fetched when in search mode
    ///
    func testSearchModeYieldsTwoSectionsWithMatchingEntities() {
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

    /// Verifies that there are always *two* sections when in search mode, even when there are no objects
    ///
    func testSearchModeYieldsTwoSections() {
        noteListController.beginSearch()
        noteListController.refreshSearchResults(keyword: "Something")

        XCTAssertEqual(noteListController.numberOfObjects, 0)
        XCTAssertEqual(noteListController.sections.count, 2)
    }

    /// Verifies that the `endSearch` switches the NotesList back to a single section
    ///
    func testEndSearchSwitchesBackToSingleSectionMode() {
        let (notes, _, _) = insertSampleEntities(count: 100)
        storage.save()

        XCTAssertEqual(noteListController.numberOfObjects, notes.count)

        noteListController.beginSearch()
        noteListController.refreshSearchResults(keyword: "0")
        XCTAssertEqual(noteListController.numberOfObjects, notes.count + noteListController.limitForTagResults)

        noteListController.endSearch()
        XCTAssertEqual(noteListController.numberOfObjects, notes.count)
    }

    /// Verifies that the SearchMode disregards active Filters
    ///
    func testSearchModeYieldsGlobalResultsDisregardingActiveFilter() {
        let note = storage.insertSampleNote(contents: "Something Here")
        storage.save()

        noteListController.filter = .deleted
        noteListController.performFetch()

        XCTAssertEqual(noteListController.numberOfObjects, 0)

        noteListController.beginSearch()
        noteListController.refreshSearchResults(keyword: "Here")

        let retrievedNote = noteListController.object(at: IndexPath(row: 0, section: 1)) as! Note
        XCTAssertEqual(retrievedNote, note)
    }

    /// Verifies that the SearchMode yields a limited number of Tags
    ///
    func testSearchModeReturnsLimitedNumberOfTags() {
        insertSampleEntities(count: 100)
        storage.save()

        noteListController.beginSearch()
        noteListController.refreshSearchResults(keyword: "0")

        XCTAssert(noteListController.sections[0].numberOfObjects <= noteListController.limitForTagResults)
    }

    // MARK: - Tests: `object(at:)`

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
            let note = noteListController.object(at: IndexPath(row: index, section: 1)) as! Note
            XCTAssertEqual(note.content, payload)
        }

        // We're capping the number of Tags to 5!
        for (index, payload) in expected.enumerated() where index < noteListController.limitForTagResults {
            let tag = noteListController.object(at: IndexPath(row: index, section: 0)) as! Tag
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

    // MARK: - Tests: `indexPath(forObject:)`

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

        for (row, tag) in tags.enumerated() where row < noteListController.limitForTagResults {
            XCTAssertEqual(noteListController.indexPath(forObject: tag), IndexPath(row: row, section: 0))
        }

        for (row, note) in notes.enumerated() {
            XCTAssertEqual(noteListController.indexPath(forObject: note), IndexPath(row: row, section: 1))
        }
    }

    // MARK: - Tests: onBatchChanges

    /// Verifies that `onBatchChanges` is never called for **Tags** in the following scenarios:
    ///
    ///     - Mode: Results
    ///     - OP: Insert / Update / Delete
    ///
    func testOnBatchChangesDoesntRunForInsertUpdateNorDeleteOpsOverTagsWhenInResultsMode() {
        noteListController.onBatchChanges = { (_, _) in
            XCTFail()
        }

        let tag = storage.insertSampleTag()
        storage.save()

        tag.name = "Updated"
        storage.save()

        storage.delete(tag)
        storage.save()
    }

    /// Verifies that `onBatchChanges` runs for **Notes** in the following scenarios
    ///
    ///     - Mode: Results
    ///     - OP: Insert
    ///
    func testOnBatchChangesDoesRunForNoteInsertionsWhenInResultsMode() {
        expectBatchChanges(objectsChangeset: ResultsObjectsChangeset(inserted: [
            IndexPath(row: 0, section: 0)
        ]))

        storage.insertSampleNote()
        storage.save()

        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }

    /// Verifies that `onBatchChanges` runs for **Notes** in the following scenarios
    ///
    ///     - Mode: Results
    ///     - OP: Deletion
    ///
    func testOnBatchChangesDoesRunForNoteDeletionsWhenInResultsMode() {
        let note = storage.insertSampleNote()
        storage.save()

        expectBatchChanges(objectsChangeset: ResultsObjectsChangeset(deleted: [
            IndexPath(row: 0, section: 0)
        ]))

        storage.delete(note)
        storage.save()

        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }

    /// Verifies that `onBatchChanges` runs for **Notes** in the following scenarios
    ///
    ///     - Mode: Results
    ///     - OP: Update
    ///
    func testOnBatchChangesDoesRunForNoteUpdatesWhenInResultsMode() {
        let note = storage.insertSampleNote()
        storage.save()

        expectBatchChanges(objectsChangeset: ResultsObjectsChangeset(updated: [
            IndexPath(row: 0, section: 0)
        ]))

        note.content = "Updated"
        storage.save()

        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }

    /// Verifies that `onBatchChanges` runs for **Notes** in the following scenarios
    ///
    ///     - Mode: Results
    ///     - OP: Update
    ///
    func testOnBatchChangesDoesRunForNoteUpdateWhenInResultsModeAndRelaysMoveOperations() {
        let firstNote = storage.insertSampleNote(contents: "A")
        storage.insertSampleNote(contents: "B")
        storage.save()

        expectBatchChanges(objectsChangeset: ResultsObjectsChangeset(moved: [
            (from: IndexPath(row: 0, section: 0), to: IndexPath(row: 1, section: 0))
        ]))

        firstNote.content = "C"
        storage.save()

        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }

    /// Verifies that `onBatchChanges` runs for **Tag** in the following scenarios
    ///
    ///     - Mode: Search
    ///     - OP: Insert
    ///
    func testOnBatchChangesDoesRunForTagInsertionsWhenInSearchMode() {
        expectBatchChanges(objectsChangeset: ResultsObjectsChangeset(inserted: [
            IndexPath(row: 0, section: 0)
        ]))

        noteListController.beginSearch()
        noteListController.refreshSearchResults(keyword: "Test")
        storage.insertSampleTag(name: "Test")
        storage.save()

        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }

    /// Verifies that `onBatchChanges` runs for **Tag** in the following scenarios
    ///
    ///     - Mode: Search
    ///     - OP: Update
    ///
    func testOnBatchChangesDoesRunForTagUpdatesWhenInSearchMode() {
        let tag = storage.insertSampleTag(name: "Test")
        storage.save()

        expectBatchChanges(objectsChangeset: ResultsObjectsChangeset(updated: [
            IndexPath(row: 0, section: 0)
        ]))

        noteListController.beginSearch()
        noteListController.refreshSearchResults(keyword: "Test")
        tag.name = "Test Updated"
        storage.save()

        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }

    /// Verifies that `onBatchChanges` runs for **Tag** in the following scenarios
    ///
    ///     - Mode: Search
    ///     - OP: Delete
    ///
    func testOnBatchChangesDoesRunForTagDeletionWhenInSearchMode() {
        let tag = storage.insertSampleTag(name: "Test")
        storage.save()

        expectBatchChanges(objectsChangeset: ResultsObjectsChangeset(deleted: [
            IndexPath(row: 0, section: 0)
        ]))

        noteListController.beginSearch()
        noteListController.refreshSearchResults(keyword: "Test")
        storage.delete(tag)
        storage.save()

        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }

    /// Verifies that `onBatchChanges` runs for **Note** in the following scenarios
    ///
    ///     - Mode: Search
    ///     - OP: Insert
    ///
    func testOnBatchChangesDoesRunForNoteInsertionsWhenInSearchModeAndTheSectionIndexIsProperlyCorrected() {
        expectBatchChanges(objectsChangeset: ResultsObjectsChangeset(inserted: [
            IndexPath(row: 0, section: 1)
        ]))

        noteListController.beginSearch()
        noteListController.refreshSearchResults(keyword: "Test")
        storage.insertSampleNote(contents: "Test")
        storage.save()

        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }

    /// Verifies that `onBatchChanges` runs for **Note** in the following scenarios
    ///
    ///     - Mode: Search
    ///     - OP: Update
    ///
    func testOnBatchChangesDoesRunForNoteUpdatesWhenInSearchModeAndTheSectionIndexIsProperlyCorrected() {
        let note = storage.insertSampleNote(contents: "Test")
        storage.save()

        expectBatchChanges(objectsChangeset: ResultsObjectsChangeset(updated: [
            IndexPath(row: 0, section: 1)
        ]))

        noteListController.beginSearch()
        noteListController.refreshSearchResults(keyword: "Test")
        note.content = "Test Updated"
        storage.save()

        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }

    /// Verifies that `onBatchChanges` runs for **Note** in the following scenarios
    ///
    ///     - Mode: Search
    ///     - OP: Delete
    ///
    func testOnBatchChangesDoesRunForNoteDeletionWhenInSearchModeAndTheSectionIndexIsProperlyCorrected() {
        let note = storage.insertSampleNote(contents: "Test")
        storage.save()

        expectBatchChanges(objectsChangeset: ResultsObjectsChangeset(deleted: [
            IndexPath(row: 0, section: 1)
        ]))

        noteListController.beginSearch()
        noteListController.refreshSearchResults(keyword: "Test")
        storage.delete(note)
        storage.save()

        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }

    /// Verifies that `onBatchChanges` does not relay duplicated Changesets
    ///
    func testOnBatchChangesDoesNotRelayDuplicatedEvents() {
        storage.insertSampleNote(contents: "A")
        storage.save()

        expectBatchChanges(objectsChangeset: ResultsObjectsChangeset(inserted: [
            IndexPath(row: 1, section: 0)
        ]))

        storage.insertSampleNote(contents: "B")
        storage.save()

        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }

    /// Verifies that `onBatchChanges` relays move events
    ///
    func testOnBatchChangesRelaysMoveEvents() {
        storage.insertSampleNote(contents: "A")
        storage.insertSampleNote(contents: "B")
        let note = storage.insertSampleNote(contents: "C")

        storage.save()

        expectBatchChanges(objectsChangeset: ResultsObjectsChangeset(moved: [
            (from: IndexPath(row: 2, section: .zero), to: IndexPath(row: .zero, section: .zero))
        ]))

        note.pinned = true
        storage.save()

        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
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

    /// Expects the specified Object and Section changes to be relayed via `onBatchChanges`
    ///
    @discardableResult
    func expectBatchChanges(objectsChangeset: ResultsObjectsChangeset) -> XCTestExpectation {
        let expectation = self.expectation(description: "Waiting...")

        noteListController.onBatchChanges = { (receivedSectionChanges, receivedObjectChanges) in
            for (index, change) in objectsChangeset.deleted.enumerated() {
                XCTAssertEqual(change, objectsChangeset.deleted[index])
            }

            for (index, change) in objectsChangeset.inserted.enumerated() {
                XCTAssertEqual(change, objectsChangeset.inserted[index])
            }

            for (index, change) in objectsChangeset.moved.enumerated() {
                XCTAssertEqual(change.from, objectsChangeset.moved[index].from)
                XCTAssertEqual(change.to, objectsChangeset.moved[index].to)
            }

            for (index, change) in objectsChangeset.updated.enumerated() {
                XCTAssertEqual(change, objectsChangeset.updated[index])
            }

            XCTAssertEqual(objectsChangeset.deleted.count, receivedObjectChanges.deleted.count)
            XCTAssertEqual(objectsChangeset.inserted.count, receivedObjectChanges.inserted.count)
            XCTAssertEqual(objectsChangeset.moved.count, receivedObjectChanges.moved.count)
            XCTAssertEqual(objectsChangeset.updated.count, receivedObjectChanges.updated.count)
            expectation.fulfill()
        }

        return expectation
    }
}
