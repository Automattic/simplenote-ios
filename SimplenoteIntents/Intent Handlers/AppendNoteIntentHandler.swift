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
            return INStringResolutionResult.needsValue()
        }
        return INStringResolutionResult.success(with: content)
    }

    func resolveNote(for intent: AppendNoteIntent) async -> IntentNoteResolutionResult {
        IntentNoteResolutionResult.resolve(intent.note, in: coreDataWrapper)
    }

    func provideNoteOptionsCollection(for intent: AppendNoteIntent) async throws -> INObjectCollection<IntentNote> {
        let intentNotes = try IntentNote.allNotes(in: coreDataWrapper)
        return INObjectCollection(items: intentNotes)
    }

    func handle(intent: AppendNoteIntent) async -> AppendNoteIntentResponse {
        guard let identifier = intent.note?.identifier,
              let content = intent.content,
              let note = coreDataWrapper.resultsController()?.note(forSimperiumKey: identifier),
              let token = KeychainManager.extensionToken else {
            return AppendNoteIntentResponse(code: .failure, userActivity: nil)
        }

        guard let existingContent = try? await Downloader(simperiumToken: token).getNoteContent(for: identifier) else {
            return AppendNoteIntentResponse(code: .failure, userActivity: nil)
        }

        note.content = existingContent + "\n\n\(content)"
        let uploader = Uploader(simperiumToken: token)
        uploader.send(note)

        return AppendNoteIntentResponse(code: .success, userActivity: nil)
    }
}
