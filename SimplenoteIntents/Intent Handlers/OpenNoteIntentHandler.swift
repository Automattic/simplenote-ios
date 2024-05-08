//
//  OpenNoteIntentHandler.swift
//  Simplenote
//
//  Created by Charlie Scheer on 5/2/24.
//  Copyright © 2024 Automattic. All rights reserved.
//

import Intents

class OpenNoteIntentHandler: NSObject, OpenNoteIntentHandling {
    let coreDataWrapper = ExtensionCoreDataWrapper()

    func resolveNote(for intent: OpenNoteIntent) async -> IntentNoteResolutionResult {
        IntentNoteResolutionResult.resolve(intent.note, in: coreDataWrapper)
    }

    func provideNoteOptionsCollection(for intent: OpenNoteIntent) async throws -> INObjectCollection<IntentNote> {
        let intentNotes = try IntentNote.allNotes(in: coreDataWrapper)
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
