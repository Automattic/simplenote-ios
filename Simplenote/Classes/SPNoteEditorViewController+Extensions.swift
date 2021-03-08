import Foundation
import CoreSpotlight


// MARK: - Overridden Methods
//
extension SPNoteEditorViewController {

    /// Whenever this instance is removed from its NavigationController, let's cleanup
    ///
    override public func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)

        guard parent == nil, self.parent != nil else {
            return
        }

        ensureEmptyNoteIsDeleted()
    }

    /// Whenever a ViewController is presented, let's ensure Interlink is dismissed!
    ///
    override public func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        super.present(viewControllerToPresent, animated: flag, completion: completion)
        interlinkProcessor.dismissInterlinkLookup()
    }
}


// MARK: - Interface Initialization
//
extension SPNoteEditorViewController {

    /// Sets up the NavigationBar Items
    ///
    @objc
    func configureNavigationBarItems() {
        actionButton = UIBarButtonItem(image: .image(name: .ellipsisOutlined), style: .plain, target: self, action: #selector(noteOptionsWasPressed(_:)))
        actionButton.accessibilityIdentifier = "note-menu"
        actionButton.accessibilityLabel = NSLocalizedString("Menu", comment: "Note Options Button")

        checklistButton = UIBarButtonItem(image: .image(name: .checklist), style: .plain, target: self, action: #selector(insertChecklistAction(_:)))
        checklistButton.accessibilityLabel = NSLocalizedString("Inserts a new Checklist Item", comment: "Insert Checklist Button")

        informationButton = UIBarButtonItem(image: .image(name: .info), style: .plain, target: self, action: #selector(noteInformationWasPressed(_:)))
        informationButton.accessibilityLabel = NSLocalizedString("Information", comment: "Note Information Button (metrics + references)")

        createNoteButton = UIBarButtonItem(image: .image(name: .newNote), style: .plain, target: self, action: #selector(handleTapOnCreateNewNoteButton))
        createNoteButton.accessibilityLabel = NSLocalizedString("New note", comment: "Label to create a new note")

        keyboardButton = UIBarButtonItem(image: .image(name: .hideKeyboard), style: .plain, target: self, action: #selector(keyboardButtonAction(_:)))
        keyboardButton.accessibilityLabel = NSLocalizedString("Dismiss keyboard", comment: "Dismiss Keyboard Button")
    }

    /// Sets up the Root ViewController
    ///
    @objc
    func configureRootView() {
        view.addSubview(noteEditorTextView)
        view.addSubview(navigationBarBackground)
    }

    /// Sets up the Layout
    ///
    @objc
    func configureLayout() {
        navigationBarBackground.translatesAutoresizingMaskIntoConstraints = false
        noteEditorTextView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            navigationBarBackground.topAnchor.constraint(equalTo: view.topAnchor),
            navigationBarBackground.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBarBackground.leftAnchor.constraint(equalTo: view.leftAnchor),
            navigationBarBackground.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])

        NSLayoutConstraint.activate([
            noteEditorTextView.topAnchor.constraint(equalTo: view.topAnchor),
            noteEditorTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            noteEditorTextView.leftAnchor.constraint(equalTo: view.leftAnchor),
            noteEditorTextView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }

    /// Sets up the Interlinks Processor
    ///
    @objc
    func configureInterlinksProcessor() {
        interlinkProcessor = InterlinkProcessor(viewContext: SPAppDelegate.shared().managedObjectContext,
                                                popoverPresenter: popoverPresenter,
                                                parentTextView: noteEditorTextView,
                                                excludedEntityID: note.objectID)
        interlinkProcessor.delegate = self
    }

    /// Sets up the Keyboard
    ///
    @objc
    func configureTextViewKeyboard() {
        noteEditorTextView.keyboardDismissMode = .interactive
    }

    /// Sets up text view observers
    ///
    @objc
    func configureTextViewObservers() {
        noteEditorTextView.onContentPositionChange = { [weak self] in
            self?.updateTagListPosition()
        }
    }

    private var popoverPresenter: PopoverPresenter {
        let viewportProvider = { [weak self] () -> CGRect in
            self?.noteEditorTextView.editingRectInWindow() ?? .zero
        }

        return PopoverPresenter(containerViewController: self,
                                viewportProvider: viewportProvider,
                                siblingView: navigationBarBackground)
    }
}


// MARK: - Layout
//
extension SPNoteEditorViewController {
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // We need to reset transform to prevent tagView from loosing `safeArea`
        // We restore transform back in viewDidLayoutSubviews
        tagView.transform = .identity
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Adding async here to break a strange layout loop
        // It happens when add tag field is first responder and device is rotated
        DispatchQueue.main.async {
            self.updateTagListPosition()
        }
    }
}

// MARK: - Notifications
//
extension SPNoteEditorViewController {
    @objc
    func startListeningToNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(dismissEditor(_:)),
                                               name: NSNotification.Name(rawValue: SPTransitionControllerPopGestureTriggeredNotificationName),
                                               object: nil)

        // voiceover status is tracked because the tag view is anchored
        // to the bottom of the screen when voiceover is enabled to allow
        // easier access
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshVoiceOverSupport),
                                               name: UIAccessibility.voiceOverStatusDidChangeNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAppDidEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }

    @objc
    private func handleAppDidEnterBackground() {
        saveScrollPosition()
    }
}

// MARK: - Keyboard Handling
//
extension SPNoteEditorViewController: KeyboardObservable {

