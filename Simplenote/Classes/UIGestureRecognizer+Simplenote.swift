import Foundation
import UIKit

// MARK: - UIGestureRecognizer Simplenote Methods
//
extension UIGestureRecognizer {

    /// Forgive me: this is the only known way (AFAIK) to force a recognizer to fail. Seen in WWDC 2014 (somewhere), and a better way is yet to be found.
    ///
    @objc
    func fail() {
        isEnabled = false
        isEnabled = true
    }

    /// Translates the receiver's location into a Character Index within the specified TextView
    ///
    @objc(characterIndexInTextView:)
    func characterIndex(in textView: UITextView) -> Int {
        var locationInContainer = location(in: textView)
        locationInContainer.x -= textView.textContainerInset.left
        locationInContainer.y -= textView.textContainerInset.top

        guard #available(iOS 17.0, *),
              let textLayoutManager = textView.textLayoutManager else {
            // TextKit 1 fallback
            return textView.layoutManager.characterIndex(
                for: locationInContainer,
                in: textView.textContainer,
                fractionOfDistanceBetweenInsertionPoints: nil)
        }

        // TextKit 2
        return textLayoutManager.characterIndex(for: locationInContainer) ?? .zero
    }
}
