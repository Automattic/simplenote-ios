//
//  Dawn.swift
//  Simplenote
//
//  Created by Jorge Leandro Perez on 30/08/2023.
//  Copyright © 2023 Automattic. All rights reserved.
//

import Foundation


class Dawn {

    private let engine: SyncEngine
    private var timer: Timer?

    init(managedObjectContext: NSManagedObjectContext, remote: DawnRemote = .init()) {
        engine = SyncEngine(managedObjectContext: managedObjectContext, remote: remote)
    }

    func startSynchronizing() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            self.syncNow()
        }

        timer?.fire()
    }

    func stopSynchronizing() {
        timer?.invalidate()
        timer = nil
    }
}


private extension Dawn {

    func syncNow() {
        engine.syncNow()
    }
}