    @objc
    func startListeningToKeyboardNotifications() {
        keyboardNotificationTokens = addKeyboardObservers()
    }

    @objc
    func stopListeningToKeyboardNotifications() {
        guard let tokens = keyboardNotificationTokens else {
            return
        }

        removeKeyboardObservers(with: tokens)
        keyboardNotificationTokens = nil
    }

    public func keyboardWillChangeFrame(beginFrame: CGRect?, endFrame: CGRect?, animationDuration: TimeInterval?, animationCurve: UInt?) {
        guard let _ = view.window, let endFrame = endFrame, let duration = animationDuration, let curve = animationCurve else {
            return
        }

        updateBottomInsets(keyboardFrame: endFrame, duration: duration, curve: curve)
    }

    public func keyboardDidChangeFrame(beginFrame: CGRect?, endFrame: CGRect?, animationDuration: TimeInterval?, animationCurve: UInt?) {
        guard let _ = view.window, let endFrame = endFrame, let duration = animationDuration, let curve = animationCurve else {
            return
        }

        updateBottomInsets(keyboardFrame: endFrame, duration: duration, curve: curve)
    }

    /// Updates the Editor's Bottom Insets
    ///
    /// - Note: Floating Keyboard results in `contentInset.bottom = .zero`
    /// - Note: When the keyboard is visible, we'll substract the `safeAreaInsets.bottom`, since the TextView already considers that gap.
    /// - Note: We're explicitly turning on / off `enableScrollSmoothening`, since it's proven to be a nightmare when UIAutoscroll is involved.
    ///
    private func updateBottomInsets(keyboardFrame: CGRect, duration: TimeInterval, curve: UInt) {
        let newKeyboardHeight       = keyboardFrame.intersection(noteEditorTextView.frame).height
        let newKeyboardFloats       = keyboardFrame.maxY < view.frame.height
        let newKeyboardIsVisible    = newKeyboardHeight != .zero
        let animationOptions        = UIView.AnimationOptions(arrayLiteral: .beginFromCurrentState, .init(rawValue: curve))
        let editorBottomInsets      = newKeyboardFloats ? .zero : newKeyboardHeight
        let adjustedBottomInsets    = max(editorBottomInsets - view.safeAreaInsets.bottom, .zero)

        guard noteEditorTextView.contentInset.bottom != adjustedBottomInsets else {
            return
        }

        defer {
            isKeyboardVisible = newKeyboardIsVisible
        }

        self.noteEditorTextView.enableScrollSmoothening = true

        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: .zero, options: animationOptions, animations: {
            self.noteEditorTextView.contentInset.bottom = adjustedBottomInsets
            self.noteEditorTextView.scrollIndicatorInsets.bottom = adjustedBottomInsets
            self.tagListBottomConstraint.constant = -editorBottomInsets
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.noteEditorTextView.enableScrollSmoothening = false
        })
    }
}


