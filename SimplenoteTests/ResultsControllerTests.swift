import XCTest
import CoreData
@testable import Simplenote


// MARK: - ResultsController Unit Tests
//
class ResultsControllerTests: XCTestCase {

    /// InMemory Storage!
    ///
    private let storage = MockupStorageManager()

    /// Returns the NSMOC associated to the Main Thread
    ///
    private var viewContext: NSManagedObjectContext {
        storage.persistentContainer.viewContext
    }

    /// Sample SectionNameKeyPath
    ///
    private let sampleSectionNameKeyPath = "content"

    /// Returns a sample NSSortDescriptor
    ///
    private var sampleSortDescriptor: NSSortDescriptor {
        NSSortDescriptor(key: #selector(getter: Note.content).description, ascending: true)
    }


    // MARK: - Overridden Methods

    override func setUp() {
        super.setUp()
        storage.reset()
    }


    /// Verifies that the Results Controller has an Empty Section right after the Fetch OP is performed.
    ///
    func testResultsControllerStartsEmptySectionAfterPerformingFetch() {
        let resultsController = ResultsController<Note>(viewContext: viewContext, sortedBy: [sampleSortDescriptor])
        XCTAssertEqual(resultsController.sections.count, 0)

        try? resultsController.performFetch()
        XCTAssertEqual(resultsController.sections.count, 1)
        XCTAssertEqual(resultsController.sections.first?.objects?.count, 0)
    }


    /// Verifies that ResultsController does pick up pre-existant entities, right after performFetch runs.
    ///
    func testResultsControllerPicksUpEntitiesAvailablePriorToInstantiation() {
        storage.insertSampleNote()
        try? viewContext.save()

        let resultsController = ResultsController<Note>(viewContext: viewContext, sortedBy: [sampleSortDescriptor])
        try? resultsController.performFetch()

        XCTAssertEqual(resultsController.sections.count, 1)
        XCTAssertEqual(resultsController.sections.first?.objects?.count, 1)
    }


    /// Verifies that ResultsController does pick up entities inserted after being instantiated.
    ///
    func testResultsControllerPicksUpEntitiesInsertedAfterInstantiation() {
        let resultsController = ResultsController<Note>(viewContext: viewContext, sortedBy: [sampleSortDescriptor])
        try? resultsController.performFetch()

        storage.insertSampleNote()
        try? viewContext.save()

        XCTAssertEqual(resultsController.sections.count, 1)
        XCTAssertEqual(resultsController.sections.first?.objects?.count, 1)
    }


    /// Verifies that `sectionNameKeyPath` effectively causes the ResultsController to produce multiple sections, based on the grouping parameter.
    ///
    func testResultsControllerGroupSectionsBySectionNameKeypath() {
        let resultsController = ResultsController<Note>(viewContext: viewContext,
                                                        sectionNameKeyPath: sampleSectionNameKeyPath,
                                                        sortedBy: [sampleSortDescriptor])
        try? resultsController.performFetch()

        let numberOfNotes = 100
        for index in 0 ..< numberOfNotes {
            let note = storage.insertSampleNote()
            note.content = index < 50 ? "first" : "second"
        }

        try? viewContext.save()

        XCTAssertEqual(resultsController.sections.count, 2)

        for section in resultsController.sections {
            XCTAssertEqual(section.numberOfObjects, 50)
        }
    }


    /// Verifies that `object(at indexPath:)` effectively returns the expected Entity.
    ///
    func testObjectAtIndexPathReturnsExpectedEntity() {
        let resultsController = ResultsController<Note>(viewContext: viewContext,
                                                        sectionNameKeyPath: sampleSectionNameKeyPath,
                                                        sortedBy: [sampleSortDescriptor])
        try? resultsController.performFetch()

        let insertedNote = storage.insertSampleNote()
        try? viewContext.save()

        let indexPath = IndexPath(row: 0, section: 0)
        let retrievedNote = resultsController.object(at: indexPath)

        XCTAssertEqual(insertedNote.simperiumKey, retrievedNote.simperiumKey)
        XCTAssertEqual(insertedNote.content, retrievedNote.content)
    }


    /// Verifies that `onDidChangeContent` is effectively called *after* the results are altered.
    ///
    func testOnDidChangeContentIsEffectivelyCalledAfterChangesArePerformed() {
        let resultsController = ResultsController<Note>(viewContext: viewContext, sortedBy: [sampleSortDescriptor])
        try? resultsController.performFetch()

        let expectation = self.expectation(description: "onDidChange")
        resultsController.onDidChangeContent = { (_, _) in
            expectation.fulfill()
        }

        storage.insertSampleNote()
        try? viewContext.save()

        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }


    /// Verifies that `onDidChangeContent` is called  with the inserted objects changesets
    ///
    func testOnDidChangeObjectIsEffectivelyCalledOnceNewObjectsAreInserted() {
        let resultsController = ResultsController<Note>(viewContext: viewContext, sortedBy: [sampleSortDescriptor])
        try? resultsController.performFetch()

        let expectation = self.expectation(description: "onDidChange")
        resultsController.onDidChangeContent = { (sectionsChangeset, objectsChangeset) in
            let expectedIndexPath = IndexPath(row: 0, section: 0)
            XCTAssertTrue(objectsChangeset.inserted.contains(expectedIndexPath))
            XCTAssertEqual(objectsChangeset.updated.count, .zero)
            XCTAssertEqual(objectsChangeset.deleted.count, .zero)
            XCTAssertEqual(objectsChangeset.moved.count, .zero)

            expectation.fulfill()
        }

        storage.insertSampleNote()
        try? viewContext.save()

        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }


    /// Verifies that `onDidChangeContent` is called whenever new sections are added.
    ///
    func testOnDidChangeSectionIsCalledWheneverNewSectionsAreAdded() {
        let resultsController = ResultsController<Note>(viewContext: viewContext,
                                                        sectionNameKeyPath: sampleSectionNameKeyPath,
                                                        sortedBy: [sampleSortDescriptor])
        try? resultsController.performFetch()

        let expectation = self.expectation(description: "onDidChange")
        resultsController.onDidChangeContent = { (sectionsChangeset, objectsChangeset) in
            XCTAssertEqual(sectionsChangeset.inserted.count, 1)
            XCTAssertEqual(sectionsChangeset.deleted.count, .zero)
            expectation.fulfill()
        }

        storage.insertSampleNote()
        try? viewContext.save()

        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }


    /// Verifies that `fetchedObjects` effectively  returns all of the objects that are expected to be available.
    ///
    func testFetchedObjectsEffectivelyReturnsAvailableEntities() {
        let resultsController = ResultsController<Note>(viewContext: viewContext, sortedBy: [sampleSortDescriptor])
        try? resultsController.performFetch()

        var expected = [String: Note]()

        for content in [ "first", "second", "third" ] {
            let note = storage.insertSampleNote()
            note.content = content
            expected[content] = note
        }

        try? viewContext.save()

        for retrieved in resultsController.fetchedObjects {
            XCTAssertEqual(retrieved, expected[retrieved.content])
        }
    }


    /// Verifies that `numberOfObjects` returns zero, when the collection is empty.
    ///
    func testEmptyStorageReturnsZeroNumberOfObjects() {
        let resultsController = ResultsController<Note>(viewContext: viewContext, sortedBy: [sampleSortDescriptor])
        try? resultsController.performFetch()

        XCTAssertEqual(resultsController.numberOfObjects, 0)
    }


    /// Verifies that the ResultsController.predicate is effectively applied to the internal FRC
    ///
    func testPredicatePropertyIsAppliedToInternalFRC() {
        storage.insertSampleNote()
        try? viewContext.save()

        let resultsController = ResultsController<Note>(viewContext: viewContext, sortedBy: [sampleSortDescriptor])
        try? resultsController.performFetch()

        XCTAssertEqual(resultsController.numberOfObjects, 1)

        resultsController.predicate = NSPredicate.predicateForNotes(deleted: true)
        try? resultsController.performFetch()
        XCTAssertEqual(resultsController.numberOfObjects, 0)
    }


    /// Verifies that the ResultsController.sortDescriptors is effectively applied to the internal FRC
    ///
    func testSortDescriptorsPropertyIsAppliedToInternalFRC() {
        let ascendingSampleContent = [ "1", "2", "3" ]
        for content in ascendingSampleContent {
            let note = storage.insertSampleNote()
            note.content = content
        }

        try? viewContext.save()

        let resultsController = ResultsController<Note>(viewContext: viewContext, sortedBy: [sampleSortDescriptor])
        try? resultsController.performFetch()

        XCTAssertEqual(resultsController.numberOfObjects, ascendingSampleContent.count)

        for (index, note) in resultsController.fetchedObjects.enumerated() {
            XCTAssertEqual(note.content, ascendingSampleContent[index])
        }

        let reversedSortDescriptor = NSSortDescriptor(key: #selector(getter: Note.content).description, ascending: false)

        resultsController.sortDescriptors = [ reversedSortDescriptor ]
        try? resultsController.performFetch()

        for (index, note) in resultsController.fetchedObjects.reversed().enumerated() {
            XCTAssertEqual(note.content, ascendingSampleContent[index])
        }
    }
}
