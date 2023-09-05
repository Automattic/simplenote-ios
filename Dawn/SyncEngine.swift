//
//  SyncEngine.swift
//  Simplenote
//
//  Created by Jorge Leandro Perez on 30/08/2023.
//  Copyright © 2023 Automattic. All rights reserved.
//

import Foundation
import CoreData


// MARK: - SyncEngine
//
@available(iOS 15, *)
actor SyncEngine {

    private let writerContext: NSManagedObjectContext
    private let remote: DawnRemote
    private let processor: SyncProcessor
    private var pendingDeletions = Set<EntryRevision>()

    init(writerContext: NSManagedObjectContext, remote: DawnRemote) {
        self.remote = remote
        self.writerContext = writerContext
        self.processor = SyncProcessor(writerContext: writerContext)
    }
}

@available(iOS 15, *)
extension SyncEngine {

    func syncNow() async {
        let allObjectIDs = await fetchAllNoteObjectIDs()
        await syncNow(objectIDs: allObjectIDs)
    }

    func syncNow(objectIDs: [NSManagedObjectID]) async {
        NSLog("# SyncNow!")
        await downloadLatestRevisions()
        await submitNewRevisions(for: objectIDs)
        await submitScheduledDeletions()
    }

    /// TODO: Fix architecture!
    func scheduleEntryDeletions(identifiers: [String]) {
        for identifier in identifiers {
            let metadata = EntryRevisionMetadata(entryID: identifier, journalID: DawnConstants.journalID, type: .delete)
            let revision = EntryRevision(metadata: metadata, payload: nil)

            pendingDeletions.insert(revision)
        }
    }
}


@available(iOS 15, *)
private extension SyncEngine {

    var lastSeenCursor: String? {
        get {
            UserDefaults.standard.value(forKey: DawnConstants.lastSeenKey) as? String
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: DawnConstants.lastSeenKey)
            UserDefaults.standard.synchronize()
            NSLog("# SETTING Cursor to \(newValue)")
            // TODO: Fix spurious Cursor Reset?
        }
    }
}


@available(iOS 15, *)
private extension SyncEngine {

    func fetchAllNoteObjectIDs() async -> [NSManagedObjectID] {
        await writerContext.perform {
            Note.fetchAllObjectIDs(in: self.writerContext)
        }
    }

    func save() async {
        await writerContext.perform {
            try? self.writerContext.save()
        }
    }
}


@available(iOS 15, *)
private extension SyncEngine {

    func downloadLatestRevisions() async {
        do {
            let cursor = lastSeenCursor
            guard let (lastCursor, revisions) = try await remote.downloadLatestRevisions(cursor: cursor) else {
                return
            }

            NSLog("# Retrieved \(revisions.count) revisions since \(cursor ?? "-")")

            await processor.processNewRevisions(revisions)
            await save()

            lastSeenCursor = lastCursor

        } catch {
            NSLog("# Error: \(error)")
        }
    }

    func submitNewRevisions(for objectIDs: [NSManagedObjectID]) async {
        do {
            for objectID in objectIDs {
                guard let revision = await processor.calculateNewRevision(objectID: objectID) else {
                    continue
                }

                try await submitNewRevision(revision: revision)
            }

        } catch {
            NSLog("# Error \(error)")
        }
    }

    func submitNewRevision(revision: EntryRevision) async throws {
        NSLog("# Submitting new revision for [\(revision.metadata.entryID)]")
        let (outcome, latest) = try await remote.submitNewRevision(revision: revision)

        switch outcome {
        case .clean:
            NSLog("# New revision submitted successfully!")
            await processor.processNewRevisions([latest])

        case .dirty:
            NSLog("# Rebasing...!")
            await processor.rebaseLocalRevision(latest: latest)
        }

        await save()
    }
}

@available(iOS 15, *)
private extension SyncEngine {

    func submitScheduledDeletions() async {
        let revisions = Array(pendingDeletions)

        for revision in revisions {
            do {
                _ = try await remote.submitNewRevision(revision: revision)
                pendingDeletions.remove(revision)
                NSLog("# Deleted revision \(revision.metadata.entryID)")
            } catch {
                NSLog("# Error deleting \(revision.metadata.entryID)")
            }
        }
    }
}