// MARK: - Voiceover Support
//
extension SPNoteEditorViewController {

    /// Indicates if VoiceOver is running
    ///
    private var isVoiceOverEnabled: Bool {
        UIAccessibility.isVoiceOverRunning
    }

    /// Whenver VoiceOver is enabled, this API will lock the Tags List in position
    ///
    @objc
    private func refreshVoiceOverSupport() {
        updateTagListPosition()
    }

    /// Sets behavior for accessibility three finger scroll
    ///
    open override func accessibilityScroll(_ direction: UIAccessibilityScrollDirection) -> Bool {
        switch direction {
        case .left:
            presentMarkdownPreview()
        case .right:
            navigationController?.popViewController(animated: true)
        default:
            // With VoiceOver on, three finger scroll up and down will cause a page up/page down action
            // If this method returns true that is disabled.  Returning false to maintain page up/page down
            return false
        }

        return true
    }
}


// MARK: - State Restoration
//
extension SPNoteEditorViewController {

    /// NSCoder Keys
    ///
    enum CodingKeys: String {
        case currentNoteKey
    }

    private var simperium: Simperium {
        SPAppDelegate.shared().simperium
    }

    open override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)

        // Always make sure the object is persisted before proceeding
        if note.objectID.isTemporaryID {
            simperium.save()
        }

        coder.encode(note.simperiumKey, forKey: CodingKeys.currentNoteKey.rawValue)
    }
}


// MARK: - History
//
extension SPNoteEditorViewController {

    /// Indicates if note history is shown on screen
    ///
    @objc
    var isShowingHistory: Bool {
        return historyViewController != nil
    }

    /// Shows note history
    ///
    @objc
    func presentHistoryController() {
        ensureSearchIsDismissed()
        save()

        dimLinksInEditor()

        let viewController = SPNoteHistoryViewController(note: note, delegate: self)
        viewController.configureToPresentAsCard(presentationDelegate: self)
        historyViewController = viewController

        present(viewController, animated: true)

        SPTracker.trackEditorVersionsAccessed()
    }

    /// Dismiss note history
    ///
    @objc(dismissHistoryControllerAnimated:)
    func dismissHistoryController(animated: Bool) {
        guard let viewController = historyViewController else {
            return
        }

        cleanUpAfterHistoryDismissal()
        viewController.dismiss(animated: animated, completion: nil)

        resetAccessibilityFocus()
    }

    private func cleanUpAfterHistoryDismissal() {
        restoreDefaultLinksDimmingInEditor()
        historyViewController = nil
    }
}


// MARK: - History Delegate
//
extension SPNoteEditorViewController: SPNoteHistoryControllerDelegate {

    func noteHistoryControllerDidCancel() {
        dismissHistoryController(animated: true)
        restoreOriginalNoteContent()
    }

    func noteHistoryControllerDidFinish() {
        dismissHistoryController(animated: true)
        modified = true
        save()
    }

    func noteHistoryControllerDidSelectVersion(withContent content: String) {
        updateEditor(with: content)
    }
}


// MARK: - SPCardPresentationControllerDelegate
//
extension SPNoteEditorViewController: SPCardPresentationControllerDelegate {

    func cardDidDismiss(_ viewController: UIViewController, reason: SPCardDismissalReason) {
        cleanUpAfterHistoryDismissal()
        restoreOriginalNoteContent()
    }
}

// MARK: - Information
//
extension SPNoteEditorViewController {

    /// Present information controller
    /// - Parameters:
    ///     - note: Note
    ///     - barButtonItem: Bar button item to be used as a popover target
    ///
    @objc
    func presentInformationController(for note: Note, from barButtonItem: UIBarButtonItem) {
        let informationViewController = NoteInformationViewController(note: note)

        let presentAsPopover = UIDevice.sp_isPad() && traitCollection.horizontalSizeClass == .regular

        if presentAsPopover {
            let navigationController = SPNavigationController(rootViewController: informationViewController)
            navigationController.configureAsPopover(barButtonItem: barButtonItem)
            navigationController.displaysBlurEffect = true
            self.informationViewController = navigationController
            present(navigationController, animated: true, completion: nil)
        } else {
            dimLinksInEditor()

            informationViewController.configureToPresentAsCard(onDismissCallback: { [weak self] in
                self?.restoreDefaultLinksDimmingInEditor()
            })
            self.informationViewController = informationViewController
            present(informationViewController, animated: true, completion: nil)
        }
    }

