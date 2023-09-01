//
//  Note+Dawn.swift
//  Simplenote
//
//  Created by Jorge Leandro Perez on 01/09/2023.
//  Copyright © 2023 Automattic. All rights reserved.
//

import Foundation


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

    class func fetchAllObjectIDs(in context: NSManagedObjectContext) -> [NSManagedObjectID] {
        let request = NSFetchRequest<Note>(entityName: "Note")
        guard let result = try? context.fetch(request) else {
            return []
        }

        return result.map { note in
            note.objectID
        }
    }
}
