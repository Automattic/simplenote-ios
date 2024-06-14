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

        do {
            let existingContent = try await downloadNoteContent(for: identifier, token: token) ?? String()
            note.content = existingContent + "\n\(content)"

            try await uploadNoteContent(note, token: token)
        } catch {
            return handleFailure(with: error, content: content)
        }
    }

    private func downloadNoteContent(for identifier: String, token: String) async throws -> String? {
        let downloader = Downloader(simperiumToken: token)
        return try await downloader.getNoteContent(for: identifier)
    }

    private func uploadNoteContent(_ note: Note, token: String) async throws {
        let uploader = Uploader(simperiumToken: token)
        _ = try await uploader.send(note)
    }

    private func handleFailure(with error: Error, content: String) -> AppendNoteIntentResponse {
        RecoveryArchiver().archiveContent(content)
        return AppendNoteIntentResponse.failure(failureReason: "\(error.localizedDescription) - \(IntentsConstants.recoveryMessage)")
    }
}
