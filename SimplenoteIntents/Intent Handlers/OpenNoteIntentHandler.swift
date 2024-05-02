//
//  OpenNoteIntentHandler.swift
//  Simplenote
//
//  Created by Charlie Scheer on 5/2/24.
//  Copyright © 2024 Automattic. All rights reserved.
//

import Intents

class OpenNoteIntentHandler: NSObject, OpenNoteIntentHandling {
    let coreDataWrapper = WidgetCoreDataWrapper()

    func resolveNote(for intent: OpenNoteIntent) async -> IntentNoteResolutionResult {
        guard let identifier = intent.note?.identifier,
              let note = coreDataWrapper.resultsController()?.note(forSimperiumKey: identifier) else {
            return IntentNoteResolutionResult.confirmationRequired(with: nil)
        }

        return IntentNoteResolutionResult.success(with: IntentNote(identifier: note.simperiumKey, display: note.title))
    }

    func provideNoteOptionsCollection(for intent: OpenNoteIntent) async throws -> INObjectCollection<IntentNote> {
        guard let notes = coreDataWrapper.resultsController()?.notes() else {
            throw fatalError("Could not fetch notes")
        }

        let intentNotes = notes.map({
            IntentNote(identifier: $0.simperiumKey, display: $0.title)
        })
        return INObjectCollection(items: intentNotes)
    }

    func handle(intent: OpenNoteIntent) async -> OpenNoteIntentResponse {
        guard let identifier = intent.note?.identifier else {
            return OpenNoteIntentResponse(code: .failure, userActivity: nil)
        }
        let activity = NSUserActivity(activityType: ActivityType.openNoteShortcut.rawValue)
        activity.userInfo = [IntentsConstants.noteIdentifierKey: identifier]
        return OpenNoteIntentResponse(code: .continueInApp, userActivity: activity)
    }
}
