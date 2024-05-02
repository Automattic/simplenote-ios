//
//  NoteWidgetIntentHandler.swift
//  Simplenote
//
//  Created by Charlie Scheer on 5/2/24.
//  Copyright © 2024 Automattic. All rights reserved.
//

import Intents

class NoteWidgetIntentHandler: NSObject, NoteWidgetIntentHandling {
    let coreDataWrapper = WidgetCoreDataWrapper()

    func provideNoteOptionsCollection(for intent: NoteWidgetIntent, with completion: @escaping (INObjectCollection<WidgetNote>?, Error?) -> Void) {
        guard WidgetDefaults.shared.loggedIn else {
            completion(nil, WidgetError.appConfigurationError)
            return
        }

        guard let notes = coreDataWrapper.resultsController()?.notes() else {
            completion(nil, WidgetError.fetchError)
            return
        }

        let collection = widgetNoteInObjectCollection(from: notes)
        completion(collection, nil)
    }

    private func widgetNoteInObjectCollection(from notes: [Note]) -> INObjectCollection<WidgetNote> {
        let widgetNotes = notes.map({ note in
            WidgetNote(identifier: note.simperiumKey, display: note.title)
        })
        return INObjectCollection(items: widgetNotes)
    }

    func defaultNote(for intent: NoteWidgetIntent) -> WidgetNote? {
        guard WidgetDefaults.shared.loggedIn,
              let note = coreDataWrapper.resultsController()?.firstNote() else {
            return nil
        }

        return WidgetNote(identifier: note.simperiumKey, display: note.title)
    }
}
