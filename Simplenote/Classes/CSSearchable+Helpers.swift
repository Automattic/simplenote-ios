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

extension CSSearchableItemAttributeSet {

    convenience init(note: Note) {
        self.init(itemContentType: kUTTypeData as String)
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

    @objc func indexSearchableNote(_ note: Note) {
        let item = CSSearchableItem(note: note)
        indexSearchableItems([item]) { error in
            if let error = error {
                NSLog("Couldn't index note in spotlight: \(error.localizedDescription)")
            }
        }
    }

    @objc func indexSearchableNotes(_ notes: [Note]) {
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

}
