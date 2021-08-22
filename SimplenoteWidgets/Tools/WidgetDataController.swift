import Foundation
import SimplenoteFoundation
import SimplenoteSearch
import CoreData

class WidgetDataController {

    /// Data Controller
    ///
    let managedObjectContext: NSManagedObjectContext

    /// Notes Controller
    ///
    private lazy var notesController = ResultsController<Note>(
        viewContext: managedObjectContext,
        matching: predicateForNotes(),
        sortedBy: [NSSortDescriptor.descriptorForNotes(sortMode: WidgetDefaults.shared.sortMode)]
    )

    /// Initialization
    ///
    init(context: NSManagedObjectContext, isPreview: Bool = false) throws {
        if !isPreview {
            guard WidgetDefaults.shared.loggedIn else {
                throw WidgetError.appConfigurationError
            }
        }

        self.managedObjectContext = context
    }

    private func performFetch() throws {
        do {
            try notesController.performFetch()
        } catch {
            throw WidgetError.fetchError
        }
    }


    // MARK: Public Methods

    /// Fetch notes with given tag and limit
    /// If no tag is specified, will fetch notes that are not deleted. If there is no limit specified it will fetch all of the notes
    ///
    func notes(withTag tag: String? = nil, limit: Int = .zero) throws -> [Note] {
        notesController.limit = limit

        if let tag = tag {
            notesController.predicate = predicateForNotes(withTag: tag)
        }
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
        let fetched = try notes(withTag: nil, limit: 1)
        return fetched.first
    }

    /// Creates a predicate for notes given a tag name.  If not specified the predicate is for all notes that are not deleted
    ///
    private func predicateForNotes(withTag tag: String? = nil) -> NSPredicate {
        guard let tag = tag else {
            return NSPredicate.predicateForNotes(deleted: false)
        }
        return NSPredicate.predicateForNotes(tag: tag)
    }
}
