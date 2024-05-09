//
//  IntentNote+Helpers.swift
//  SimplenoteIntents
//
//  Created by Charlie Scheer on 5/8/24.
//  Copyright © 2024 Automattic. All rights reserved.
//

import Intents

extension IntentNoteResolutionResult {
    static func resolve(_ intentNote: IntentNote?, in coreDataWrapper: ExtensionCoreDataWrapper) -> IntentNoteResolutionResult {
        guard let intentNote = intentNote,
              let identifier = intentNote.identifier else {
            return IntentNoteResolutionResult.needsValue()
        }

        guard coreDataWrapper.resultsController()?.noteExists(forSimperiumKey: identifier) == true else {
            return IntentNoteResolutionResult.unsupported()
        }

        return IntentNoteResolutionResult.success(with: intentNote)
    }

    static func resolveIntentNote(for content: String, in coreDataWrapper: ExtensionCoreDataWrapper) -> IntentNoteResolutionResult {
        guard let notes = coreDataWrapper.resultsController()?.notes() else {
            // TODO: Better error
            return IntentNoteResolutionResult.unsupported()
        }
        let filteredNotes = notes.filter({ $0.content?.contains(content) == true })
        let intentNotes = filteredNotes.map({ IntentNote(identifier: $0.simperiumKey, display: $0.title) })

        guard intentNotes.isEmpty == false else {
            // TODO: Better error
            return IntentNoteResolutionResult.unsupported()
        }

        guard intentNotes.count == 1 else {
            return IntentNoteResolutionResult.disambiguation(with: intentNotes)
        }

        //This shouldn't happen but we to unwrap the existing note we need to return something
        guard let matchingNote = intentNotes.first else {
            return IntentNoteResolutionResult.unsupported()
        }

        return IntentNoteResolutionResult.success(with: matchingNote)
    }
}

extension IntentNote {
    static func allNotes(in coreDataWrapper: ExtensionCoreDataWrapper) throws -> [IntentNote] {
        guard let notes = coreDataWrapper.resultsController()?.notes() else {
            throw IntentsError.couldNotFetchNotes
        }

        return notes.map({ IntentNote(identifier: $0.simperiumKey, display: $0.title) })
    }
}
