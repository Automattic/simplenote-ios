import Foundation
import SimplenoteFoundation

// MARK: - SPObjectManager
//
extension SPObjectManager {

    var managedObjectContext: NSManagedObjectContext {
        return SPAppDelegate.shared().managedObjectContext
    }

    @objc
    func newDefaultNote() -> Note {
        // Inserting via the Simperium Bucket ensures the note gets its `simperiumKey` right away
        // (rather than on the first save), so the Internal Link is available immediately
        guard let note = SPAppDelegate.shared().simperium.notesBucket.insertNewObject() as? Note else {
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

        var predicates: [NSPredicate] = []
        predicates.append(.predicateForNotes(tag: tagName))
        if includeDeleted == false {
            predicates.append(.predicateForNotes(deleted: includeDeleted))
        }

        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        return (try? managedObjectContext.fetch(request)) ?? []
    }

    @objc
    func notesWithTag(_ tag: Tag?) -> [Note] {
        return notesWithTag(tag, includeDeleted: false)
    }

    @objc
    func newNote(withContent content: String?, tags: [String]?) -> Note {
        let newNote = newDefaultNote()

        if let content {
            newNote.content = content
        }

        let validator = TagTextFieldInputValidator()
        tags?
            .compactMap({ validator.preprocessForPasting(tag: $0) })
            .forEach { tag in
                newNote.addTag(tag)
                SPObjectManager.shared().createTag(from: tag)
            }

        return newNote
    }
}
