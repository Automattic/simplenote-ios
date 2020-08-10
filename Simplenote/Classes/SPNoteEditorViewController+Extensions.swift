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

        update(note)
    }
}


// MARK: - NSCoder Keys
//
private enum CodingKeys: String {
    case currentNoteKey
}