    /// Dismiss and present information controller.
    /// Called when horizontal size class changes
    ///
    @objc
    func updateInformationControllerPresentation() {
        guard let informationViewController = informationViewController else {
            return
        }

        restoreDefaultLinksDimmingInEditor()
        informationViewController.dismiss(animated: false) { [weak self] in
            guard let self = self else {
                return
            }
            self.presentInformationController(for: self.note, from: self.informationButton)
        }
    }
}

// MARK: - Private API(s)
//
private extension SPNoteEditorViewController {

    func dismissKeyboardAndSave() {
        endEditing()
        save()
    }

    func mustBounceMarkdownPreview(note: Note, oldMarkdownState: Bool) -> Bool {
        note.markdown && oldMarkdownState != note.markdown
    }

    func bounceMarkdownPreviewIfNeeded(note: Note, oldMarkdownState: Bool) {
        guard mustBounceMarkdownPreview(note: note, oldMarkdownState: oldMarkdownState) else {
            return
        }

        bounceMarkdownPreview()
    }

    func presentOptionsController(for note: Note, from barButtonItem: UIBarButtonItem) {
        let optionsViewController = OptionsViewController(note: note)
        optionsViewController.delegate = self

        let navigationController = SPNavigationController(rootViewController: optionsViewController)
        navigationController.configureAsPopover(barButtonItem: barButtonItem)
        navigationController.displaysBlurEffect = true

        let oldMarkdownState = note.markdown
        navigationController.onWillDismiss = { [weak self] in
            self?.bounceMarkdownPreviewIfNeeded(note: note, oldMarkdownState: oldMarkdownState)
        }

        dismissKeyboardAndSave()
        present(navigationController, animated: true, completion: nil)

        SPTracker.trackEditorActivitiesAccessed()
    }

    func presentShareController(for note: Note, from barButtonItem: UIBarButtonItem) {
        guard let activityController = UIActivityViewController(note: note) else {
            return
        }

        activityController.configureAsPopover(barButtonItem: barButtonItem)

        present(activityController, animated: true, completion: nil)
        SPTracker.trackEditorNoteContentShared()

    }

    func presentMarkdownPreview() {
        guard navigationController?.topViewController == self else {
            return
        }

        let previewViewController = SPMarkdownPreviewViewController()
        previewViewController.markdownText = noteEditorTextView.plainText
        navigationController?.pushViewController(previewViewController, animated: true)
    }
}



// MARK: - Services
//
extension SPNoteEditorViewController {

    func delete(note: Note) {
        SPTracker.trackEditorNoteDeleted()
        SPObjectManager.shared().trashNote(note)
        CSSearchableIndex.default().deleteSearchableNote(note)
    }

    @objc
    func ensureEmptyNoteIsDeleted() {
        guard note.isBlank, noteEditorTextView.text.isEmpty else {
            save()
            return
        }

        SPObjectManager.shared().trashNote(note)
    }

    @objc
    private func handleTapOnCreateNewNoteButton() {
        saveIfNeeded()

        if note.isBlank {
            noteEditorTextView.becomeFirstResponder()
            return
        }

        SPTracker.trackEditorNoteCreated()

        presentNewNoteReplacingCurrentEditor()
    }

    private func presentNewNoteReplacingCurrentEditor() {
        guard let navigationController = navigationController,
              let snapshotView = createAndAddEditorSnapshotView() else {
            return
        }

        let viewControllers: [UIViewController] = navigationController.viewControllers.map {
            if $0 == self {
                return EditorFactory.shared.build(with: nil)
            }
            return $0
        }

        navigationController.setViewControllers(viewControllers, animated: false)

        UIView.animate(withDuration: 0.2) {
            snapshotView.transform = .init(translationX: 0, y: snapshotView.frame.height)
        } completion: { (_) in
            snapshotView.removeFromSuperview()
        }
    }

