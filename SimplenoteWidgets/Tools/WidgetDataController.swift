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
        sortedBy: [NSSortDescriptor.descriptorForNotes(sortMode: WidgetDefaults.shared.sortMode)]
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
        if !isPreview {
            guard WidgetDefaults.shared.loggedIn else {
                throw WidgetError.appConfigurationError
            }
        }

        self.coreDataManager = coreDataManager
    }

    private func performFetch() throws {
        do {
            try notesController.performFetch()
        } catch {
            throw WidgetError.fetchError
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
            throw WidgetError.fetchError
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
