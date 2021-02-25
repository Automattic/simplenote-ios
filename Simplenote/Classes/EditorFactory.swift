import Foundation


// MARK: - Editor Factory (!)
//
@objcMembers
class EditorFactory: NSObject {

    /// Yet another Singleton
    ///
    static let shared = EditorFactory()

    /// Editor's Restoration Class
    ///
    var restorationClass: UIViewControllerRestoration.Type?

    /// Scroll position cache
    ///
    private let scrollPositionCache = NoteScrollPositionCache()

    /// You shall not pass!
    ///
    private override init() {
        super.init()
    }

    /// Returns a new Editor Instance
    ///
    func build(with note: Note?) -> SPNoteEditorViewController {
        assert(restorationClass != nil)

        let controller = SPNoteEditorViewController(note: note ?? newNote())
        controller.restorationClass = restorationClass
        controller.restorationIdentifier = SPNoteEditorViewController.defaultRestorationIdentifier
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
