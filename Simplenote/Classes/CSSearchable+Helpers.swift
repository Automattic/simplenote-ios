//
//  CSSearchableItem+Helpers.swift
//  Simplenote
//
//  Created by Michal Kosmowski on 25/11/2016.
//  Copyright © 2016 Automattic. All rights reserved.
//

import Foundation
import CoreSpotlight
import MobileCoreServices
import UniformTypeIdentifiers

extension CSSearchableItemAttributeSet {

    convenience init(note: Note) {
        self.init(contentType: UTType.data)
        note.ensurePreviewStringsAreAvailable()
        title = note.titlePreview
        contentDescription = note.bodyPreview
    }

}

extension CSSearchableItem {

    convenience init(note: Note) {
        let attributeSet = CSSearchableItemAttributeSet(note: note)
        self.init(uniqueIdentifier: note.simperiumKey, domainIdentifier: "notes", attributeSet: attributeSet)
    }

}

extension CSSearchableIndex {
    // MARK: - Index Notes
    @objc
    func indexSpotlightItems(in context: NSManagedObjectContext) {
        guard Options.shared.indexNotesInSpotlight else {
            return
        }

        context.perform {
            if let deleted = context.fetchObjects(forEntityName: "Note", with: NSPredicate(format: "deleted == YES")) as? [Note] {
                CSSearchableIndex.default().deleteSearchableNotes(deleted)
            }

            if let notes = context.fetchObjects(forEntityName: "Note", with: NSPredicate(format: "deleted == NO")) as? [Note] {
                CSSearchableIndex.default().indexSearchableNotes(notes)
            }
        }
    }

    @objc func indexSearchableNote(_ note: Note) {
        guard Options.shared.indexNotesInSpotlight else {
            return
        }

        let item = CSSearchableItem(note: note)
        indexSearchableItems([item]) { error in
            if let error = error {
                NSLog("Couldn't index note in spotlight: \(error.localizedDescription)")
            }
        }
    }

    @objc func indexSearchableNotes(_ notes: [Note]) {
        guard Options.shared.indexNotesInSpotlight else {
            return
        }

        let items = notes.map {
            return CSSearchableItem(note: $0)
        }

        indexSearchableItems(items) { error in
            if let error = error {
                NSLog("Couldn't index notes in spotlight: \(error.localizedDescription)")
            }
        }
    }

    @objc func deleteSearchableNote(_ note: Note) {
        deleteSearchableNotes([note])
    }

    @objc func deleteSearchableNotes(_ notes: [Note]) {
        let ids = notes.map {
            return $0.simperiumKey!
        }

        deleteSearchableItems(withIdentifiers: ids) { error in
            if let error = error {
                NSLog("Couldn't delete notes from spotlight index: \(error.localizedDescription)")
            }
        }
    }

    @objc
    func deleteSearchableNotes(in context: NSManagedObjectContext) {
        if let notes = context.fetchAllObjects(forEntityName: "Note") as? [Note] {

            deleteSearchableNotes(notes)
        }
    }
}
