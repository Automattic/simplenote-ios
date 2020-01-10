import Foundation
import CoreData


// MARK: - SPSearchResultsController
//
@objcMembers
class SPSearchResultsController: NSObject {

    /// Batch Size for the FRC's Request
    ///
    private let resultsBatchSize = 20

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
    private(set) lazy var resultsController: NSFetchedResultsController<Note> = {
        NSFetchedResultsController<Note>(fetchRequest: request, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
    }()

    /// View Context MOC: Main Thread!
    ///
    let viewContext: NSManagedObjectContext

    /// Active Filter
    ///
    var filter: SPTagFilterType = .userTag {
        didSet {
            guard oldValue != filter else {
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

    /// Selected Tag
    ///
    var selectedTag: String? {
        didSet {
            guard oldValue != selectedTag else {
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
    }
}


// MARK: - Public Methods
//
extension SPSearchResultsController {

    /// Executes the fetch request on the store to get objects.
    ///
    func performFetch() throws {
        try resultsController.performFetch()
    }

    @objc(objectAtIndexPath:)
    func object(at indexPath: IndexPath) -> Note {
        return resultsController.object(at: indexPath)
    }

    func indexPath(forObject object: Note) -> IndexPath? {
        return resultsController.indexPath(forObject: object)
    }

    /// Returns the number of fetched objects.
    ///
    var numberOfObjects: Int {
        return resultsController.fetchedObjects?.count ?? 0
    }

    /// Returns an array of all of the (ReadOnly) Fetched Objects.
    ///
    var fetchedObjects: [Note] {
        return resultsController.fetchedObjects ?? []
    }

    /// Returns an array of SectionInfo Entitites.
    ///
    var sections: [NSFetchedResultsSectionInfo] {
        return resultsController.sections ?? []
    }
}


// MARK: - Private Methods
//
private extension SPSearchResultsController {

    /// Refreshes the ResultsController's Fetch Request
    ///
    func refreshFetchRequest() {
        let request = resultsController.fetchRequest
        request.predicate = predicate(keyword: keyword, filter: filter)
        request.sortDescriptors = sortDescriptors(sortMode: sortMode)
    }

    /// Returns a NSPredicate which will filter notes by a given keyword.
    ///
    func predicate(keyword: String?, filter: SPTagFilterType) -> NSPredicate {
        var predicates = [
            NSPredicate.predicateForNotesWithStatus(deleted: filter == .deleted)
        ]

        switch filter {
        case .userTag:
            if let selectedTag = selectedTag {
                predicates.append( NSPredicate.predicateForTag(with: selectedTag) )
            }
        case .untagged:
            predicates.append( NSPredicate.predicateForUntaggedNotes() )
        default:
            break
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
