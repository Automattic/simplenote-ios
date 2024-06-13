import Intents

class CreateNewNoteIntentHandler: NSObject, CreateNewNoteIntentHandling {
    let coreDataWrapper = ExtensionCoreDataWrapper()

    func handle(intent: CreateNewNoteIntent) async -> CreateNewNoteIntentResponse {
        guard let content = intent.content,
              let token = KeychainManager.extensionToken else {
            return CreateNewNoteIntentResponse(code: .failure, userActivity: nil)
        }

        do {
            _ = try await Uploader(simperiumToken: token).send(note(with: content))
            return CreateNewNoteIntentResponse(code: .success, userActivity: nil)
        } catch {
            return CreateNewNoteIntentResponse.failure(failureReason: error.localizedDescription)
        }
    }

    private func note(with content: String) -> Note {
        let note = Note(context: coreDataWrapper.context())
        note.creationDate = .now
        note.modificationDate = .now
        note.content = content

        return note
    }
}
