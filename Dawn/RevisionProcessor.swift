//
//  SyncChangeProcessor.swift
//  Simplenote
//
//  Created by Jorge Leandro Perez on 30/08/2023.
//  Copyright © 2023 Automattic. All rights reserved.
//

import Foundation
import CoreData


struct SyncProcessor {

    let managedObjectContext: NSManagedObjectContext

    func process(revisions: [EntryRevision]) {
        managedObjectContext.perform {
            applyInContext(revisions: revisions, context: managedObjectContext)
        }
    }
}

private extension SyncProcessor {

    func applyInContext(revisions: [EntryRevision], context: NSManagedObjectContext) {
        for revision in revisions {
            NSLog("# Processing revision of type \(revision.type.rawValue)")

            switch revision.type {
            case .create:
                fallthrough
            case .update:
                processUpdateRevision(revision, context: context)
            case .delete:
                processDeleteRevision(revision, context: context)
            case .merge:
                NSLog("# Unsupported Revision Type!")
                break
            }
        }

        managedObjectContext.saveIfPossible()
    }

    func processUpdateRevision(_ revision: EntryRevision, context: NSManagedObjectContext) {
        let note = Note.fetchNote(in: context, key: revision.entryID) ?? Note(context: context)
        update(note: note, using: revision)
    }

    func update(note: Note, using revision: EntryRevision) {

        // TODO: Why the Body has `\\` ?

        note.simperiumKey = revision.entryID
        note.content = revision.body.replacingOccurrences(of: "\\", with: "")

        note.createPreview()
    }

    func processDeleteRevision(_ revision: EntryRevision, context: NSManagedObjectContext) {
        guard let note = Note.fetchNote(in: context, key: revision.entryID) else {
            return
        }

        context.delete(note)
    }
}


extension Note {

    class func fetchNote(in context: NSManagedObjectContext, key: String) -> Note? {
        let request = NSFetchRequest<Note>(entityName: "Note")
        request.predicate = NSPredicate(format: "%K = %@", #keyPath(Note.simperiumKey), key)

        return try? context.fetch(request).first
    }
}


extension NSManagedObjectContext {

    func saveIfPossible() {
        perform {
            do {
                try self.save()
            } catch {
                NSLog("# FATAL: \(error)")
            }
        }
    }
}
