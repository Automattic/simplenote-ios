import XCTest
@testable import Simplenote


// MARK: - InterlinkResultsController Tests
//
class InterlinkResultsControllerTests: XCTestCase {

    /// InMemory Storage!
    ///
    private let storage = MockupStorageManager()

    /// InterlinkResultsController
    ///
    private var resultsController: InterlinkResultsController!


    // MARK: - Overridden Methods

    override func setUp() {
        super.setUp()
        resultsController = InterlinkResultsController(viewContext: storage.viewContext)
    }

    override func tearDown() {
        super.tearDown()
        storage.reset()
    }


    // MARK: - Tests: Filtering

    /// Verifies that only Notes with matching keywords in their title are returned by `searchNotes:byTitleKeyword:`
    ///
    func testSearchNotesByKeywordOnlyReturnsNotesThatContainTheSpecifiedKeywordInTheirTitle() {
        let (matching, _) = insertSampleEntities()

        guard let results = resultsController.searchNotes(byTitleKeyword: Settings.sampleMatchingKeyword, excluding: nil) else {
            XCTFail()
            return
        }

        XCTAssertEqual(matching, Set(results))
    }

    /// Verifies that `searchNotes:byTitleKeyword:` limits the output count to the value defined by `maximumNumberOfResults`
    ///
    func testSearchNotesByKeywordRespectsTheMaximumNumberOfResultsLimit() {
        let (_, _) = insertSampleEntities()

        resultsController.maximumNumberOfResults = 1
        guard let results = resultsController.searchNotes(byTitleKeyword: Settings.sampleMatchingKeyword, excluding: nil) else {
            XCTFail()
            return
        }

        XCTAssertEqual(results.count, resultsController.maximumNumberOfResults)
    }

    /// Verifies that `searchNotes:byTitleKeyword:` excludes the specified entity
    ///
    func testSearchNotesByKeywordExcludesTheSpecifiedObjectID() {
        let (matching, _) = insertSampleEntities()

        let excluded = matching.randomElement()!
        guard let results = resultsController.searchNotes(byTitleKeyword: Settings.sampleMatchingKeyword, excluding: excluded.objectID) else {
            XCTFail()
            return
        }

        XCTAssertFalse(results.contains(excluded))
        XCTAssertEqual(results.count, matching.count - 1)
    }
}


// MARK: - Private
//
private extension InterlinkResultsControllerTests {

    /// Inserts a collection of sample entities.
    ///
    func insertSampleEntities() -> (matching: Set<Note>, irrelevant: Set<Note>) {
        let notesWithKeyword = Set(arrayLiteral:
            storage.insertSampleNote(contents: Settings.sampleMatchingKeyword.uppercased() + "Match \n nope"),
            storage.insertSampleNote(contents: "Another " + Settings.sampleMatchingKeyword + " \n nope"),
            storage.insertSampleNote(contents: "Yet Another " + Settings.sampleMatchingKeyword + " \n nope")
        )

        let notesWithoutKeyword = Set(arrayLiteral:
            storage.insertSampleNote(contents: "nope"),
            storage.insertSampleNote(contents: "neither this one \n " + Settings.sampleMatchingKeyword)
        )

        storage.save()

        return (notesWithKeyword, notesWithoutKeyword)
    }
}


// MARK: - Constants
//
private enum Settings {
    static let sampleMatchingKeyword: String = "match"
}
