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

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