    private func createAndAddEditorSnapshotView() -> UIView? {
        let snapshotRect = CGRect(x: 0,
                                  y: noteEditorTextView.adjustedContentInset.top,
                                  width: noteEditorTextView.frame.width,
                                  height: noteEditorTextView.frame.height - noteEditorTextView.adjustedContentInset.top)

        guard let snapshotView = view.resizableSnapshotView(from: snapshotRect, afterScreenUpdates: false, withCapInsets: .zero),
              let navigationController = navigationController else {
            return nil
        }

        snapshotView.frame.origin.y = snapshotRect.origin.y
        navigationController.view.addSubview(snapshotView)

        return snapshotView
    }
}


// MARK: - Editor
//
private extension SPNoteEditorViewController {

    // TODO: Think if we can use it from 'newButtonAction' as well (the animation effect is different)
    func updateEditor(with content: String, animated: Bool = true) {
        let contentUpdateBlock = {
            self.noteEditorTextView.attributedText = NSAttributedString(string: content)
            self.noteEditorTextView.processChecklists()
        }

        guard animated, let snapshot = noteEditorTextView.snapshotView(afterScreenUpdates: false) else {
            contentUpdateBlock()
            return
        }

        snapshot.frame = noteEditorTextView.frame
        view.insertSubview(snapshot, aboveSubview: noteEditorTextView)

        contentUpdateBlock()

        let animations = {
            snapshot.alpha = .zero
        }

        let completion: (Bool) -> Void = { _ in
            snapshot.removeFromSuperview()
        }

        UIView.animate(withDuration: UIKitConstants.animationShortDuration,
                       animations: animations,
                       completion: completion)
    }

    func restoreOriginalNoteContent() {
        updateEditor(with: note.content)
    }

    func dimLinksInEditor() {
        noteEditorTextView.tintAdjustmentMode = .dimmed
    }

    func restoreDefaultLinksDimmingInEditor() {
        noteEditorTextView.tintAdjustmentMode = .automatic
    }
}


// MARK: - OptionsControllerDelegate
//
extension SPNoteEditorViewController: OptionsControllerDelegate {

    func optionsControllerDidPressShare(_ sender: OptionsViewController) {
        sender.dismiss(animated: true, completion: nil)

        // Wait a bit until the Dismiss Animation concludes. `dismiss(:completion)` takes too long!
        DispatchQueue.main.asyncAfter(deadline: .now() + UIKitConstants.animationDelayShort) {
            self.presentShareController(for: sender.note, from: self.actionButton)
        }
    }

    func optionsControllerDidPressHistory(_ sender: OptionsViewController) {
        sender.dismiss(animated: true, completion: nil)

        // Wait a bit until the Dismiss Animation concludes. `dismiss(:completion)` takes too long!
        DispatchQueue.main.asyncAfter(deadline: .now() + UIKitConstants.animationDelayShort) {
            self.presentHistoryController()
        }
    }

    func optionsControllerDidPressTrash(_ sender: OptionsViewController) {
        sender.dismiss(animated: true, completion: nil)

        // Wait a bit until the Dismiss Animation concludes. `dismiss(:completion)` takes too long!
        DispatchQueue.main.asyncAfter(deadline: .now() + UIKitConstants.animationDelayShort) {
            self.delete(note: sender.note)
            self.dismissEditor(sender)
        }
    }
}


// MARK: - Accessibility
//
private extension SPNoteEditorViewController {

    func resetAccessibilityFocus() {
        UIAccessibility.post(notification: .layoutChanged, argument: nil)
    }
}


// MARK: - Actions
//
extension SPNoteEditorViewController {

    @IBAction
    func noteOptionsWasPressed(_ sender: UIBarButtonItem) {
        presentOptionsController(for: note, from: sender)
    }

    @objc
    private func noteInformationWasPressed(_ sender: UIBarButtonItem) {
        presentInformationController(for: note, from: sender)
    }
}

// MARK: - Searching
//
extension SPNoteEditorViewController {

    /// Returns ranges of keywords in a given text
    ///
    @objc
    func searchResultRanges(in text: String, withKeywords keywords: [String]) -> [NSRange] {
        return text.contentSlice(matching: keywords)?.nsMatches ?? []
    }
}

