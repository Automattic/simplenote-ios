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
        title = note.titlePreview
        let index = note.preview.index(note.preview.startIndex, offsetBy: note.titlePreview.utf16.count)
        contentDescription = note.preview.substring(from: index)
    }
    
}

extension CSSearchableItem {

    convenience init(note: Note) {
        let set = CSSearchableItemAttributeSet(note: note)
        self.init(uniqueIdentifier: note.simperiumKey, domainIdentifier:"notes", attributeSet: set)
    }

}

extension CSSearchableIndex {

    func indexSearchableNote(_ note: Note) {
        let item = CSSearchableItem(note: note)
        CSSearchableIndex.default().indexSearchableItems([item]) { error in
            if let error = error {
                NSLog("Couldn't index note in spotlight: \(error.localizedDescription)");
            }
        }
    }
    
    func indexSearchableNotes(_ notes: [Note]) {
        var items: [CSSearchableItem] = []
        
        for note in notes {
            items.append(CSSearchableItem(note: note))
        }
        
        CSSearchableIndex.default().indexSearchableItems(items) { error in
            if let error = error {
                NSLog("Couldn't index notes in spotlight: \(error.localizedDescription)");
            }
        }
    }
    
    func deleteSearchableNote(_ note: Note) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [note.simperiumKey]) { error in
            if let error = error {
                NSLog("Couldn't delete note from spotlight index: \(error.localizedDescription)");
            }
        }
    }

}
