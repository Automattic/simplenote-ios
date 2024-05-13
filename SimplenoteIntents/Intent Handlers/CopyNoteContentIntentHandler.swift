//
//  CopyNoteContentIntentHandler.swift
//  SimplenoteIntents
//
//  Created by Charlie Scheer on 5/9/24.
//  Copyright © 2024 Automattic. All rights reserved.
//

import Intents

class CopyNoteContentIntentHandler: NSObject, CopyNoteContentIntentHandling {
    let coreDataWrapper = ExtensionCoreDataWrapper()

    func provideNoteOptionsCollection(for intent: CopyNoteContentIntent) async throws -> INObjectCollection<IntentNote> {
        let intentNotes = try IntentNote.allNotes(in: coreDataWrapper)
        return INObjectCollection(items: intentNotes)
    }

    func handle(intent: CopyNoteContentIntent) async -> CopyNoteContentIntentResponse {
        guard let note = intent.note else {
            return CopyNoteContentIntentResponse(code: .unspecified, userActivity: nil)
        }

        guard let identifier = note.identifier,
              let content = coreDataWrapper.resultsController()?.note(forSimperiumKey: identifier)?.content else {
            return CopyNoteContentIntentResponse(code: .failure, userActivity: nil)
        }

        let response = CopyNoteContentIntentResponse(code: .success, userActivity: nil)
        response.noteContent = content
        return response
    }
}
