import XCTest
@testable import Simplenote


/// StoresManager Unit Tests
///
class ResultsControllerUIKitTests: XCTestCase {

    /// Mockup StorageManager
    ///
    private var storageManager: MockupStorageManager!

    /// Mockup TableView
    ///
    private var tableView: MockupTableView!

    /// Sample ResultsController
    ///
    private var resultsController: ResultsController<Note>!


    // MARK: - Overridden Methods

    override func setUp() {
        storageManager = MockupStorageManager()
        tableView = MockupTableView()

        resultsController = {
            let viewContext = storageManager.persistentContainer.viewContext
            let sectionNameKeyPath = "content"
            let descriptor = NSSortDescriptor(keyPath: \Note.content, ascending: false)

            return ResultsController<Note>(viewContext: viewContext, sectionNameKeyPath: sectionNameKeyPath, sortedBy: [descriptor])
        }()

        resultsController.onDidChangeContent = { [weak self] (sectionsChangeset, objectsChangeset) in
            self?.tableView.performBatchChanges(sectionsChangeset: sectionsChangeset, objectsChangeset: objectsChangeset)
        }

        try? resultsController.performFetch()
    }

    /// Verifies that inserted entities result in `tableView.insertRows`
    ///
    func testAddingAnEntityResultsInNewRows() {
        let expectation = self.expectation(description: "Entity Insertion triggers Row Insertion")

        tableView.onInsertedRows = { rows in
            XCTAssertEqual(rows.count, 1)
            expectation.fulfill()
        }

        tableView.onReloadRows = { _ in
            XCTFail()
        }

        tableView.onDeletedRows = { _ in
            XCTFail()
        }

        storageManager.insertSampleNote()
        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }


    /// Verifies that deleted entities result in `tableView.deleteRows`.
    ///
    func testDeletingAnEntityResultsInDeletedRows() {
        let expectation = self.expectation(description: "Entity Deletion triggers Row Removal")

        let note = storageManager.insertSampleNote()
        try? storageManager.viewContext.save()

        tableView.onDeletedRows = { rows in
            XCTAssertEqual(rows.count, 1)
            expectation.fulfill()
        }

        tableView.onInsertedRows = { _ in
            XCTFail()
        }

        tableView.onReloadRows = { _ in
            XCTFail()
        }

        storageManager.viewContext.delete(note)
        try? storageManager.viewContext.save()

        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }

    /// Verifies that updated entities result in `tableView.reloadRows`.
    ///
    func testUpdatedEntityResultsInReloadedRows() {
        let expectation = self.expectation(description: "Entity Update triggers Row Reload")

        let note = storageManager.insertSampleNote()
        try? storageManager.viewContext.save()

        tableView.onDeletedRows = { _ in
            XCTFail()
        }

        tableView.onInsertedRows = { _ in
            XCTFail()
        }

        tableView.onReloadRows = { rows in
            XCTAssertEqual(rows.count, 1)
            expectation.fulfill()
        }

        note.shareURL = "www.automattic.com/rocks"
        try? storageManager.viewContext.save()
        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }

    /// Verifies that whenever entities are updated so that they match the "New Section Criteria", `tableView.insertSections` is
    /// effectively called.
    ///
    func testInsertSectionsIsExecutedWheneverEntitiesMatchNewSectionsCriteria() {
        let expectation = self.expectation(description: "SectionKeyPath Update Results in New Section")

        let first = storageManager.insertSampleNote()
        let _ = storageManager.insertSampleNote()
        try? storageManager.viewContext.save()

        tableView.onInsertedSections = { indexSet in
            expectation.fulfill()
        }

        tableView.onDeletedSections = { indexSet in
            XCTFail()
        }

        first.content = "Something Different Here!"
        try? storageManager.viewContext.save()
        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }

    /// Verifies that deleting the last Entity gets mapped to `tableView.deleteSections`.
    ///
    func testDeletingLastEntityResultsInDeletedSection() {
        let expectation = self.expectation(description: "Zero Entities results in Deleted Sections")

        let first = storageManager.insertSampleNote()
        try? storageManager.viewContext.save()

        tableView.onInsertedSections = { indexSet in
            XCTFail()
        }

        tableView.onDeletedSections = { indexSet in
            expectation.fulfill()
        }

        storageManager.viewContext.delete(first)
        try? storageManager.viewContext.save()
        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }
}
