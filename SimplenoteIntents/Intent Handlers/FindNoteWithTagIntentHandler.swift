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
        IntentNoteResolutionResult.success(with: IntentNote(identifier: "", display: ""))
    }

    func provideTagOptionsCollection(for intent: FindNoteWithTagIntent) async throws -> INObjectCollection<IntentTag> {
        let tags = try IntentTag.allTags(in: coreDataWrapper)
        return INObjectCollection(items: tags)
    }

    func handle(intent: FindNoteWithTagIntent) async -> FindNoteWithTagIntentResponse {
        FindNoteWithTagIntentResponse(code: .success, userActivity: nil)
    }
}
