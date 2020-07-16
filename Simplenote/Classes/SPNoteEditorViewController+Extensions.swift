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
        addKeyboardObservers()
    }

    @objc
    func stopListeningToKeyboardNotifications() {
        removeKeyboardObservers()
    }

    public func keyboardWillChangeFrame(beginFrame: CGRect?, endFrame: CGRect?, animationDuration: TimeInterval?, animationCurve: UInt?) {
        guard let _ = view.window, let keyboardFrame = endFrame, let duration = animationDuration else {
            return
        }

        updateBottomInsets(keyboardFrame: keyboardFrame, duration: duration)
    }

    public func keyboardDidChangeFrame(beginFrame: CGRect?, endFrame: CGRect?, animationDuration: TimeInterval?, animationCurve: UInt?) {
        guard let _ = view.window, let keyboardFrame = endFrame, let duration = animationDuration else {
            return
        }

        updateBottomInsets(keyboardFrame: keyboardFrame, duration: duration)
    }

    /// Updates the Editor's Bottom Insets
    ///
    /// - Note: Floating Keyboard results in `contentInset.bottom = .zero`
    /// - Note: No animation when the Keyboard Visibility isn't affected (when switching from<>to TagsEditor)
    /// - Note: Performs `scrollToBottom` alongside, whenever TagsView is the firstResponder
    ///
    private func updateBottomInsets(keyboardFrame: CGRect, duration: TimeInterval) {
        let newKeyboardHeight   = keyboardFrame.intersection(noteEditorTextView.frame).height
        let isKeyboardFloating  = keyboardFrame.maxY < view.bounds.height
        let wasKeyboardVisible  = isKeyboardVisible
        let newBottomInsets     = isKeyboardFloating ? .zero : newKeyboardHeight
        let mustScrollToBottom  = tagView.isFirstResponder

        isKeyboardVisible       = newKeyboardHeight != .zero

        let closure = {
            self.noteEditorTextView.scrollIndicatorInsets.bottom = newBottomInsets
            self.noteEditorTextView.contentInset.bottom = newBottomInsets

            if mustScrollToBottom {
                self.noteEditorTextView.scrollToBottom()
            }
        }

        guard isKeyboardVisible != wasKeyboardVisible else {
            closure()
            return
        }

        UIView.animate(withDuration: duration, animations: closure)
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
