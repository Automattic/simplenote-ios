import Foundation

// MARK: - Editor Factory (!)
//
@objcMembers
class EditorFactory: NSObject {

    /// Yet another Singleton
    ///
    static let shared = EditorFactory()

    /// Scroll position cache
    ///
    let scrollPositionCache: NoteScrollPositionCache = {
        let fileURL = FileManager.default.documentsURL.appendingPathComponent(Constants.filename)
        return NoteScrollPositionCache(storage: FileStorage(fileURL: fileURL))
    }()

    /// You shall not pass!
    ///
    override private init() {
        super.init()
    }

    /// Returns a new Editor Instance
    ///
    func build(with note: Note?) -> SPNoteEditorViewController {
        let controller = SPNoteEditorViewController(note: note ?? newNote())
        controller.scrollPositionCache = scrollPositionCache
        return controller
    }

    private func newNote() -> Note {
        let note = SPObjectManager.shared().newDefaultNote()
        if let tagName = SPAppDelegate.shared().filteredTagName {
            note.addTag(tagName)
        }
        return note
    }
}

// MARK: - Constants
//
private struct Constants {
    static let filename = ".scroll-cache"
}