// MARK: - Interlinks
//
extension SPNoteEditorViewController {

    /// Dismisses (if needed) and reprocessess Interlink Lookup whenever the current Transition concludes
    ///
    @objc(refreshInterlinkLookupWithCoordinator:)
    func refreshInterlinkLookupWithCoordinator(coordinator: UIViewControllerTransitionCoordinator) {
        interlinkProcessor.dismissInterlinkLookup()

        coordinator.animate(alongsideTransition: nil) { _ in
            self.interlinkProcessor.processInterlinkLookup()
        }
    }
}


// MARK: - InterlinkProcessorDelegate
//
extension SPNoteEditorViewController: InterlinkProcessorDelegate {
    func interlinkProcessor(_ processor: InterlinkProcessor, insert text: String, in range: Range<String.Index>) {
        noteEditorTextView.insertText(text: text, in: range)
        processor.dismissInterlinkLookup()
    }
}


// MARK: - Tags
//
extension SPNoteEditorViewController {
    @objc
    func configureTagListViewController() {
        let popoverPresenter = self.popoverPresenter
        popoverPresenter.dismissOnInteractionWithPassthruView = true
        tagListViewController = NoteEditorTagListViewController(note: note, popoverPresenter: popoverPresenter)

        addChild(tagListViewController)
        
        tagView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tagView)

        NSLayoutConstraint.activate([
            tagView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tagView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        tagListBottomConstraint = tagView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        tagListBottomConstraint.isActive = true

        tagListViewController.didMove(toParent: self)

        tagListViewController.delegate = self
    }

    private func updateTagListPosition() {
        guard !isVoiceOverEnabled else {
            tagView.transform = .identity
            return
        }

        let contentHeight = noteEditorTextView.contentSize.height - noteEditorTextView.textContainerInset.bottom + Metrics.additionalTagViewAndEditorCollisionDistance
        let maxContentY = noteEditorTextView.convert(CGPoint(x: 0, y: contentHeight), to: view).y

        let tagViewY = tagView.frame.origin.y - tagView.transform.ty
        let translationY = max(maxContentY - tagViewY, 0)

        if tagView.transform.ty != translationY {
            tagView.transform = .init(translationX: 0, y: translationY)
        }
    }

    private var tagView: UIView {
        return tagListViewController.view
    }
}


// MARK: - NoteEditorTagListViewControllerDelegate
//
extension SPNoteEditorViewController: NoteEditorTagListViewControllerDelegate {
    func tagListDidUpdate(_ tagList: NoteEditorTagListViewController) {
        modified = true
        save()
    }

    func tagListIsEditing(_ tagList: NoteEditorTagListViewController) {
        // Note: When Voiceover is enabled, the Tags Editor is docked!
        guard !isVoiceOverEnabled else {
            return
        }

        // Without async it doesn't work due to race condition with keyboard frame changes
        DispatchQueue.main.async {
            self.noteEditorTextView.scrollToBottom(withAnimation: true)
        }
    }
}


// MARK: - Style
//
extension SPNoteEditorViewController {

    @objc
    func refreshStyle() {
        refreshRootView()
        refreshTagsEditor()
        refreshTextEditor()
        refreshTextStorage()
    }

    private func refreshRootView() {
        view.backgroundColor = backgroundColor
    }

    private func refreshTextEditor() {
        noteEditorTextView.backgroundColor = backgroundColor
        noteEditorTextView.keyboardAppearance = .simplenoteKeyboardAppearance
        noteEditorTextView.checklistsFont = .preferredFont(forTextStyle: .headline)
        noteEditorTextView.checklistsTintColor = .simplenoteNoteBodyPreviewColor
    }

    private func refreshTagsEditor() {
        tagView.backgroundColor = backgroundColor
    }

    private func refreshTextStorage() {
        let headlineFont = UIFont.preferredFont(for: .title1, weight: .bold)
        let defaultFont = UIFont.preferredFont(forTextStyle: .body)
        let textColor = UIColor.simplenoteNoteHeadlineColor
        let lineSpacing = defaultFont.lineHeight * Metrics.lineSpacingMultipler
        let textStorage = noteEditorTextView.interactiveTextStorage

        textStorage.defaultStyle = [
            .font: defaultFont,
            .foregroundColor: textColor,
            .paragraphStyle: NSMutableParagraphStyle(lineSpacing: lineSpacing)
        ]

        textStorage.headlineStyle = [
            .font: headlineFont,
            .foregroundColor: textColor,
        ]
    }

