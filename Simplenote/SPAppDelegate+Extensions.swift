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
        guard let note = simperium.loadNote(for: url) else {
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

    @objc
    public static func viewController(withRestorationIdentifierPath identifierComponents: [String], coder: NSCoder) -> UIViewController? {

        guard
            let appDelegate = UIApplication.shared.delegate as? SPAppDelegate,
            let component = identifierComponents.last
        else {
            return nil
        }

        switch component {
        case SPTagsListViewController.defaultRestorationIdentifier:
            return appDelegate.tagListViewController

        case SPNoteListViewController.defaultRestorationIdentifier:
            return appDelegate.noteListViewController

        case SPNoteEditorViewController.defaultRestorationIdentifier:
            // Yea! always a new instance (we're not keeping a reference to the active editor anymore)
            return SPNoteEditorViewController()

        case SPNavigationController.defaultRestorationIdentifier:
            return appDelegate.navigationController

        case SPSidebarContainerViewController.defaultRestorationIdentifier:
            return appDelegate.sidebarViewController

        default:
            return nil
        }
    }
}
