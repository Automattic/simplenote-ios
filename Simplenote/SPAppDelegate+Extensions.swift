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

    /// Opens search
    ///
    func presentSearch() {
        popToNoteList()

        UIView.performWithoutAnimation {
            // Switch from trash to all notes as trash doesn't have search
            if selectedTag == kSimplenoteTrashKey {
                selectedTag = nil
            }

            noteListViewController.startSearching()
        }
    }

    /// Opens editor with a new note
    ///
    func presentNewNoteEditor() {
        presentNote(nil)
    }

    /// Opens a note with specified simperium key
    ///
    func presentNoteWithSimperiumKey(_ simperiumKey: String) {
        guard let note = simperium.loadNote(simperiumKey: simperiumKey) else {
            return
        }

        presentNote(note)
    }

    /// Opens a note
    ///
    @objc
    func presentNote(_ note: Note?) {
        popToNoteList()

        noteListViewController.open(note, animated: false)
    }

    /// Dismisses all modals
    ///
    @objc(dismissAllModalsAnimated:completion:)
    func dismissAllModals(animated: Bool, completion: (() -> Void)?) {
        navigationController.dismiss(animated: animated, completion: completion)
    }

    private func popToNoteList() {
        dismissAllModals(animated: false, completion: nil)
        sidebarViewController.hideSidebar(withAnimation: false)

        if navigationController.viewControllers.contains(noteListViewController) {
            navigationController.popToViewController(noteListViewController, animated: false)
        }
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
        ShortcutsHandler.shared.updateHomeScreenQuickActionsIfNeeded()

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

        // Shortcuts!
        ShortcutsHandler.shared.clearHomeScreenQuickActions()
    }

    public func simperium(_ simperium: Simperium!, didFailWithError error: Error!) {
        SPTracker.refreshMetadataForAnonymousUser()
    }
}


// MARK: - Passcode
//
extension SPAppDelegate {
    /// Show passcode lock if passcode is enabled
    ///
    @objc
    func showPasscodeLockIfNecessary() {
        guard SPPinLockManager.shared.isEnabled, !isPresentingPasscodeLock else {
            return
        }

        let controller = PinLockVerifyController(delegate: self)
        let viewController = PinLockViewController(controller: controller)

        pinLockWindow = UIWindow(frame: UIScreen.main.bounds)
        pinLockWindow?.accessibilityViewIsModal = true
        pinLockWindow?.rootViewController = viewController
        pinLockWindow?.makeKeyAndVisible()
    }

    /// Dismiss the passcode lock window if the user has returned to the app before their preferred timeout length
    ///
    @objc
    func dismissPasscodeLockIfPossible() {
        guard pinLockWindow?.isKeyWindow == true, SPPinLockManager.shared.shouldBypassPinLock else {
            return
        }

        dismissPasscodeLock()
    }

    private func dismissPasscodeLock() {
        window.makeKeyAndVisible()
        pinLockWindow?.removeFromSuperview()
        pinLockWindow = nil
    }

    private var isPresentingPasscodeLock: Bool {
        return pinLockWindow?.isKeyWindow == true
    }
}


// MARK: - PinLockVerifyControllerDelegate
//
extension SPAppDelegate: PinLockVerifyControllerDelegate {
    func pinLockVerifyControllerDidComplete(_ controller: PinLockVerifyController) {
        UIView.animate(withDuration: UIKitConstants.animationShortDuration) {
            self.pinLockWindow?.alpha = 0.0
        } completion: { (_) in
            self.dismissPasscodeLock()
        }
    }
}
