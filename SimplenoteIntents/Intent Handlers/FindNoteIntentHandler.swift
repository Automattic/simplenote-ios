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

    func handle(intent: FindNoteIntent) async -> FindNoteIntentResponse {
        guard let notes = coreDataWrapper.resultsController()?.notes() else {
            return FindNoteIntentResponse(code: .failure, userActivity: nil)
        }

        guard let content = intent.content else {
            return FindNoteIntentResponse(code: .unspecified, userActivity: nil)
        }

        let matchingNotes: [Note] = notes.compactMap({
            if $0.content?.contains(content) == true {
                return $0
            }
            return nil
        })

        guard matchingNotes.isEmpty == false else {
            // TODO: Create custom respond code to alert user that no notes were found
            return FindNoteIntentResponse(code: .failure, userActivity: nil)
        }

        guard matchingNotes.count == 1 else {
            // TODO: Disambiguate the notes
            return FindNoteIntentResponse(code: .failure, userActivity: nil)
        }

        guard let matchingNote = matchingNotes.first else {
            return FindNoteIntentResponse(code: .failure, userActivity: nil)
        }
        let success = FindNoteIntentResponse(code: .success, userActivity: nil)
        success.note = IntentNote(identifier: matchingNote.simperiumKey, display: matchingNote.title)

        return success

    }
}
