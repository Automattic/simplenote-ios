import Foundation
import WidgetKit

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

        simperium.authenticationViewControllerClass = SPOnboardingViewController.self
        simperium.authenticationShouldBeEmbeddedInNavigationController = true
        simperium.delegate = self

        for bucket in simperium.allBuckets {
            bucket.notifyWhileIndexing = true
            bucket.delegate = self
        }
    }

    @objc
    func setupAuthenticator() {
        let authenticator = simperium.authenticator

        authenticator.providerString = "simplenote.com"
    }

    @objc
    func setupStoreManager() {
        StoreManager.shared.initialize()
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

    @objc
    func configureAccountDeletionController() {
        accountDeletionController = AccountDeletionController()
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
        popToNoteList()
        noteListViewController.open(note, ignoringSearchQuery: true, animated: false)

        return true
    }

    /// Opens the Note list displaying a tag associated with a given URL instance, when possible
    ///
    @objc
    func handleOpenTagList(url: NSURL) -> Bool {
        guard url.isInternalTagURL else {
            return false
        }

        if let tag = url.internalTagKey {
            selectedTag = SPObjectManager.shared().tagExists(tag) ? tag : selectedTag
        } else {
            selectedTag = nil
        }

        popToNoteList()

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
    @objc
    func presentNewNoteEditor(useSelectedTag: Bool = true, animated: Bool = false) {
        performActionAfterUnlock {
            if useSelectedTag {
                self.presentNote(nil, animated: animated)
            } else {
                // If we use the standard new note option and a tag is selected then the tag is applied
                // in some cases, like shortcuts, we don't want it do apply the tag cause you can't see
                // what tag is selected when the shortcut runs
                let note = SPObjectManager.shared().newDefaultNote()
                self.presentNote(note, animated: true)
            }
        }
    }

    @objc
    func presentNewNoteEditor(animated: Bool = false) {
        presentNewNoteEditor(useSelectedTag: true, animated: animated)
    }

    var verifyController: PinLockVerifyController? {
        (pinLockWindow?.rootViewController as? PinLockViewController)?.controller as? PinLockVerifyController
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

    func performActionAfterUnlock(action: @escaping () -> Void) {
        if isPresentingPasscodeLock && SPPinLockManager.shared.isEnabled {
            verifyController?.addOnSuccesBlock {
                action()
            }
        } else {
            action()
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
        ShortcutsHandler.shared.updateHomeScreenQuickActionsIfNeeded()

        // Now that the user info is present, cache it for use by the crash logging system.
        let analyticsEnabled = simperium.preferencesObject().analytics_enabled?.boolValue ?? true
        CrashLoggingShim.shared.cacheUser(user)
        CrashLoggingShim.cacheOptOutSetting(!analyticsEnabled)

        syncWidgetDefaults()

        setupVerificationController()
    }

    public func simperiumDidLogout(_ simperium: Simperium) {
        // Nuke Extension Token
        KeychainManager.extensionToken = nil

        // Tracker!
        SPTracker.refreshMetadataForAnonymousUser()

        // Shortcuts!
        ShortcutsHandler.shared.clearHomeScreenQuickActions()

        syncWidgetDefaults()

        destroyVerificationController()
    }

    public func simperium(_ simperium: Simperium, didFailWithError error: Error) {
        SPTracker.refreshMetadataForAnonymousUser()

        guard let simperiumError = SPSimperiumErrors(rawValue: (error as NSError).code) else {
            return
        }

        switch simperiumError {
        case .invalidToken:
            logOutIfAccountDeletionRequested()
        default:
            break
        }
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
            verifyController?.removeSuccesBlocks()
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

// MARK: - Account Deletion
//
extension SPAppDelegate {
    @objc
    func authenticateSimperiumIfAccountDeletionRequested() {
        guard let deletionController = accountDeletionController,
              deletionController.hasValidDeletionRequest else {
            return
        }

        simperium.authenticateIfNecessary()
    }

    @objc
    func logOutIfAccountDeletionRequested() {
        guard accountDeletionController?.hasValidDeletionRequest == true else {
            return
        }

        logoutAndReset(self)
    }
}

// MARK: - Core Data
//
extension SPAppDelegate {
    @objc
    var managedObjectContext: NSManagedObjectContext {
        coreDataManager.managedObjectContext
    }

    @objc
    func setupStorage() {
        let migrationResult = SharedStorageMigrator().performMigrationIfNeeded()

        do {
            try setupCoreData(migrationResult: migrationResult)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    private func setupCoreData(migrationResult: MigrationResult) throws {
        let settings = StorageSettings()

        switch migrationResult {
        case .notNeeded, .success:
            coreDataManager = try CoreDataManager(settings.sharedStorageURL)
        case .failed:
            coreDataManager = try CoreDataManager(settings.legacyStorageURL)
        }
    }
}

// MARK: - Widgets
extension SPAppDelegate {
    @objc
    func resetWidgetTimelines() {
        WidgetController.resetWidgetTimelines()
    }

    @objc
    func syncWidgetDefaults() {
        let authenticated = simperium.user?.authenticated() ?? false
        let sortMode = Options.shared.listSortMode
        WidgetController.syncWidgetDefaults(authenticated: authenticated, sortMode: sortMode)
    }
}

// MARK: - Sustainer migration
extension SPAppDelegate {
    @objc
    func migrateSimperiumPreferencesIfNeeded() {
        guard UserDefaults.standard.bool(forKey: .hasMigratedSustainerPreferences) == false else {
            return
        }

        guard isFirstLaunch() == false else {
            UserDefaults.standard.set(true, forKey: .hasMigratedSustainerPreferences)
            return
        }

        NSLog("Migrating Simperium Preferences object to include was_sustainer value")
        UserDefaults.standard.removeObject(forKey: Simperium.preferencesLastChangedSignatureKey)
        let prefs = simperium.preferencesObject()
        prefs.ghostData = ""
        simperium.saveWithoutSyncing()

        UserDefaults.standard.set(true, forKey: .hasMigratedSustainerPreferences)
    }
}

// MARK: - Content Recovery
//
extension SPAppDelegate {
    @objc
    func attemptContentRecoveryIfNeeded() {
        RecoveryUnarchiver().insertNotesFromRecoveryFilesIfNeeded()
    }
}
