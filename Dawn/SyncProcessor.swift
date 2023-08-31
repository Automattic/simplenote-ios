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

    let writerContext: NSManagedObjectContext

    func process(revisions: [EntryRevision]) async {
        writerContext.perform {
            applyInContext(revisions: revisions, context: writerContext)
        }
    }

    func calculateNewRevisions(objectIDs: [NSManagedObjectID]) async -> [(EntryRevisionMetadata, EntryRevisionPayload)] {
        guard #available(iOS 15.0, *) else {
            return []
        }

        return await writerContext.perform {
            calculateNewRevisionsInContext(objectIDs: objectIDs, context: writerContext)
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

        writerContext.saveIfPossible()
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
        note.ensureSimperiumKeyIsSet()
    }

    func processDeleteRevision(_ revision: EntryRevision, context: NSManagedObjectContext) {
        guard let note = Note.fetchNote(in: context, key: revision.entryID) else {
            return
        }

        context.delete(note)
    }
}


private extension SyncProcessor {

    func calculateNewRevisionsInContext(objectIDs: [NSManagedObjectID], context: NSManagedObjectContext) -> [(EntryRevisionMetadata, EntryRevisionPayload)] {
        var output = [(EntryRevisionMetadata, EntryRevisionPayload)]()

        for objectID in objectIDs {
            guard let object = try? context.existingObject(with: objectID) else {
                NSLog("# Failure calculating new revision! \(objectID)")
                continue
            }

            guard let revision = calculateNewRevisionsInContext(object: object, context: context) else {
                continue
            }

            output.append(revision)
        }

        return output
    }

    func calculateNewRevisionsInContext(object: NSManagedObject, context: NSManagedObjectContext) -> (EntryRevisionMetadata, EntryRevisionPayload)? {
        // TODO: Support for multiple entity kinds
        guard let note = object as? Note else {
            NSLog("# Unsupported entity kind")
            return nil
        }

        guard requiresNewRevision(note: note) else {
            return nil
        }

        let entryID     = note.simperiumKey ?? ""
        let journalID   = DawnConstants.journalID
        let editDate    = note.modificationDate ?? Date()
        let body        = note.content ?? ""

        let metadata    = EntryRevisionMetadata(entryID: entryID, journalID: journalID, type: .update, editDate: editDate)
        let payload     = EntryRevisionPayload(id: entryID, isPinned: false, tags: [], body: body)

        return (metadata, payload)
    }

    func requiresNewRevision(note: Note) -> Bool {
        // No Ghost == Never pushed!
        guard let revision = note.decodeGhostRevision() else {
            return true
        }

        return revision.payload.body != note.content
    }
}



extension Note {

    func ensureSimperiumKeyIsSet() {
        guard simperiumKey == nil || simperiumKey.count == .zero else {
            return
        }

        simperiumKey = UUID().uuidString.replacingOccurrences(of: "-", with: "").uppercased()
    }

    func updateGhost(revision: EntryRevision) {
        guard let data = try? JSONEncoder.mercuryRecordEncoder.encode(revision) else {
            NSLog("# ERROR Updating Host!")
            return
        }

        ghostData = String(data: data, encoding: .utf8)
    }

    func decodeGhostRevision() -> EntryRevision? {
        guard let payload = ghostData?.data(using: .utf8) else {
            return nil
        }

        return try? JSONDecoder.mercuryRecordDecoder.decode(EntryRevision.self, from: payload)

    }

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
