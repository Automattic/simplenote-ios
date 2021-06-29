import Foundation


// MARK: - Initialization
//
extension SPAppDelegate {

    /// Simperium Initialization
    /// - Important: Buckets that don't have a backing `SPManagedObject` will be dynamic. Invoking `bucketForName` will initialize sync'ing!
    ///
    @objc
    func setupSimperium() {
        simperium = Simperium(model: coreDataManager.managedObjectModel, context: coreDataManager.managedObjectContext, coordinator: coreDataManager.persistentStoreCoordinator)

#if USE_VERBOSE_LOGGING
        simperium.verboseLoggingEnabled = true
        NSLog("[Simperium] Verbose logging Enabled")
#else
        simperium.verboseLoggingEnabled = false
#endif

        simperium.authenticationViewControllerClass    = SPOnboardingViewController.self
        simperium.authenticator.providerString         = "simplenote.com"

        simperium.authenticationShouldBeEmbeddedInNavigationController = true
        simperium.delegate = self

        for bucket in simperium.allBuckets {
            bucket.notifyWhileIndexing = true
            bucket.delegate = self
        }
    }
}


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

// MARK: - Initialization
//
extension SPAppDelegate {

    @objc
    func configureVersionsController() {
        versionsController = VersionsController(bucket: simperium.notesBucket)
    }

    @objc
    func configurePublishController() {
        publishController = PublishController()
        publishController.onUpdate = { (note) in
            PublishNoticePresenter.presentNotice(for: note)
        }
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

        navigationController.presentedViewController?.dismiss(animated: true, completion: nil)
        noteListViewController.open(note, ignoringSearchQuery: true, animated: true)

        return true
    }

    /// Opens search
    ///
    func presentSearch(animated: Bool = false) {
        popToNoteList(animated: animated)

        let block = {
            // Switch from trash to all notes as trash doesn't have search
            if self.selectedTag == kSimplenoteTrashKey {
                self.selectedTag = nil
            }

            self.noteListViewController.startSearching()
        }

        if animated {
            block()
        } else {
            UIView.performWithoutAnimation(block)
        }
    }

    /// Opens editor with a new note
    ///
    func presentNewNoteEditor(animated: Bool = false) {
        presentNote(nil, animated: animated)
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
    func presentNote(_ note: Note?, animated: Bool = false) {
        popToNoteList(animated: animated)

        noteListViewController.open(note, animated: animated)
    }

    /// Dismisses all modals
    ///
    @objc(dismissAllModalsAnimated:completion:)
    func dismissAllModals(animated: Bool, completion: (() -> Void)?) {
        navigationController.dismiss(animated: animated, completion: completion)
    }

    private func popToNoteList(animated: Bool = false) {
        dismissAllModals(animated: animated, completion: nil)
        sidebarViewController.hideSidebar(withAnimation: animated)

        if navigationController.viewControllers.contains(noteListViewController) {
            navigationController.popToViewController(noteListViewController, animated: animated)
        }
    }

    @objc
    func setupNoticeController() {
        NoticeController.shared.setupNoticeController()
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

    func viewController(restorationIdentifier: String, coder: NSCoder) -> UIViewController? {
        switch restorationIdentifier {
        case tagListViewController.restorationIdentifier:
            return tagListViewController

        case noteListViewController.restorationIdentifier:
            return noteListViewController

        case SPNoteEditorViewController.defaultRestorationIdentifier:
            guard let simperiumKey = coder.decodeObject(forKey: SPNoteEditorViewController.CodingKeys.currentNoteKey.rawValue) as? String,
                  let note = simperium.bucket(forName: Note.classNameWithoutNamespaces)?.object(forKey: simperiumKey) as? Note
            else {
                return nil
            }
            return EditorFactory.shared.build(with: note)

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

        return appDelegate.viewController(restorationIdentifier: restorationIdentifier, coder: coder)
    }
}


// MARK: - SimperiumDelegate
//
extension SPAppDelegate: SimperiumDelegate {

    public func simperiumDidLogin(_ simperium: Simperium) {
        guard let user = simperium.user else {
            fatalError()
        }

        // Store the Token: Required by the Share Extension!
        KeychainManager.extensionToken = user.authToken

        // Tracker!
        SPTracker.refreshMetadata(withEmail: user.email)

        // Shortcuts!
        ShortcutsHandler.shared.registerSimplenoteActivities()
        ShortcutsHandler.shared.updateHomeScreenQuickActionsIfNeeded()

        // Now that the user info is present, cache it for use by the crash logging system.
        let analyticsEnabled = simperium.preferencesObject()?.analytics_enabled?.boolValue ?? true
        CrashLoggingShim.cacheUser(user)
        CrashLoggingShim.cacheOptOutSetting(!analyticsEnabled)

        setupVerificationController()
    }

    public func simperiumDidLogout(_ simperium: Simperium) {
        // Nuke Extension Token
        KeychainManager.extensionToken = nil

        // Tracker!
        SPTracker.refreshMetadataForAnonymousUser()

        // Shortcuts!
        ShortcutsHandler.shared.clearHomeScreenQuickActions()

        destroyVerificationController()
    }

    public func simperium(_ simperium: Simperium, didFailWithError error: Error) {
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
            self.pinLockWindow?.alpha = UIKitConstants.alpha0_0
        } completion: { (_) in
            self.dismissPasscodeLock()
        }
    }
}

// MARK: - Account Verification
//
private extension SPAppDelegate {
    func setupVerificationController() {
        guard let email = simperium.user?.email, !email.isEmpty else {
            return
        }
        verificationController = AccountVerificationController(email: email)
        verificationController?.onStateChange = { [weak self] (oldState, state) in
            switch (oldState, state) {
            case (.unknown, .unverified):
                self?.showVerificationViewController(with: .review)
            case (.unknown, .verificationInProgress):
                self?.showVerificationViewController(with: .verify)
            case (.unverified, .verified), (.verificationInProgress, .verified):
                self?.dismissVerificationViewController()
            default:
                break
            }
        }
    }

    func destroyVerificationController() {
        verificationController = nil
    }

    func showVerificationViewController(with configuration: AccountVerificationViewController.Configuration) {
        guard let controller = verificationController, verificationViewController == nil else {
            return
        }

        let viewController = AccountVerificationViewController(configuration: configuration, controller: controller)
        verificationViewController = viewController

        viewController.presentFromRootViewController()
    }

    func dismissVerificationViewController() {
        verificationViewController?.dismiss(animated: true, completion: nil)
        verificationViewController = nil
    }
}


// MARK: - Magic Link authentication
//
extension SPAppDelegate {
    @objc
    func performMagicLinkAuthentication(with url: URL) {
        MagicLinkAuthenticator(authenticator: simperium.authenticator).handle(url: url)
    }
}


// MARK: - Scroll position cache
//
extension SPAppDelegate {
    @objc
    func cleanupScrollPositionCache() {
        let allNotes = SPObjectManager.shared().notes()
        let allIdentifiers: [String] = allNotes.compactMap { note in
            note.deleted ? nil : note.simperiumKey
        }
        EditorFactory.shared.scrollPositionCache.cleanup(keeping: allIdentifiers)
    }
}

// MARK: - Core Data
//
extension SPAppDelegate {
    @objc
    var managedObjectContext: NSManagedObjectContext {
        coreDataManager.managedObjectContext
    }
}
