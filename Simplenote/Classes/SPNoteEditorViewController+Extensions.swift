import Foundation


// MARK: - Interface Initialization
//
extension SPNoteEditorViewController {

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
    ///
    private func updateBottomInsets(keyboardFrame: CGRect, duration: TimeInterval, curve: UInt) {
        let newKeyboardHeight       = keyboardFrame.intersection(noteEditorTextView.frame).height
        let newKeyboardFloats       = keyboardFrame.maxY < view.frame.height
        let newKeyboardIsVisible    = newKeyboardHeight != .zero

        let animationOptions        = UIView.AnimationOptions(arrayLiteral: .beginFromCurrentState, .init(rawValue: curve))
        let editorBottomInsets      = newKeyboardFloats ? .zero : newKeyboardHeight
        let adjustedBottomInsets    = max(editorBottomInsets - view.safeAreaInsets.bottom, .zero)

        defer {
            isKeyboardVisible = newKeyboardIsVisible
        }

        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: .zero, options: animationOptions, animations: {
            self.noteEditorTextView.contentInset.bottom = adjustedBottomInsets
            self.noteEditorTextView.scrollIndicatorInsets.bottom = adjustedBottomInsets
        }, completion: nil)
    }
}


// MARK: - Voiceover Support
//
extension SPNoteEditorViewController {

    @objc
    var voiceoverEnabled: Bool {
        UIAccessibility.isVoiceOverRunning
    }

    @objc
    func refreshVoiceoverSupport() {
        let enabled = voiceoverEnabled
        updateTagsEditor(locked: enabled)

        if voiceoverEnabled {
            resetNavigationBarToIdentity(withAnimation: true, completion: nil)
        }
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

// MARK: - Navigation button handling
//
extension SPNoteEditorViewController {

    /// Presents the note options view
    /// - Parameter button: The button that triggered the action
    @objc
    func handleNoteOptions(_ button: UIButton) {

        save()
        endEditing(button)
        tagView.endEditing(true)

        SPTracker.trackEditorActivitiesAccessed()
        presentNoteOptions(from: button)
    }

    /// Presents a new note options view from a given `UIButton`
    /// This is presented as a popover on iPad
    /// - Parameter button: The button to anchor the popover to
    func presentNoteOptions(from button: UIButton) {
        let noteView = NoteOptionsViewController(with: currentNote)
        noteView.delegate = self
        let noteNavigation = SPNavigationController(rootViewController: noteView)
        noteNavigation.displaysBlurEffect = true
        noteNavigation.modalPresentationStyle = .popover
        noteNavigation.popoverPresentationController?.sourceRect = button.bounds
        noteNavigation.popoverPresentationController?.sourceView = button
        noteNavigation.popoverPresentationController?.backgroundColor = .simplenoteNavigationBarModalBackgroundColor
        noteNavigation.popoverPresentationController?.delegate = self
        present(noteNavigation, animated: true, completion: nil)
    }
}

// MARK: - Popover presentation delegate
//
extension SPNoteEditorViewController: UIPopoverPresentationControllerDelegate {
    public func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        if bounceMarkdownPreviewOnActivityViewDismiss {
            bounceMarkdownPreview()
        }
    }

    // The `SPActivityView` and `SPPopoverContainerViewController` breaks when transitioning from a popover to a modal-style
    // presentation, so we'll tell it not to change its presentation if the
    // view's size class changes.
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        if controller.presentedViewController is SPPopoverContainerViewController {
            return .none
        }
        return .popover
    }
}

// MARK: - Note options delegate
//
extension SPNoteEditorViewController: NoteOptionsViewControllerDelegate {
    func didToggleMarkdown(state: Bool) {

        // If Markdown is being enabled and it was previously disabled
        bounceMarkdownPreviewOnActivityViewDismiss = state && !UserDefaults.standard.bool(forKey: kSimplenoteMarkdownDefaultKey)

        // Update the global preference to use when creating new notes
        UserDefaults.standard.set(state, forKey: kSimplenoteMarkdownDefaultKey)
    }

    func didTapHistory(sender: NoteOptionsViewController) {
        sender.dismiss(animated: true) { [weak self] in
            self?.viewVersionAction(sender)
        }
    }

    func didTapMoveToTrash(sender: NoteOptionsViewController) {
        sender.dismiss(animated: true, completion: nil)
        trashNoteAction(self)
    }
}

// MARK: - Note options state handling
//
extension SPNoteEditorViewController {
    /// A convenience variable for accessing the currently presented note options view
    /// This is used to pass on note updates from Simperium
    @objc var presentedNoteOptionsViewController: NoteOptionsViewController? {
        return (presentedViewController as? SPNavigationController)?.topViewController as? NoteOptionsViewController
    }
}
