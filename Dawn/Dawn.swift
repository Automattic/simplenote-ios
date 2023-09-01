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
        timer?.fire()
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
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
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
        let notes = mainContext.insertedObjects.compactMap { $0 as? Note }
        if notes.isEmpty {
            return
        }

        do {
            try mainContext.obtainPermanentIDs(for: notes)
        } catch {
            NSLog("# Failure obtaining permanent ID(s): \(error)")
        }

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

        queue.dispatch {
            await self.engine.syncNow(objectIDs: objects.compactMap { $0.objectID })
        }
    }
}
