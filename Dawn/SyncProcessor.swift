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

    func processNewRevisions(_ revisions: [EntryRevision]) async {
        guard #available(iOS 15.0, *) else {
            return
        }

        await writerContext.perform {
            processNewRevisionsInContext(revisions: revisions, context: writerContext)
        }
    }

    func calculateNewRevision(objectID: NSManagedObjectID) async -> EntryRevision? {
        guard #available(iOS 15.0, *) else {
            return nil
        }

        return await writerContext.perform {
            calculateNewRevisionInContext(objectID: objectID, context: writerContext)
        }
    }

    func rebaseLocalRevision(latest: EntryRevision) async {
        guard #available(iOS 15.0, *) else {
            return
        }

        await writerContext.perform {
            rebaseLocalRevisionInContext(latest: latest, context: writerContext)
        }
    }
}

private extension SyncProcessor {

    func processNewRevisionsInContext(revisions: [EntryRevision], context: NSManagedObjectContext) {
        for revision in revisions {
            NSLog("# Processing revision of type \(revision.metadata.type.rawValue)")

            switch revision.metadata.type {
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
        let note = Note.fetchNote(in: context, key: revision.metadata.entryID) ?? Note(context: context)

        guard containsLocalChanges(note: note), note.content != revision.payload?.simplenoteBody else {
            apply(revision: revision, to: note)
            return
        }

        /// Rebasing + Applying On Top!
        rebaseLocalRevisionInContext(latest: revision, local: note, context: context)
    }

    func apply(revision: EntryRevision, to note: Note) {
        note.simperiumKey = revision.metadata.entryID
        note.content = revision.payload?.simplenoteBody
        note.modificationDate = revision.metadata.editDate
        note.updateGhost(revision: revision)
        note.createPreview()
        note.ensureSimperiumKeyIsSet()
    }

    func processDeleteRevision(_ revision: EntryRevision, context: NSManagedObjectContext) {
        guard let note = Note.fetchNote(in: context, key: revision.metadata.entryID) else {
            return
        }

        context.delete(note)
    }
}


// MARK: - Revision Calculation
//
private extension SyncProcessor {

    func calculateNewRevisionInContext(objectID: NSManagedObjectID, context: NSManagedObjectContext) -> EntryRevision? {
        guard let note = try? context.existingObject(with: objectID) as? Note else {
            // TODO: Support for multiple entity kinds
            // TODO: Support Deletion!
            return nil
        }

        guard containsLocalChanges(note: note) else {
            return nil
        }

        let entryID     = note.simperiumKey ?? ""
        let journalID   = DawnConstants.journalID
        let editDate    = note.modificationDate ?? Date()
        let body        = note.content ?? ""

        let metadata    = EntryRevisionMetadata(entryID: entryID, journalID: journalID, type: .update, editDate: editDate)
        let payload     = EntryRevisionPayload(id: entryID, isPinned: false, tags: [], body: body)

        return EntryRevision(metadata: metadata, payload: payload)
    }

    func containsLocalChanges(note: Note) -> Bool {
        // No Ghost == Never pushed!
        guard let revision = note.decodeGhostRevision() else {
            let isEmpty = note.content?.isEmpty ?? false
            return isEmpty == false
        }

        return revision.payload?.simplenoteBody != note.content
    }
}



// MARK: - Rebase Mechanism
//
extension SyncProcessor {

    func rebaseLocalRevisionInContext(latest: EntryRevision, context: NSManagedObjectContext) {
        guard let local = Note.fetchNote(in: context, key: latest.metadata.entryID) else {
            NSLog("# FATAL: Missing Note \(latest.metadata.entryID))")
            return
        }

        rebaseLocalRevisionInContext(latest: latest, local: local, context: context)
    }

    func rebaseLocalRevisionInContext(latest: EntryRevision, local: Note, context: NSManagedObjectContext) {
        guard let lastKnownPayload = local.decodeGhostRevision()?.payload else {
            NSLog("# FATAL: Cannot decode Ghost")
            return
        }

        guard let latestPayload = latest.payload else {
            NSLog("# FATAL: Latest Remote contains no payload")
            return
        }

        do {
            let dmp = DiffMatchPatch()
            let rebased = try dmp.rebase(currentValue: local.content,
                                         otherValue: latestPayload.simplenoteBody,
                                         oldValue: lastKnownPayload.simplenoteBody)

            local.content = rebased.replacingOccurrences(of: "\\", with: "")
            local.modificationDate = Date()
        } catch {
            NSLog("# Rebase Failure!! \(error)")
        }
    }
}
