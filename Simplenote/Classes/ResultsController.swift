import Foundation
import CoreData


// MARK: - ResultsController
//
@objcMembers
class ResultsController: NSObject {

    /// Batch Size for the FRC's Request
    ///
    private let resultsBatchSize = 20

    /// FetchedResultsController Delegate Wrapper.
    ///
    private let internalDelegate = FetchedResultsControllerDelegateWrapper()

    /// Fetch Request
    ///
    private lazy var request: NSFetchRequest<Note> = {
        let request = NSFetchRequest<Note>()
        request.entity = NSEntityDescription.entity(forEntityName: Note.classNameWithoutNamespaces, in: viewContext)
        request.fetchBatchSize = resultsBatchSize
        request.sortDescriptors = sortDescriptors(sortMode: sortMode)
        return request
    }()

    /// Results Controller
    ///
    private lazy var resultsController: NSFetchedResultsController<Note> = {
        NSFetchedResultsController<Note>(fetchRequest: request, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
    }()

    /// View Context MOC: Main Thread!
    ///
    let viewContext: NSManagedObjectContext

    /// Closure to be executed before the results are changed.
    ///
    var onWillChangeContent: (() -> Void)?

    /// Closure to be executed after the results are changed.
    ///
    var onDidChangeContent: (() -> Void)?

    /// Closure to be executed whenever an Object is updated.
    ///
    var onDidChangeObject: ((_ object: Any, _ indexPath: IndexPath?, _ type: ChangeType, _ newIndexPath: IndexPath?) -> Void)?

    /// Closure to be executed whenever an entire Section is updated.
    ///
    var onDidChangeSection: ((_ sectionInfo: SectionInfo, _ sectionIndex: Int, _ type: ChangeType) -> Void)?

    /// Active Filter
    ///
    var filter: Filter = .all {
        didSet {
            if oldValue == filter {
                return
            }

            refreshFetchRequest()
        }
    }

    /// Keyword we should be filtering by
    ///
    var keyword: String? {
        didSet {
            guard oldValue != keyword else {
                return
            }

            refreshFetchRequest()
        }
    }

    /// Sorting Mode
    ///
    var sortMode: SortMode = .alphabeticallyAscending {
         didSet {
            guard oldValue != sortMode else {
                return
            }

            refreshFetchRequest()
         }
    }

    /// Designated Initializer
    ///  - mainContext: Main Thread's MOC
    ///
    init(viewContext: NSManagedObjectContext) {
        assert(viewContext.concurrencyType == .mainQueueConcurrencyType)
        self.viewContext = viewContext
        super.init()
        setupResultsController()
        setupEventsForwarding()
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
    @objc(objectAtIndexPath:)
    func object(at indexPath: IndexPath) -> Note {
        resultsController.object(at: indexPath)
    }

    /// Returns the IndexPath for a given Object
    ///
    func indexPath(forObject object: Note) -> IndexPath? {
        resultsController.indexPath(forObject: object)
    }

    /// Returns the number of fetched objects.
    ///
    var numberOfObjects: Int {
        resultsController.fetchedObjects?.count ?? 0
    }

    /// Returns an array of all of the (ReadOnly) Fetched Objects.
    ///
    var fetchedObjects: [Note] {
        resultsController.fetchedObjects ?? []
    }

    /// Returns an array of SectionInfo Entitites.
    ///
    var sections: [NSFetchedResultsSectionInfo] {
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
    func setupEventsForwarding() {
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
            let wrappedSection = SectionInfo(section: section)
            self?.onDidChangeSection?(wrappedSection, sectionIndex, type)
        }
    }

    /// Refreshes the ResultsController's Fetch Request
    ///
    func refreshFetchRequest() {
        let request = resultsController.fetchRequest
        request.predicate = predicate(keyword: keyword, filter: filter)
        request.sortDescriptors = sortDescriptors(sortMode: sortMode)
    }

    /// Returns a NSPredicate which will filter notes by a given keyword.
    ///
    func predicate(keyword: String?, filter: Filter) -> NSPredicate {
        var predicates = [
            NSPredicate.predicateForNotesWithStatus(deleted: filter == .deleted)
        ]

        switch filter {
        case .all, .deleted:
            break
        case .tag(let name):
            predicates.append( NSPredicate.predicateForTag(with: name) )
        case .untagged:
            predicates.append( NSPredicate.predicateForUntaggedNotes() )
        }

        if let keyword = keyword, keyword.count > 0 {
            predicates.append( NSPredicate.predicateForSearchText(searchText: keyword) )
        }

        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }

    /// Returns the Active SortDescriptors
    ///
    func sortDescriptors(sortMode: SortMode) -> [NSSortDescriptor] {
        let pinnedKeySelector = #selector(getter: Note.pinned)
        let sortKeySelector: Selector
        var sortSelector: Selector?
        var ascending = false

        switch sortMode {
        case .alphabeticallyAscending:
            sortKeySelector = #selector(getter: Note.content)
            sortSelector    = #selector(NSString.caseInsensitiveCompare)
            ascending       = true
        case .alphabeticallyDescending:
            sortKeySelector = #selector(getter: Note.content)
            sortSelector    = #selector(NSString.caseInsensitiveCompare)
            ascending       = false
        case .createdNewest:
            sortKeySelector = #selector(getter: Note.creationDate)
            ascending       = false
        case .createdOldest:
            sortKeySelector = #selector(getter: Note.creationDate)
            ascending       = true
        case .modifiedNewest:
            sortKeySelector = #selector(getter: Note.modificationDate)
            ascending       = false
        case .modifiedOldest:
            sortKeySelector = #selector(getter: Note.modificationDate)
            ascending       = true
        }

        return [
            NSSortDescriptor(key: NSStringFromSelector(pinnedKeySelector), ascending: false),
            NSSortDescriptor(key: NSStringFromSelector(sortKeySelector), ascending: ascending, selector: sortSelector)
        ]
    }
}


// MARK: - Nested Types
//
extension ResultsController {

    // MARK: - ResultsController.ChangeType
    //
    typealias ChangeType = NSFetchedResultsChangeType

    // MARK: - ResultsController.Filter
    //
    enum Filter {
        case all
        case deleted
        case tag(name: String)
        case untagged
    }

    // MARK: - ResultsController.SectionInfo
    //
    class SectionInfo {

        /// Name of the section
        ///
        let name: String

        /// Number of objects in the current section
        ///
        var numberOfObjects: Int {
            objects.count
        }

        /// Returns the array of (ReadOnly) objects in the section.
        ///
        let objects: [Any]


        /// Designated Initializer
        ///
        init(section: NSFetchedResultsSectionInfo) {
            name = section.name
            objects = section.objects ?? []
        }
    }
}


// MARK: ResultsController.Filter Equatable
//
func ==(lhs: ResultsController.Filter, rhs: ResultsController.Filter) -> Bool {
    switch (lhs, rhs) {
    case (.all, .all), (.deleted, .deleted), (.untagged, .untagged):
        return true
    case let (.tag(lName), .tag(rName)):
        return lName == rName
    default:
        return false
    }
}
