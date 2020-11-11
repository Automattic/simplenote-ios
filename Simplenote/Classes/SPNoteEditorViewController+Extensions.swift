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

        createNoteButton = UIBarButtonItem(image: .image(name: .newNote), style: .plain, target: self, action: #selector(newButtonAction(_:)))
        createNoteButton.accessibilityLabel = NSLocalizedString("New note", comment: "Label to create a new note")

        keyboardButton = UIBarButtonItem(image: .image(name: .hideKeyboard), style: .plain, target: self, action: #selector(keyboardButtonAction(_:)))
        keyboardButton.accessibilityLabel = NSLocalizedString("Dismiss keyboard", comment: "Dismiss Keyboard Button")
    }

    /// Sets up the Bottom View:
    /// - Note: This helper view covers the area between the bottom edge of the screen, and the safeArea's bottom
    ///
    @objc
    func configureBottomView() {
        bottomView = UIView()
        bottomView.isHidden = true
    }

    /// Sets up the Root ViewController
    ///
    @objc
    func configureRootView() {
        view.addSubview(noteEditorTextView)
        view.addSubview(navigationBarBackground)
        view.addSubview(bottomView)
    }

    /// Sets up the Layout
    ///
    @objc
    func configureLayout() {
        navigationBarBackground.translatesAutoresizingMaskIntoConstraints = false
        noteEditorTextView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.translatesAutoresizingMaskIntoConstraints = false

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

        NSLayoutConstraint.activate([
            bottomView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
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
    @objc
    var voiceoverEnabled: Bool {
        UIAccessibility.isVoiceOverRunning
    }

    /// Whenver VoiceOver is enabled, this API will lock the Tags List in position
    ///
    @objc
    func refreshVoiceoverSupport() {
        let enabled = voiceoverEnabled
        updateTagsEditor(locked: enabled)
    }

    /// Whenever the Tags Editor must be locked:
    ///     - We'll fix the editor's position at the bottom of the TextView
    ///     - And we'll display the `bottomView`: covers the spacing between Bottom / SafeArea.bottom
    ///
    func updateTagsEditor(locked: Bool) {
        bottomView.isHidden = !locked
        noteEditorTextView.lockTagEditorPosition = locked
    }
}


// MARK: - State Restoration
//
extension SPNoteEditorViewController {

    var simperium: Simperium {
        SPAppDelegate.shared().simperium
    }

    open override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)

        guard let note = currentNote else {
            return
        }

        // Always make sure the object is persisted before proceeding
        if note.objectID.isTemporaryID {
            simperium.save()
        }

        coder.encode(note.simperiumKey, forKey: CodingKeys.currentNoteKey.rawValue)
    }

    open override func decodeRestorableState(with coder: NSCoder) {
        guard let simperiumKey = coder.decodeObject(forKey: CodingKeys.currentNoteKey.rawValue) as? String,
            let note = simperium.bucket(forName: Note.classNameWithoutNamespaces)?.object(forKey: simperiumKey) as? Note
            else {
                navigationController?.popViewController(animated: false)
                return
        }

        display(note)
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

        let viewController = SPNoteHistoryViewController(note: currentNote, delegate: self)
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
            informationViewController.configureToPresentAsCard()
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

        informationViewController.dismiss(animated: false) { [weak self] in
            guard let self = self,
                  let note = self.currentNote,
                  let informationButton = self.informationButton else {
                return
            }
            self.presentInformationController(for: note, from: informationButton)
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
        guard let note = currentNote else {
            return
        }

        guard note.isBlank, noteEditorTextView.text.isEmpty else {
            save()
            return
        }

        SPObjectManager.shared().trashNote(note)
        currentNote = nil
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
        updateEditor(with: currentNote.content)
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
        guard let note = currentNote else {
            assertionFailure()
            return
        }

        presentOptionsController(for: note, from: sender)
    }

    @objc
    private func noteInformationWasPressed(_ sender: UIBarButtonItem) {
        guard let note = currentNote else {
            assertionFailure()
            return
        }

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
        return text.contentSlice(matching: keywords).nsMatches
    }
}

// MARK: - NSCoder Keys
//
private enum CodingKeys: String {
    case currentNoteKey
}
