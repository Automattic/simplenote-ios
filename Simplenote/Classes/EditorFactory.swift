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

    /// You shall not pass!
    ///
    private override init() {
        super.init()
    }

    /// Returns a new Editor Instance
    ///
    func build() -> SPNoteEditorViewController {
        assert(restorationClass != nil)

        let controller = SPNoteEditorViewController()
        controller.restorationClass = restorationClass
        controller.restorationIdentifier = SPNoteEditorViewController.defaultRestorationIdentifier
        return controller
    }
}
