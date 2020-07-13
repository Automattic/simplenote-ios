import Foundation


// MARK: - Interface Initialization
//
extension SPNoteEditorViewController {

    /// Sets up the Root ViewController
    ///
    @objc
    func configureRootView() {
        navigationBarBackground.translatesAutoresizingMaskIntoConstraints = false
        noteEditorTextView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(noteEditorTextView)
        view.addSubview(navigationBarBackground)

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

        let newKeyboardHeight = keyboardFrame.intersection(noteEditorTextView.frame).height
        
        UIView.animate(withDuration: duration) {
            self.noteEditorTextView.scrollIndicatorInsets.bottom = newKeyboardHeight
            self.noteEditorTextView.contentInset.bottom = newKeyboardHeight
        }

        isKeyboardVisible = newKeyboardHeight != .zero
    }
}
