import Foundation


/// Adopters of this protocol will recieve keyboard-based notifications
/// by implmenting the provided functions within.
///
public protocol KeyboardObservable: class {

    /// Called immediately prior to the display of the keyboard and includes related animation information.
    ///
    /// - Parameters:
    ///   - beginFrame: starting frame of the keyboard display animation
    ///   - endFrame: ending frame of the keyboard display animation
    ///   - animationDuration: total duration of the keyboard display animation
    ///   - animationCurve: animation curve for the keyboard display animation
    ///
    func keyboardWillShow(beginFrame: CGRect?, endFrame: CGRect?, animationDuration: TimeInterval?, animationCurve: UInt?)

    /// Called immediately prior to the dismissal of the keyboard and includes related animation information.
    ///
    /// - Parameters:
    ///   - beginFrame: starting frame of the keyboard dismissal animation
    ///   - endFrame: ending frame of the keyboard dismissal animation (typically 0)
    ///   - animationDuration: total duration of the keyboard dismissal animation
    ///   - animationCurve: animation curve for the keyboard dismissal animation
    ///
    func keyboardWillHide(beginFrame: CGRect?, endFrame: CGRect?, animationDuration: TimeInterval?, animationCurve: UInt?)
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
                self?.keyboardWillShow(beginFrame: notification.keyboardBeginFrame(),
                                       endFrame: notification.keyboardEndFrame(),
                                       animationDuration: notification.keyboardAnimationDuration(),
                                       animationCurve: notification.keyboardAnimationCurve())
        })

        notificationCenter.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: nil,
            using: { [weak self] notification in
                self?.keyboardWillHide(beginFrame: notification.keyboardBeginFrame(),
                                       endFrame: notification.keyboardEndFrame(),
                                       animationDuration: notification.keyboardAnimationDuration(),
                                       animationCurve: notification.keyboardAnimationCurve())
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
    func keyboardBeginFrame () -> CGRect? {
        return (self.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
    }

    /// Gets the optional CGRect value of the UIKeyboardFrameEndUserInfoKey from a UIKeyboard notification
    ///
    func keyboardEndFrame () -> CGRect? {
        return (self.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
    }

    /// Gets the optional AnimationDuration value of the UIKeyboardAnimationDurationUserInfoKey from a UIKeyboard notification
    ///
    func keyboardAnimationDuration () -> TimeInterval? {
        return (self.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
    }

    /// Gets the optional AnimationCurve value of the UIKeyboardAnimationCurveUserInfoKey from a UIKeyboard notification
    ///
    func keyboardAnimationCurve () -> UInt? {
        return (self.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue
    }
}
