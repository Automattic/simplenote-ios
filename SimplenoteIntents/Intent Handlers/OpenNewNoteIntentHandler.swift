//
//  OpenNewNoteIntentHandler.swift
//  Simplenote
//
//  Created by Charlie Scheer on 5/2/24.
//  Copyright © 2024 Automattic. All rights reserved.
//

import Intents

class OpenNewNoteIntentHandler: NSObject, SPOpenNewNoteIntentHandling {
    func handle(intent: SPOpenNewNoteIntent) async -> SPOpenNewNoteIntentResponse {
        SPOpenNewNoteIntentResponse(code: .continueInApp, userActivity: nil)
    }
}

class OpenNoteIntentHandler: NSObject, SPOpenNoteIntentHandling {
    let coreDataWrapper = WidgetCoreDataWrapper()

    func resolveNote(for intent: SPOpenNoteIntent) async -> SPIntentNoteResolutionResult {
        guard let identifier = intent.note?.identifier,
              let note = coreDataWrapper.resultsController()?.note(forSimperiumKey: identifier) else {
            return SPIntentNoteResolutionResult.confirmationRequired(with: nil)
        }

        return SPIntentNoteResolutionResult.success(with: SPIntentNote(identifier: note.simperiumKey, display: note.title))
    }

    func provideNoteOptionsCollection(for intent: SPOpenNoteIntent) async throws -> INObjectCollection<SPIntentNote> {
        guard let notes = coreDataWrapper.resultsController()?.notes() else {
            throw NSError(domain: "intents", code: 404)
        }

        let intentNotes = notes.map({
            SPIntentNote(identifier: $0.simperiumKey, display: $0.title)
        })
        return INObjectCollection(items: intentNotes)
    }

    func handle(intent: SPOpenNoteIntent) async -> SPOpenNoteIntentResponse {
        guard let identifier = intent.note?.identifier else {
            return SPOpenNoteIntentResponse(code: .failure, userActivity: nil)
        }
        let activity = NSUserActivity(activityType: "SPOpenNoteIntent")
        activity.userInfo = [Self.noteIdentifierKey: identifier]
        return SPOpenNoteIntentResponse(code: .continueInApp, userActivity: activity)
    }

    static let noteIdentifierKey = "OpenNoteIntentHandlerIdentifierKey"
}
