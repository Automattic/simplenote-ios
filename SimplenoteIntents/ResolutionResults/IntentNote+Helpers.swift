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
            return IntentNoteResolutionResult.unsupported()
        }
        let filteredNotes = notes.filter({ $0.content?.contains(content) == true })
        let intentNotes = IntentNote.makeIntentNotes(from: filteredNotes)

        return resolve(intentNotes)
    }

    static func resolveIntentNote(forTag tag: IntentTag, in coreDataWrapper: ExtensionCoreDataWrapper) -> IntentNoteResolutionResult {
        guard let notesForTag = coreDataWrapper.resultsController()?.notes(filteredBy: .tag(tag.displayString)) else {
            return IntentNoteResolutionResult.unsupported()
        }

        let intentNotes = IntentNote.makeIntentNotes(from: notesForTag)

        return resolve(intentNotes)
    }

    private static func resolve(_ intentNotes: [IntentNote]) -> IntentNoteResolutionResult {
        guard intentNotes.isEmpty == false else {
            return IntentNoteResolutionResult.unsupported()
        }

        if intentNotes.count == 1,
           let intentNote = intentNotes.first {
            return IntentNoteResolutionResult.success(with: intentNote)
        }

        return IntentNoteResolutionResult.disambiguation(with: intentNotes)
    }
}

extension IntentNote {
    static func allNotes(in coreDataWrapper: ExtensionCoreDataWrapper) throws -> [IntentNote] {
        guard let notes = coreDataWrapper.resultsController()?.notes() else {
            throw IntentsError.couldNotFetchNotes
        }

        return makeIntentNotes(from: notes)
    }

    static func makeIntentNotes(from notes: [Note]) -> [IntentNote] {
        notes.map({ IntentNote(identifier: $0.simperiumKey, display: $0.title) })
    }
}
