import Foundation


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

        let newKeyboardHeight = keyboardFrame.intersection(view.frame).height

        UIView.animate(withDuration: duration) {
            self.noteEditorTextView.scrollIndicatorInsets.bottom = newKeyboardHeight
            self.noteEditorTextView.contentInset.bottom = newKeyboardHeight
        }

        keyboardHeight = newKeyboardHeight
    }
}
