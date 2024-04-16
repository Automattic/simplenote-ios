import Foundation
import UIKit

/// Adopters of this protocol will recieve interactive keyboard-based notifications
/// by implmenting the provided functions within.
///
public protocol KeyboardObservable: AnyObject {

    /// Called during a Keyboard Repositioning Notification.
    ///
    /// - Parameters:
    ///   - beginFrame: starting frame of the keyboard
    ///   - endFrame: ending frame of the keyboard
    ///   - animationDuration: total duration of the keyboard animation
    ///   - animationCurve: animation curve for the keyboard animation
    ///
    func keyboardWillChangeFrame(beginFrame: CGRect?, endFrame: CGRect?, animationDuration: TimeInterval?, animationCurve: UInt?)

    /// Called during an Keyboard Repositioning Notification.
    ///
    /// - Parameters:
    ///   - beginFrame: starting frame of the keyboard
    ///   - endFrame: ending frame of the keyboard
    ///   - animationDuration: total duration of the keyboard animation
    ///   - animationCurve: animation curve for the keyboard animation
    ///
    func keyboardDidChangeFrame(beginFrame: CGRect?, endFrame: CGRect?, animationDuration: TimeInterval?, animationCurve: UInt?)
}

/// Interactive Keyboard Observers
///
extension KeyboardObservable {

    /// Setup the keyboard observers for the provided `NotificationCenter`.
    ///
    /// - Parameter notificationCenter: `NotificationCenter` to register the keyboard interactive observer
    ///   with (or `.default` if none is specified).
    ///
    /// - Returns: An array of opaque objects, strongly retained by the NotificationCenter. Must be passed back to `removeKeyboardObservers`
    ///
    public func addKeyboardObservers(to notificationCenter: NotificationCenter = .default) -> [Any] {
        let tokenWillBegin = notificationCenter.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: nil, using: { [weak self] notification in
            self?.keyboardWillChangeFrame(beginFrame: notification.keyboardBeginFrame(),
                                          endFrame: notification.keyboardEndFrame(),
                                          animationDuration: notification.keyboardAnimationDuration(),
                                          animationCurve: notification.keyboardAnimationCurve())
        })

        let tokenDidBegin = notificationCenter.addObserver(forName: UIResponder.keyboardDidChangeFrameNotification, object: nil, queue: nil, using: { [weak self] notification in
            self?.keyboardDidChangeFrame(beginFrame: notification.keyboardBeginFrame(),
                                         endFrame: notification.keyboardEndFrame(),
                                         animationDuration: notification.keyboardAnimationDuration(),
                                         animationCurve: notification.keyboardAnimationCurve())
        })

        return [tokenWillBegin, tokenDidBegin]
    }

    /// Remove the keyboard observers for the provided `NotificationCenter`.
    ///
    /// - Parameter notificationCenter: `NotificationCenter` to remove the keyboard interactive observer
    ///   from (or `.default` if none is specified).
    ///
    public func removeKeyboardObservers(with tokens: [Any], from notificationCenter: NotificationCenter = .default) {
        for token in tokens {
            notificationCenter.removeObserver(token)
        }
    }
}

// MARK: - Notification + UIKeyboardInfo
//
private extension Notification {

    /// Gets the optional CGRect value of the UIKeyboardFrameBeginUserInfoKey from a UIKeyboard notification
    ///
    func keyboardBeginFrame () -> CGRect? {
        return (userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
    }

    /// Gets the optional CGRect value of the UIKeyboardFrameEndUserInfoKey from a UIKeyboard notification
    ///
    func keyboardEndFrame () -> CGRect? {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
    }

    /// Gets the optional AnimationDuration value of the UIKeyboardAnimationDurationUserInfoKey from a UIKeyboard notification
    ///
    func keyboardAnimationDuration () -> TimeInterval? {
        return (userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
    }

    /// Gets the optional AnimationCurve value of the UIKeyboardAnimationCurveUserInfoKey from a UIKeyboard notification
    ///
    func keyboardAnimationCurve () -> UInt? {
        return (userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue
    }
}
