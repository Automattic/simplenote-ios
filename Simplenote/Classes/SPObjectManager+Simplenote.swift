import Foundation
import SimplenoteFoundation

// MARK: - SPObjectManager
//
extension SPObjectManager {

    var managedObjectContext: NSManagedObjectContext {
        return SPAppDelegate.shared().coreDataManager.managedObjectContext
    }

    @objc
    func newDefaultNote() -> Note {
        guard let note = NSEntityDescription.insertNewObject(forEntityName: Note.entityName, into: managedObjectContext) as? Note else {
            fatalError()
        }

        note.modificationDate = Date()
        note.creationDate = Date()

        // Set the note's markdown tag according to the global preference (defaults NO for new accounts)
        note.markdown = Options.shared.markdown

        return note
    }

    @objc
    func notesWithTag(_ tag: Tag?, includeDeleted: Bool) -> [Note] {
        guard let tagName = tag?.name else {
            return []
        }

        let request = NSFetchRequest<Note>(entityName: Note.entityName)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            .predicateForNotes(tag: tagName),
            .predicateForNotes(deleted: includeDeleted)
        ])

        return (try? managedObjectContext.fetch(request)) ?? []
    }

    @objc
    func notesWithTag(_ tag: Tag?) -> [Note] {
        return notesWithTag(tag, includeDeleted: false)
    }
}
