//
//  SyncEngine.swift
//  Simplenote
//
//  Created by Jorge Leandro Perez on 30/08/2023.
//  Copyright © 2023 Automattic. All rights reserved.
//

import Foundation


// MARK: - SyncEngine
//
class SyncEngine {

    let mainContext: NSManagedObjectContext
    let writerContext: NSManagedObjectContext
    let remote: DawnRemote
    let processor: SyncProcessor

    init(mainContext: NSManagedObjectContext, writerContext: NSManagedObjectContext, remote: DawnRemote) {
        self.remote = remote
        self.mainContext = mainContext
        self.writerContext = writerContext
        self.processor = SyncProcessor(writerContext: writerContext)
    }

    func startListeningToChanges() {
        stopListeningToChanges()
        NotificationCenter.default.addObserver(self, selector: #selector(mainContextWillSave(_:)), name: .NSManagedObjectContextWillSave, object: mainContext)
        NotificationCenter.default.addObserver(self, selector: #selector(mainContextDidSave(_:)), name: .NSManagedObjectContextDidSave, object: mainContext)
    }

    func stopListeningToChanges() {
        NotificationCenter.default.removeObserver(self)
    }
}

extension SyncEngine {

    func syncNow() {
        Task {
            await pullChanges()
            await pushAllChanges()
        }
    }
}


// MARK: - Notification Handlers
//
private extension SyncEngine {

    @objc
    func mainContextWillSave(_ note: Notification) {
        if mainContext.insertedObjects.isEmpty {
            return
        }

        do {
            try mainContext.obtainPermanentIDs(for: Array(mainContext.insertedObjects))
        } catch {
            NSLog("# Failure obtaining permanent ID(s): \(error)")
        }

        let notes = mainContext.insertedObjects.compactMap { $0 as? Note }
        for note in notes {
            note.ensureSimperiumKeyIsSet()
        }
    }

    @objc
    func mainContextDidSave(_ note: Notification) {
        let objects = note.managedObjectsOfType(SPManagedObject.self)
        if objects.isEmpty {
            return
        }

        let objectIDs = objects.map { $0.objectID }
        Task {
            await pushChanges(objectIDs: objectIDs)
        }
    }
}

private extension SyncEngine {

    var lastSeenCursor: String? {
        get {
            UserDefaults.standard.value(forKey: DawnConstants.lastSeenKey) as? String
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: DawnConstants.lastSeenKey)
        }
    }
}


private extension SyncEngine {

    func updateCursor(revisions: [EntryRevision]) {
        guard let revision = revisions.last else {
            return
        }

        NSLog("# Persisting cursor \(revision.cursor)")
        lastSeenCursor = String(revision.cursor)
    }

    func save() {
        writerContext.perform {
            try? self.writerContext.save()
        }
    }
}


private extension SyncEngine {

    func pullChanges() async {
        do {
            let revisions = try await remote.fetchLatestRevisions(cursor: lastSeenCursor)
            if revisions.isEmpty {
                return
            }
            NSLog("# Retrieved \(revisions.count) revisions since \(lastSeenCursor ?? "-")")

            await processor.process(revisions: revisions)
            updateCursor(revisions: revisions)
            save()

        } catch {
            NSLog("# Error: \(error)")
        }
    }

    func pushAllChanges() async {
// TODO: Fetch all objects
    }

    func pushChanges(objectIDs: [NSManagedObjectID]) async {
        //            let entryID = "7D330AD0F73247819F18F31B808498EF"
        //            let journalID = DawnConstants.journalID
        //            let editDate = Date()
        //            let body = "YOSEMITE!"
        //
        //            let metadata = EntryRevisionMetadata(entryID: entryID, journalID: journalID, type: .update, editDate: editDate)
        //            let payload = EntryRevisionPayload(id: entryID, isPinned: false, tags: [], body: body)

        do {
            let revisions = await processor.calculateNewRevisions(objectIDs: objectIDs)
            for (metadata, payload) in revisions {
                NSLog("# Submitting new revision!")
                try await remote.pushEntryRevision(metadata: metadata, payload: payload)
            }

        } catch {
            NSLog("# Error \(error)")
        }

    }
}
