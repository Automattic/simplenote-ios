import Foundation
import CoreData


// MARK: - Aliases
//
typealias ResultsChangeType = NSFetchedResultsChangeType
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
    var onDidChangeObject: ((_ object: Any, _ indexPath: IndexPath?, _ type: ResultsChangeType, _ newIndexPath: IndexPath?) -> Void)?

    /// Closure to be executed whenever an entire Section is updated.
    ///
    var onDidChangeSection: ((_ sectionInfo: ResultsSectionInfo, _ sectionIndex: Int, _ type: ResultsChangeType) -> Void)?


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
         sortedBy sortDescriptors: [NSSortDescriptor]) {

        assert(viewContext.concurrencyType == .mainQueueConcurrencyType)

        resultsController = {
            let request = NSFetchRequest<T>(entityName: T.entityName)
            request.predicate = predicate
            request.sortDescriptors = sortDescriptors

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

        internalDelegate.onDidChangeObject = { [weak self] (object, indexPath, type, newIndexPath) in
            self?.onDidChangeObject?(object, indexPath, type, newIndexPath)
        }

        internalDelegate.onDidChangeSection = { [weak self] (section, sectionIndex, type) in
            self?.onDidChangeSection?(section, sectionIndex, type)
        }
    }
}
