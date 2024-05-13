//
//  CreateNewNoteIntentHandler.swift
//  SimplenoteIntents
//
//  Created by Charlie Scheer on 5/8/24.
//  Copyright © 2024 Automattic. All rights reserved.
//

import Intents

class CreateNewNoteIntentHandler: NSObject, CreateNewNoteIntentHandling {
    let coreDataWrapper = ExtensionCoreDataWrapper()

    func handle(intent: CreateNewNoteIntent) async -> CreateNewNoteIntentResponse {
        guard let content = intent.content,
              let token = KeychainManager.extensionToken else {
            return CreateNewNoteIntentResponse(code: .failure, userActivity: nil)
        }

        Uploader(simperiumToken: token).send(note(with: content))
        return CreateNewNoteIntentResponse(code: .success, userActivity: nil)
    }

    private func note(with content: String) -> Note {
        let note = Note(context: coreDataWrapper.context())
        note.creationDate = .now
        note.modificationDate = .now
        note.content = content

        return note
    }
}
