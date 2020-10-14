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

    ///
    ///
    @objc
    weak var parentTextView: UITextView?


    /// Linkification happens when the TextView is not editable.
    /// Ever since iOS 7, we've relied on a custom GestureRecognizer to handle tap events, and reposition the cursor.
    /// As per iOS 14, since our custom tap handling is causing weird side effects, we're only proceeding when the TextView is not the First Responder.
    ///
    /// Ref. https://github.com/Automattic/simplenote-ios/pull/916
    ///
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard #available(iOS 14.0, *) else {
            return true
        }

        return parentTextView?.isFirstResponder == false
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
