//
//  FindNoteIntentHandler.swift
//  SimplenoteIntents
//
//  Created by Charlie Scheer on 5/9/24.
//  Copyright © 2024 Automattic. All rights reserved.
//

import Intents

enum FindNoteError: String {
    case couldNotFetchNotes
    case noMatchingNotesFound

    var localizedDescription: String {
        switch self {
        case .couldNotFetchNotes:
            NSLocalizedString("Could not fetch notes", comment: "Error warning user that their notes could not be fetched")
        case .noMatchingNotesFound:
            NSLocalizedString("Could not find notes matching the search terms", comment: "Error warning user that a matching note could not be found")
        }
    }
}

class FindNoteIntentHandler: NSObject, FindNoteIntentHandling {
    let coreDataWrapper = ExtensionCoreDataWrapper()

    func handle(intent: FindNoteIntent) async -> FindNoteIntentResponse {
        guard let notes = coreDataWrapper.resultsController()?.notes() else {
            return FindNoteIntentResponse.failure(failureReason: FindNoteError.couldNotFetchNotes.localizedDescription)
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
            return FindNoteIntentResponse.failure(failureReason: FindNoteError.noMatchingNotesFound.localizedDescription)
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
