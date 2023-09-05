//
//  Dawn.swift
//  Simplenote
//
//  Created by Jorge Leandro Perez on 30/08/2023.
//  Copyright © 2023 Automattic. All rights reserved.
//

import Foundation


@available(iOS 15, *)
class Dawn {

    private let mainContext: NSManagedObjectContext
    private let writerContext: NSManagedObjectContext
    private let engine: SyncEngine
    private var timer: Timer?
    private let queue = TaskQueue()

    init(mainContext: NSManagedObjectContext, writerContext: NSManagedObjectContext, remote: DawnRemote = .init()) {
        self.engine = SyncEngine(writerContext: writerContext, remote: remote)
        self.mainContext = mainContext
        self.writerContext = writerContext
    }

    func startSynchronizing() {
        startListeningToChanges()
        schedulSyncTimer()
        syncNow()
    }

    func stopSynchronizing() {
        stopListeningToChanges()
        invalidateSyncTimer()
    }
}


@available(iOS 15, *)
private extension Dawn {

    func syncNow() {
        queue.dispatch {
            await self.engine.syncNow()
        }
    }
}


@available(iOS 15, *)
private extension Dawn {

    func schedulSyncTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            self.syncNow()
        }
    }

    func invalidateSyncTimer() {
        timer?.invalidate()
        timer = nil
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


// MARK: - Notification Handlers
//
@available(iOS 15, *)
private extension Dawn {

    @objc
    func mainContextWillSave(_ note: Notification) {
        let newNotes = mainContext.insertedObjects.compactMap { $0 as? Note }
        if newNotes.count > .zero {
            setupNewNotes(newNotes)
        }

        let deletedNotes = mainContext.deletedObjects.compactMap { $0 as? Note }
        let identifiers = deletedNotes.compactMap { note in
            note.simperiumKey
        }

        if identifiers.count > .zero {
            schedulDeletionRevisions(identifiers: identifiers)
        }
    }

    @objc
    func mainContextDidSave(_ note: Notification) {
        let objects = note.managedObjectsOfType(SPManagedObject.self)
        if objects.isEmpty {
            return
        }

        queue.dispatch {
            await self.engine.syncNow(objectIDs: objects.compactMap { $0.objectID })
        }
    }
}


@available(iOS 15, *)
extension Dawn {

    func setupNewNotes(_ newNotes: [Note]) {
        do {
            try mainContext.obtainPermanentIDs(for: newNotes)
        } catch {
            NSLog("# Failure obtaining permanent ID(s): \(error)")
        }

        for note in newNotes {
            note.ensureSimperiumKeyIsSet()
        }
    }

    func schedulDeletionRevisions(identifiers: [String]) {
        queue.dispatch {
            await self.engine.scheduleEntryDeletions(identifiers: identifiers)
        }
    }
}
