import Foundation
import CoreData


// MARK: - Aliases
//
typealias ResultsSectionInfo = NSFetchedResultsSectionInfo


// MARK: - ResultsController
//
class ResultsController<T: NSManagedObject> {

    /// FetchedResultsController Delegate Wrapper.
    ///
    private let internalDelegate = FetchedResultsControllerDelegateWrapper()

    /// Results Controller
    ///
    private let resultsController: NSFetchedResultsController<T>

    /// Pending Changesets
    ///
    private var sectionsChangeset = ResultsSectionsChangeset()
    private var objectsChangeset = ResultsObjectsChangeset()

    /// ResultsController's Fetch Request
    ///
    private var fetchRequest: NSFetchRequest<T> {
        resultsController.fetchRequest
    }

    /// Limits the number of entries to retrieve
    ///
    var limit: Int? {
        get {
            fetchRequest.fetchLimit
        }
        set {
            fetchRequest.fetchLimit = newValue ?? .zero
        }
    }

    /// Filtering Predicate to be applied to the Results.
    ///
    var predicate: NSPredicate? {
        get {
            fetchRequest.predicate
        }
        set {
            fetchRequest.predicate = newValue
        }
    }

    /// Results's Sort Descriptor.
    ///
    var sortDescriptors: [NSSortDescriptor]? {
        get {
            fetchRequest.sortDescriptors
        }
        set {
            fetchRequest.sortDescriptors = newValue
        }
    }

    /// Closure to be executed after the results are changed.
    ///
    var onDidChangeContent: ((_ sections: ResultsSectionsChangeset, _ objects: ResultsObjectsChangeset) -> Void)?


    /// Designated Initializer
    ///
    ///  - viewContext: Main Thread's MOC
    ///  - sectionNameKeyPath: String containing the Section's Key Path
    ///  - predicate: Filtering NSPredicate
    ///  - sortDescriptors: Array of NSSortDescriptors which should be applied to the fetched results
    ///
    init(viewContext: NSManagedObjectContext,
         sectionNameKeyPath: String? = nil,
         matching predicate: NSPredicate? = nil,
         sortedBy sortDescriptors: [NSSortDescriptor],
         limit: Int = .zero) {

        assert(viewContext.concurrencyType == .mainQueueConcurrencyType)

        resultsController = {
            let request = NSFetchRequest<T>(entityName: T.entityName)
            request.predicate = predicate
            request.sortDescriptors = sortDescriptors
            request.fetchLimit = limit

            return NSFetchedResultsController<T>(fetchRequest: request,
                                                 managedObjectContext: viewContext,
                                                 sectionNameKeyPath: sectionNameKeyPath,
                                                 cacheName: nil)
        }()

        setupResultsController()
        setupDelegateWrapper()
    }
}


// MARK: - Public Methods
//
extension ResultsController {

    /// Executes the fetch request on the store to get objects.
    ///
    func performFetch() throws {
        resetPendingChangesets()
        try resultsController.performFetch()
    }

    /// Returns the Object at the specified IndexPath
    ///
    func object(at indexPath: IndexPath) -> T {
        resultsController.object(at: indexPath)
    }

    /// Returns the IndexPath for a given Object
    ///
    func indexPath(forObject object: T) -> IndexPath? {
        resultsController.indexPath(forObject: object)
    }

    /// Returns the number of fetched objects.
    ///
    var numberOfObjects: Int {
        resultsController.fetchedObjects?.count ?? 0
    }

    /// Returns an array of all of the Fetched Objects.
    ///
    var fetchedObjects: [T] {
        resultsController.fetchedObjects ?? []
    }

    /// Returns an array of SectionInfo Entitites.
    ///
    var sections: [ResultsSectionInfo] {
        resultsController.sections ?? []
    }
}


// MARK: - Private Methods
//
private extension ResultsController {

    /// Initializes the FetchedResultsController
    ///
    func setupResultsController() {
        resultsController.delegate = internalDelegate
    }

    /// Initializes FRC's Event Forwarding.
    ///
    func setupDelegateWrapper() {
        internalDelegate.onWillChangeContent = { [weak self] in
            self?.resetPendingChangesets()
        }

        internalDelegate.onDidChangeContent = { [weak self] in
            guard let `self` = self else {
                return
            }

            self.onDidChangeContent?(self.sectionsChangeset, self.objectsChangeset)
            self.resetPendingChangesets()
        }

        internalDelegate.onDidChangeObject = { [weak self] (_, type, indexPath, newIndexPath) in
            guard let `self` = self else {
                return
            }

            // Seriously, Apple?
            // https://developer.apple.com/library/archive/releasenotes/iPhone/NSFetchedResultsChangeMoveReportedAsNSFetchedResultsChangeUpdate/index.html
            // Update: Not needed on iOS +13. Drop when possible!
            //
            let fixedType: NSFetchedResultsChangeType = {
                guard type == .update && newIndexPath != nil && newIndexPath != indexPath else {
                    return type
                }
                return .move
            }()

            switch (fixedType, indexPath, newIndexPath) {
            case (.delete, .some(let indexPath), _):
                self.objectsChangeset.deletedIndexPath(indexPath)

            case (.insert, _, .some(let newIndexPath)):
                self.objectsChangeset.insertedIndexPath(newIndexPath)

            case (.move, .some(let oldIndexPath), .some(let newIndexPath)):
                self.objectsChangeset.movedIndexPath(from: oldIndexPath, to: newIndexPath)

            // WWDC 2020 @ Labs: Switch `indexPath` > `newIndexPath` for reload OP(s)
            case (.update, _, .some(let newIndexPath)):
                self.objectsChangeset.updatedIndexPath(newIndexPath)

            default:
                NSLog("☠️ [ResultsController] Unrecognized Row Change!")
            }
        }

        internalDelegate.onDidChangeSection = { [weak self] (section, sectionIndex, type) in
            switch type {
            case .delete:
                self?.sectionsChangeset.deletedSection(at: sectionIndex)

            case .insert:
                self?.sectionsChangeset.insertedSection(at: sectionIndex)

            default:
                NSLog("☠️ [ResultsController] Unrecognized Section Change!")
            }
        }
    }

    func resetPendingChangesets() {
        sectionsChangeset = ResultsSectionsChangeset()
        objectsChangeset = ResultsObjectsChangeset()
    }
}
