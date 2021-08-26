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
    func newNote(from urlComponents: URLComponents) -> Note {
        guard let queryItems = urlComponents.queryItems else {
            return newDefaultNote()
        }

        let newNote = newDefaultNote()

        for item in queryItems {
            if item.name == "content" {
                newNote.content = item.value
            } else if item.name == "tag" {
                if let tags = item.value?.components(separatedBy: " ") {
                    for tag in tags {
                        if tag.count == 0 {
                            continue
                        }
                        newNote.addTag(tag)
                        SPObjectManager.shared().createTag(from: tag)
                    }
                }
            }
        }

        return newNote
    }
}
