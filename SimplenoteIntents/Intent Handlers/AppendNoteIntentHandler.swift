//
//  AppendNoteIntentHandler.swift
//  SimplenoteIntents
//
//  Created by Charlie Scheer on 5/6/24.
//  Copyright © 2024 Automattic. All rights reserved.
//

import Intents

class AppendNoteIntentHandler: NSObject, AppendNoteIntentHandling {
    let coreDataWrapper = ExtensionCoreDataWrapper()

    func resolveContent(for intent: AppendNoteIntent) async -> INStringResolutionResult {
        guard let content = intent.content else {
            return INStringResolutionResult.confirmationRequired(with: nil)
        }
        return INStringResolutionResult.success(with: content)
    }

    func resolveNote(for intent: AppendNoteIntent) async -> IntentNoteResolutionResult {
        guard let identifier = intent.note?.identifier,
              let note = coreDataWrapper.resultsController()?.note(forSimperiumKey: identifier) else {
            return IntentNoteResolutionResult.confirmationRequired(with: nil)
        }

        return IntentNoteResolutionResult.success(with: IntentNote(identifier: note.simperiumKey, display: note.title))
    }

    func provideNoteOptionsCollection(for intent: AppendNoteIntent) async throws -> INObjectCollection<IntentNote> {
        guard let notes = coreDataWrapper.resultsController()?.notes() else {
            throw IntentsError.couldNotFetchNotes
        }

        let intentNotes = notes.map({
            IntentNote(identifier: $0.simperiumKey, display: $0.title)
        })
        return INObjectCollection(items: intentNotes)
    }

    func handle(intent: AppendNoteIntent) async -> AppendNoteIntentResponse {
        guard let identifier = intent.note?.identifier,
              let content = intent.content,
              let note = coreDataWrapper.resultsController()?.note(forSimperiumKey: identifier),
              let token = KeychainManager.extensionToken else {
            return AppendNoteIntentResponse(code: .failure, userActivity: nil)
        }

        note.content? += "\n\n\(content)"
        let uploader = Uploader(simperiumToken: token)
        uploader.send(note)

        return AppendNoteIntentResponse(code: .success, userActivity: nil)
    }
}
