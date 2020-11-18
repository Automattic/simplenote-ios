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

    /// This API drops (whatever) Editor Instance you may have, and pushes the List + Editor into the NavigationController's Stack
    ///
    /// - Note: This is used for Interlinking Navigation. Long Press over the Editor (or Markdown Preview) is expected to perform a *push* animation.
    ///         In both scenarios, there's already an Editor onScreen, and the standard SDK behavior is to "pop".
    ///
    /// - Note: Furthermore, when pressing an Interlink from the Editor, the "Link Text Interaction" injects a floating view, so that the link appears to "float".
    ///         Refreshing the Editor's contents right there (with any kind of animation) ends up interacting with this "Floating Link" behavior.
    ///         For such reason, we're opting for simply pushing another VC.
    ///
    private func replaceNoteEditor(_ editorViewController: SPNoteEditorViewController) {
        navigationController.presentedViewController?.dismiss(animated: true, completion: nil)
        navigationController.setViewControllers([noteListViewController, editorViewController], animated: true)
    }

    @objc
    func updateHomeScreenQuickActions() {
        let note = SPObjectManager.shared().recentlyModifiedNote
        ShortcutsHandler.shared.updateHomeScreenQuickActions(with: note)
    }
}

// MARK: - Initialization
//
extension SPAppDelegate {

    @objc
    func configureVersionsController() {
        versionsController = VersionsController(bucket: simperium.notesBucket)
    }
}

// MARK: - URL Handlers and Deep Linking
//
extension SPAppDelegate {

    /// Opens the Note associated with a given URL instance, when possible
    ///
    @objc
    func handleOpenNote(url: NSURL) -> Bool {
        guard let simperiumKey = url.interlinkSimperiumKey, let note = simperium.loadNote(simperiumKey: simperiumKey) else {
            return false
        }

        let editorViewController = EditorFactory.shared.build()
        editorViewController.display(note)
        replaceNoteEditor(editorViewController)

        return true
    }

    func presentSearch() {
        dismissAllModals(animated: false, completion: nil)
        sidebarViewController.hideSidebar(withAnimation: false)
        if navigationController.viewControllers.contains(noteListViewController) {
            navigationController.popToViewController(noteListViewController, animated: false)
        }

        DispatchQueue.main.async {
            self.noteListViewController.startSearching()
        }
    }

    @objc(dismissAllModalsAnimated:completion:)
    func dismissAllModals(animated: Bool, completion: (() -> Void)?) {
        navigationController.dismiss(animated: animated, completion: completion)
    }
}


// MARK: - UIViewControllerRestoration
//
@objc
extension SPAppDelegate: UIViewControllerRestoration {

    @objc
    func configureStateRestoration() {
        EditorFactory.shared.restorationClass = SPAppDelegate.self

        tagListViewController.restorationIdentifier = TagListViewController.defaultRestorationIdentifier
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
            return EditorFactory.shared.build()

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


// MARK: - Pin Lock
//
// TODO: Let's move these API(s) over to PinLockManager!
//
extension SPAppDelegate {

    @objc
    func getPin() -> String? {
        KeychainManager.pinlock
    }

    @objc
    func setPin(_ pin: String) {
        KeychainManager.pinlock = pin
    }

    @objc
    func removePin() {
        KeychainManager.pinlock = nil
        allowBiometryInsteadOfPin = false
    }
}


// MARK: - SimperiumDelegate
//
extension SPAppDelegate: SimperiumDelegate {

    public func simperiumDidLogin(_ simperium: Simperium!) {
        // Store the Token: Required by the Share Extension!
        if let token = simperium.user.authToken {
            KeychainManager.extensionToken = token
        }

        // Tracker!
        SPTracker.refreshMetadata(withEmail: simperium.user.email)

        // Shortcuts!
        ShortcutsHandler.shared.registerSimplenoteActivities()

        // Now that the user info is present, cache it for use by the crash logging system.
        let analyticsEnabled = simperium.preferencesObject()?.analytics_enabled?.boolValue ?? true
        CrashLoggingShim.cacheUser(simperium.user)
        CrashLoggingShim.cacheOptOutSetting(!analyticsEnabled)
    }

    public func simperiumDidLogout(_ simperium: Simperium!) {
        // Nuke Extension Token
        KeychainManager.extensionToken = nil

        // Tracker!
        SPTracker.refreshMetadataForAnonymousUser()
    }

    public func simperium(_ simperium: Simperium!, didFailWithError error: Error!) {
        SPTracker.refreshMetadataForAnonymousUser()
    }
}
