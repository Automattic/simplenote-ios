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

    /// Closure to be executed before the results are changed.
    ///
    var onWillChangeContent: (() -> Void)?

    /// Closure to be executed after the results are changed.
    ///
    var onDidChangeContent: (() -> Void)?

    /// Closure to be executed whenever an Object is updated.
    ///
    var onDidChangeObject: ((_ change: ResultsObjectChange) -> Void)?

    /// Closure to be executed whenever an entire Section is updated.
    ///
    var onDidChangeSection: ((_ change: ResultsSectionChange) -> Void)?


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
            self?.onWillChangeContent?()
        }

        internalDelegate.onDidChangeContent = { [weak self] in
            self?.onDidChangeContent?()
        }

        internalDelegate.onDidChangeObject = { [weak self] (_, type, indexPath, newIndexPath) in
            let change: ResultsObjectChange

            // Seriously, Apple?
            // https://developer.apple.com/library/archive/releasenotes/iPhone/NSFetchedResultsChangeMoveReportedAsNSFetchedResultsChangeUpdate/index.html
            let fixedType: NSFetchedResultsChangeType = {
                guard type == .update && newIndexPath != nil && newIndexPath != indexPath else {
                    return type
                }
                return .move
            }()

            switch (fixedType, indexPath, newIndexPath) {
            case (.delete, .some(let indexPath), _):
                change = .delete(indexPath: indexPath)

            case (.insert, _, .some(let newIndexPath)):
                change = .insert(indexPath: newIndexPath)

            case (.move, .some(let oldIndexPath), .some(let newIndexPath)):
                change = .move(oldIndexPath: oldIndexPath, newIndexPath: newIndexPath)

            case (.update, .some(let indexPath), _):
                change = .update(indexPath: indexPath)

            default:
                NSLog("☠️ [ResultsController] Unrecognized Row Change!")
                return
            }

            self?.onDidChangeObject?(change)
        }

        internalDelegate.onDidChangeSection = { [weak self] (section, sectionIndex, type) in
            let change: ResultsSectionChange
            switch type {
            case .delete:
                change = .delete(sectionIndex: sectionIndex)
            case .insert:
                change = .insert(sectionIndex: sectionIndex)
            default:
                NSLog("☠️ [ResultsController] Unrecognized Section Change!")
                return
            }

            self?.onDidChangeSection?(change)
        }
    }
}