    private var backgroundColor: UIColor {
        isPreviewing ? .simplenoteBackgroundPreviewColor : .simplenoteBackgroundColor
    }
}

// MARK: - Search Map
//
extension SPNoteEditorViewController {

    /// Show search map keyword ranges
    ///
    // TODO: Use `Range` when `SPNoteEditorViewController` is fully swift
    @objc
    func showSearchMap(with searchRangeValues: [NSValue]) {
        createSearchMapViewIfNeeded()
        searchMapView?.update(with: searchBarPositions(with: searchRangeValues))
    }

    /// Returns position relative to the total text container height.
    /// Position value is from 0 to 1
    ///
    private func searchBarPositions(with searchRangeValues: [NSValue]) -> [CGFloat] {
        let textContainerHeight = textContainerHeightForSearchMap()
        guard textContainerHeight > CGFloat.leastNormalMagnitude else {
            return []
        }

        return searchRangeValues.map {
            let boundingRect = noteEditorTextView.boundingRect(for: $0.rangeValue)
            return max(boundingRect.midY / textContainerHeight, CGFloat.leastNormalMagnitude)
        }
    }

    private func textContainerHeightForSearchMap() -> CGFloat {
        var textContainerHeight = noteEditorTextView.layoutManager.usedRect(for: noteEditorTextView.textContainer).size.height
        textContainerHeight = textContainerHeight + noteEditorTextView.textContainerInset.top + noteEditorTextView.textContainerInset.bottom

        let textContainerMinHeight = noteEditorTextView.editingRectInWindow().size.height
        return max(textContainerHeight, textContainerMinHeight)
    }

    private func createSearchMapViewIfNeeded() {
        guard searchMapView == nil else {
            return
        }

        let searchMapView = SearchMapView()

        view.addSubview(searchMapView)
        NSLayoutConstraint.activate([
            searchMapView.topAnchor.constraint(equalTo: noteEditorTextView.topAnchor, constant: noteEditorTextView.adjustedContentInset.top),
            searchMapView.bottomAnchor.constraint(equalTo: noteEditorTextView.bottomAnchor, constant: -noteEditorTextView.adjustedContentInset.bottom),
            searchMapView.trailingAnchor.constraint(equalTo: noteEditorTextView.trailingAnchor),
            searchMapView.widthAnchor.constraint(equalToConstant: Metrics.searchMapWidth)
        ])

        searchMapView.onSelectionChange = { [weak self] index in
            self?.highlightSearchResult(at: index, animated: false)
        }

        self.searchMapView = searchMapView
    }

    /// Hide search map
    ///
    @objc
    func hideSearchMap() {
        searchMapView?.removeFromSuperview()
        searchMapView = nil
    }
}

// MARK: - Quick Actions
//
extension SPNoteEditorViewController {
    @objc
    func updateHomeScreenQuickActions() {
        ShortcutsHandler.shared.updateHomeScreenQuickActions(with: note)
    }
}

// MARK: - Keyboard
//
extension SPNoteEditorViewController {
    open override var canBecomeFirstResponder: Bool {
        return true
    }

