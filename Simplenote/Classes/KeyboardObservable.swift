import Foundation


/// Adopters of this protocol will recieve keyboard-based notifications
/// by implmenting the provided functions within.
///
public protocol KeyboardObservable: class {
    func keyboardWillShow(endFrame: CGRect?, animationDuration: Double?)
    func keyboardWillHide(endFrame: CGRect?, animationDuration: Double?)
}


// MARK: - NotificationCenter Helpers
//
extension KeyboardObservable {

    /// Setup the keyboard observers for the provided `NotificationCenter`.
    ///
    /// - Parameter notificationCenter: `NotificationCenter` to register the keyboard observers
    ///   with (or `.default` if none is specified).
    ///
    public func addKeyboardObservers(to notificationCenter: NotificationCenter = .default) {
        notificationCenter.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: nil,
            using: { [weak self] notification in
                self?.keyboardWillShow(endFrame: notification.keyboardEndFrame(), animationDuration: notification.keyboardAnimationDuration())
        })

        notificationCenter.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: nil,
            using: { [weak self] notification in
                self?.keyboardWillHide(endFrame: notification.keyboardEndFrame(), animationDuration: notification.keyboardAnimationDuration())
        })
    }


    /// Remove the keyboard observers for the provided `NotificationCenter`.
    ///
    /// - Parameter notificationCenter: `NotificationCenter` to remove the keyboard observers
    ///   from (or `.default` if none is specified).
    ///
    public func removeKeyboardObservers(from notificationCenter: NotificationCenter = .default) {
        notificationCenter.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil)

        notificationCenter.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
    }
}


// MARK: - Notification + UIKeyboardInfo
//
private extension Notification {

    /// Gets the optional CGRect value of the UIKeyboardFrameEndUserInfoKey from a UIKeyboard notification
    ///
    func keyboardEndFrame () -> CGRect? {
        return (self.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
    }

    /// Gets the optional AnimationDuration value of the UIKeyboardAnimationDurationUserInfoKey from a UIKeyboard notification
    ///
    func keyboardAnimationDuration () -> Double? {
        return (self.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
    }
}
