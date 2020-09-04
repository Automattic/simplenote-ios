import Foundation


// MARK: - Internal Methods
//
extension SPAppDelegate {

    /// Returns the actual Selected Tag Name **Excluding** navigation tags, such as Trash or Untagged Notes.
    ///
    /// TODO: This should be gone... **the second** the AppDelegate is Swift-y. We should simply keep a `NoteListFilter` instance.
    ///
    @objc
    var filteredTagName: String? {
        guard let selectedTag = SPAppDelegate.shared().selectedTag,
            case let .tag(name) = NotesListFilter(selectedTag: selectedTag) else {
                return nil
        }

        return name
    }

    /// Returns the visible EditorViewController (when applicable!)
    ///
    @objc
    var noteEditorViewController: SPNoteEditorViewController? {
        navigationController.firstChild(ofType: SPNoteEditorViewController.self)
    }
}


// MARK: - URL Handlers
//
extension SPAppDelegate {

    /// Opens the Note associated with a given URL instance, when possible
    ///
    @objc
    func handleOpenNote(url: NSURL) -> Bool {
        guard let simperiumKey = url.interlinkSimperiumKey, let note = simperium.loadNote(simperiumKey: simperiumKey) else {
            return false
        }

        let editorViewController = SPNoteEditorViewController()
        editorViewController.display(note)
        replaceNoteEditor(editorViewController)

        return true
    }

    func replaceNoteEditor(_ editorViewController: SPNoteEditorViewController) {
        navigationController.setViewControllers([noteListViewController, editorViewController], animated: true)
    }
}


// MARK: - UIViewControllerRestoration
//
@objc
extension SPAppDelegate: UIViewControllerRestoration {

    @objc
    func configureStateRestoration() {
        tagListViewController.restorationIdentifier = SPTagsListViewController.defaultRestorationIdentifier
        tagListViewController.restorationClass = SPAppDelegate.self

        noteListViewController.restorationIdentifier = SPNoteListViewController.defaultRestorationIdentifier
        noteListViewController.restorationClass = SPAppDelegate.self

        navigationController.restorationIdentifier = SPNavigationController.defaultRestorationIdentifier
        navigationController.restorationClass = SPAppDelegate.self

        sidebarViewController.restorationIdentifier = SPSidebarContainerViewController.defaultRestorationIdentifier
        sidebarViewController.restorationClass = SPAppDelegate.self
    }

    func viewController(restorationIdentifier: String) -> UIViewController? {
        switch restorationIdentifier {
        case tagListViewController.restorationIdentifier:
            return tagListViewController

        case noteListViewController.restorationIdentifier:
            return noteListViewController

        case SPNoteEditorViewController.defaultRestorationIdentifier:
            // Yea! always a new instance (we're not keeping a reference to the active editor anymore)
            return SPNoteEditorViewController()

        case navigationController.restorationIdentifier:
            return navigationController

        case sidebarViewController.restorationIdentifier:
            return sidebarViewController

        default:
            return nil
        }
    }

    @objc
    public static func viewController(withRestorationIdentifierPath identifierComponents: [String], coder: NSCoder) -> UIViewController? {
        guard
            let appDelegate = UIApplication.shared.delegate as? SPAppDelegate,
            let restorationIdentifier = identifierComponents.last
        else {
            return nil
        }

        return appDelegate.viewController(restorationIdentifier: restorationIdentifier)
    }
}