    open override var keyCommands: [UIKeyCommand]? {
        guard presentedViewController == nil else {
            return nil
        }

        var commands = [
            UIKeyCommand(input: "n",
                         modifierFlags: [.command],
                         action: #selector(keyboardCreateNewNote),
                         title: Localization.Shortcuts.newNote),
        ]

        if note.markdown == true {
            commands.append(UIKeyCommand(input: "p",
                                         modifierFlags: [.command, .shift],
                                         action: #selector(keyboardToggleMarkdownPreview),
                                         title: Localization.Shortcuts.toggleMarkdown))
        }



        if searching {
            commands.append(contentsOf: [
                UIKeyCommand(input: "g",
                             modifierFlags: [.command],
                             action: #selector(keyboardHighlightNextMatch),
                             title: Localization.Shortcuts.nextMatch),
                UIKeyCommand(input: "g",
                             modifierFlags: [.command, .shift],
                             action: #selector(keyboardHighlightPrevMatch),
                             title: Localization.Shortcuts.previousMatch),
            ])
        }

        if noteEditorTextView.isFirstResponder {
            commands.append(UIKeyCommand(input: "c",
                                         modifierFlags: [.command, .shift],
                                         action: #selector(keyboardInsertChecklist),
                                         title: Localization.Shortcuts.insertChecklist))
        } else {
            commands.append(UIKeyCommand(input: UIKeyCommand.inputTab,
                                         modifierFlags: [],
                                         action: #selector(keyboardFocusOnEditor)))
        }

        commands.append(UIKeyCommand(input: UIKeyCommand.inputReturn,
                                     modifierFlags: [.command],
                                     action: #selector(keyboardGoBack),
                                     title: Localization.Shortcuts.endEditing))

        return commands
    }

    @objc
    private func keyboardCreateNewNote() {
        SPTracker.trackShortcutCreateNote()
        presentNewNoteReplacingCurrentEditor()
    }

    @objc
    private func keyboardToggleMarkdownPreview() {
        SPTracker.trackShortcutToggleMarkdownPreview()
        presentMarkdownPreview()
    }

    @objc
    private func keyboardInsertChecklist() {
        SPTracker.trackShortcutToggleChecklist()
        insertChecklistAction(checklistButton)
    }

    @objc
    private func keyboardHighlightNextMatch() {
        SPTracker.trackShortcutSearchNext()
        highlightNextSearchResult()
    }

    @objc
    private func keyboardHighlightPrevMatch() {
        SPTracker.trackShortcutSearchPrev()
        highlightPrevSearchResult()
    }

    @objc
    private func keyboardFocusOnEditor() {
        noteEditorTextView.becomeFirstResponder()
        noteEditorTextView.selectedTextRange = noteEditorTextView.textRange(from: noteEditorTextView.beginningOfDocument,
                                                                            to: noteEditorTextView.beginningOfDocument)
    }

    @objc
    private func keyboardGoBack() {
        dismissEditor(nil)
    }
}


// MARK: - Scroll position
//
extension SPNoteEditorViewController {
    @objc
    func saveScrollPosition() {
        guard let key = note.simperiumKey else {
            return
        }

        scrollPositionCache.store(position: noteEditorTextView.contentOffset.y,
                                  for: key)
    }

    @objc
    func restoreScrollPosition() {
        guard let key = note.simperiumKey,
              let offsetY = scrollPositionCache.position(for: key) else {
            noteEditorTextView.scrollToTop()
            return
        }

        let offset = CGPoint(x: 0, y: offsetY)

        noteEditorTextView.contentOffset = noteEditorTextView.boundedContentOffset(from: offset)
    }
}


// MARK: - Metrics
//
private enum Metrics {
    static let lineSpacingMultiplerPad: CGFloat = 0.40
    static let lineSpacingMultiplerPhone: CGFloat = 0.20

    static var lineSpacingMultipler: CGFloat {
        UIDevice.isPad ? lineSpacingMultiplerPad : lineSpacingMultiplerPhone
    }

    static let searchMapWidth: CGFloat = 15.0
    static let additionalTagViewAndEditorCollisionDistance: CGFloat = 16.0
}


// MARK: - Localization
//
private enum Localization {
    enum Shortcuts {
        static let newNote = NSLocalizedString("New Note", comment: "Keyboard shortcut: New Note")
        static let nextMatch = NSLocalizedString("Next Match", comment: "Keyboard shortcut: Note search, Next Match")
        static let previousMatch = NSLocalizedString("Previous Match", comment: "Keyboard shortcut: Note search, Previous Match")
        static let insertChecklist = NSLocalizedString("Insert Checklist", comment: "Keyboard shortcut: Insert Checklist")
        static let toggleMarkdown = NSLocalizedString("Toggle Markdown", comment: "Keyboard shortcut: Toggle Markdown")
        static let endEditing = NSLocalizedString("End Editing", comment: "Keyboard shortcut: End Editing")
    }
}
