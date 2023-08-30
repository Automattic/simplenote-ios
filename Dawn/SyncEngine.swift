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

    let managedObjectContext: NSManagedObjectContext
    let remote: DawnRemote
    let processor: SyncProcessor

    init(managedObjectContext: NSManagedObjectContext, remote: DawnRemote) {
        self.remote = remote
        self.managedObjectContext = managedObjectContext
        self.processor = SyncProcessor(managedObjectContext: managedObjectContext)
    }

    func startListeningToChanges() {
        stopListeningToChanges()
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidSave(_:)), name: .NSManagedObjectContextDidSave, object: nil)
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
    func contextDidSave(_ note: Notification) {
        let objects = note.managedObjectsOfType(SPManagedObject.self)
        if objects.isEmpty {
            return
        }

        Task {
            await pushChanges(objects: objects)
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

        lastSeenCursor = String(revision.cursor)
    }
}


private extension SyncEngine {

    func pullChanges() async {
        do {
            let revisions = try await remote.fetchLatestRevisions(cursor: lastSeenCursor)
            NSLog("# Retrieved \(revisions.count) revisions since \(lastSeenCursor ?? "")")

            processor.process(revisions: revisions)
            updateCursor(revisions: revisions)

        } catch {
            NSLog("# Error: \(error)")
        }
    }

    func pushAllChanges() async {

    }

    func pushChanges(objects: Set<SPManagedObject>) async {

    }
}
