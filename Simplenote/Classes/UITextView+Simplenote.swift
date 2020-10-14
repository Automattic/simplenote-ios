import Foundation
import UIKit


// MARK: - UITextView's Simplenote Methods
//
extension UITextView {

    /// Indicates if the receiver contains selected text
    ///
    @objc
    var isTextSelected: Bool {
        return selectedRange.length > 0
    }

    /// Returns the Selected Text's bounds
    ///
    @objc
    var selectedBounds: CGRect {
        guard selectedRange.length > 0 else {
            return .zero
        }

        return layoutManager.boundingRect(forGlyphRange: selectedRange, in: textContainer)
    }

    /// Returns the NSTextAttachment of the specified kind, ad a given Index. If possible
    ///
    func attachment<T: NSTextAttachment>(ofType: T.Type, at index: Int) -> T? {
        return attributedText.attribute(.attachment, at: index, effectiveRange: nil) as? T
    }
}
