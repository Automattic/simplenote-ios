import Foundation
import UIKit

// MARK: - SPEditorTapRecognizerDelegate
//  Since the dawn of time, UITextView itself was set as (our own) TapGestureRecognizer delegate.
//  As per iOS 14, the new (superclass) implementation is not allowing our Tap recognizer to work simultaneously with its (internal)
//  recognizers. This is causing several undesired side effects.
//
//  Ref. https://github.com/Automattic/simplenote-ios/pull/916
//
class SPEditorTapRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {

    /// TextView in which we're listening to changes
    ///
    @objc
    weak var parentTextView: UITextView?

    /// View that, when interacted upon, should cause the recognizer to bail out
    ///
    @objc
    weak var excludedView: UIView?

    /// TextView only performs linkification when the `editable` flag is disabled.
    /// We're allowing Edition by means of a TapGestureRecognizer, which also allows us to deal with Tap events performed over TextAttachments
    ///
    /// Ref. https://github.com/Automattic/simplenote-ios/pull/916
    ///
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let textView = parentTextView else {
            return true
        }

        if textView.isDragging {
            return false
        }

        let characterIndex = gestureRecognizer.characterIndex(in: textView)
        if textView.attachment(ofType: SPTextAttachment.self, at: characterIndex) != nil {
            return true
        }

        return textView.isFirstResponder == false
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let excludedView = excludedView, let touchView = touch.view else {
            return true
        }

        return touchView.isDescendant(of: excludedView) == false
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
