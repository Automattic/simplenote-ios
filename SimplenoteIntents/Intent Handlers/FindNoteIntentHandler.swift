//
//  FindNoteIntentHandler.swift
//  SimplenoteIntents
//
//  Created by Charlie Scheer on 5/9/24.
//  Copyright © 2024 Automattic. All rights reserved.
//

import Intents

class FindNoteIntentHandler: NSObject, FindNoteIntentHandling {
    let coreDataWrapper = ExtensionCoreDataWrapper()

    func resolveNote(for intent: FindNoteIntent) async -> IntentNoteResolutionResult {
        // If the user has already selected a note return that note with success
        if let selectedNote = intent.note {
            return IntentNoteResolutionResult.success(with: selectedNote)
        }

        guard let content = intent.content else {
            return IntentNoteResolutionResult.needsValue()
        }

        return IntentNoteResolutionResult.resolveIntentNote(for: content, in: coreDataWrapper)
    }

    func provideNoteOptionsCollection(for intent: FindNoteIntent) async throws -> INObjectCollection<IntentNote> {
        let intentNotes = try IntentNote.allNotes(in: coreDataWrapper)
        return INObjectCollection(items: intentNotes)
    }

    func handle(intent: FindNoteIntent) async -> FindNoteIntentResponse {
        guard let intentNote = intent.note else {
            return FindNoteIntentResponse(code: .failure, userActivity: nil)
        }

        let success = FindNoteIntentResponse(code: .success, userActivity: nil)
        success.note = intentNote

        return success
    }
}
