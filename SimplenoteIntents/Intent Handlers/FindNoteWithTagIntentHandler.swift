//
//  FindNoteWithTagIntentHandler.swift
//  SimplenoteIntents
//
//  Created by Charlie Scheer on 5/9/24.
//  Copyright © 2024 Automattic. All rights reserved.
//

import Intents

class FindNoteWithTagIntentHandler: NSObject, FindNoteWithTagIntentHandling {
    let coreDataWrapper = ExtensionCoreDataWrapper()

    func resolveNote(for intent: FindNoteWithTagIntent) async -> IntentNoteResolutionResult {
        if let selectedNote = intent.note {
            return IntentNoteResolutionResult.success(with: selectedNote)
        }

        guard let selectedTag = intent.tag else {
            return IntentNoteResolutionResult.needsValue()
        }

        return IntentNoteResolutionResult.resolveIntentNote(forTag: selectedTag, in: coreDataWrapper)
    }

    func provideTagOptionsCollection(for intent: FindNoteWithTagIntent) async throws -> INObjectCollection<IntentTag> {
        let tags = try IntentTag.allTags(in: coreDataWrapper)
        return INObjectCollection(items: tags)
    }

    func handle(intent: FindNoteWithTagIntent) async -> FindNoteWithTagIntentResponse {
        guard let note = intent.note else {
            return FindNoteWithTagIntentResponse(code: .failure, userActivity: nil)
        }

        let response = FindNoteWithTagIntentResponse(code: .success, userActivity: nil)
        response.note = note
        return response
    }
}
