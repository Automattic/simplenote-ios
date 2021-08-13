import Foundation
import SimplenoteFoundation
import SimplenoteSearch

class WidgetDataController {

    /// Data Controller
    ///
    let coreDataManager: CoreDataManager

    /// Notes Controller
    ///
    private lazy var notesController = ResultsController<Note>(
        viewContext: coreDataManager.managedObjectContext,
        matching: predicateForNotes(),
        sortedBy: [NSSortDescriptor.descriptorForNotes(sortMode: noteSortMode)]
    )

    /// Tags Controller
    ///
    private lazy var tagsController = ResultsController<Tag>(
        viewContext: coreDataManager.managedObjectContext,
        sortedBy: [NSSortDescriptor.descriptorForTags()]
    )

    /// Initialization
    ///
    init(coreDataManager: CoreDataManager, isPreview: Bool = false) throws {
        guard !isPreview else {
            self.coreDataManager = coreDataManager
            return
        }

        guard let isLoggedIn = UserDefaults(suiteName: SimplenoteConstants.sharedGroupDomain)?.bool(forKey: .accountIsLoggedIn),
              isLoggedIn else {
            throw StorageError.appConfigurationError
        }

        self.coreDataManager = coreDataManager
    }

    /// Sort mode for widgets.  Fetched from main apps sort setting
    ///
    private var noteSortMode: SortMode {
        guard let defaults = UserDefaults(suiteName: SimplenoteConstants.sharedGroupDomain) else {
            return SortMode.alphabeticallyAscending
        }

        return SortMode(rawValue: defaults.integer(forKey: .listSortMode))
            ?? SortMode.alphabeticallyAscending
    }

    private func performFetch() throws {
        do {
            try notesController.performFetch()
        } catch {
            throw StorageError.fetchError
        }
    }
    // MARK: - Notes

    /// Fetch notes with given tag and limit
    /// If no tag is specified, will fetch notes that are not deleted. If there is no limit specified it will fetch all of the notes
    ///
    func notes(withFilter tagsFilter: TagsFilter = .allNotes, limit: Int = .zero) throws -> [Note] {
        notesController.limit = limit

        notesController.predicate = predicateForNotes(filteredBy: tagsFilter)
        try performFetch()

        return notesController.fetchedObjects
    }

    /// Returns note given a simperium key
    ///
    func note(forSimperiumKey key: String) -> Note? {
        notesController.predicate = predicateForNotes()

        do {
            try notesController.performFetch()
        } catch {
            return nil
        }

        return notesController.fetchedObjects.first { note in
            note.simperiumKey == key
        }
    }

    func firstNote() throws -> Note? {
        let fetched = try notes(limit: 1)
        return fetched.first
    }

    /// Creates a predicate for notes given a tag name.  If not specified the predicate is for all notes that are not deleted
    ///
    private func predicateForNotes(filteredBy tagFilter: TagsFilter = .allNotes) -> NSPredicate {
        switch tagFilter {
        case .allNotes:
            return NSPredicate.predicateForNotes(deleted: false)
        case .tag(let tag):
            return NSPredicate.predicateForNotes(tag: tag)
        }
    }

    // MARK: - Tags

    func tags() throws -> [Tag] {
        do {
            try tagsController.performFetch()
        } catch {
            throw StorageError.fetchError
        }

        return tagsController.fetchedObjects
    }
}

enum TagsFilter {
    case allNotes
    case tag(String)
}

extension TagsFilter {
    init(from tag: String) {
        switch tag {
        case WidgetConstants.allNotesIdentifier:
            self = .allNotes
        default:
            self = .tag(tag)
        }
    }
}
