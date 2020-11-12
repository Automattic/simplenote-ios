import Foundation
import UIKit
import SimplenoteInterlinks


// MARK: - UITextView State
//
extension UITextView {

    /// Indicates if the receiver contains selected text
    ///
    @objc
    var isTextSelected: Bool {
        return selectedRange.length > 0
    }

    /// Indicates if there's an ongoing Undo Operation in the Text Editor
    ///
    var isUndoingEditOP: Bool {
        undoManager?.isUndoing == true
    }

    /// Indicates if the user is Editing an Interlink
    ///
    var isEditingInterlink: Bool {
        interlinkKeywordAtSelectedLocation != nil
    }
}


// MARK: - Interlinks
//
extension UITextView {

    /// Returns the Interlinking Keyword at the current Location (if any)
    ///
    var interlinkKeywordAtSelectedLocation: (Range<String.Index>, Range<String.Index>, String)? {
        guard let text = text else {
            return nil
        }

        return text.indexFromLocation(selectedRange.location).flatMap { index in
            text.interlinkKeyword(at: index)
        }
    }
}


// MARK: - Attachments
//
extension UITextView {

    /// Returns the NSTextAttachment of the specified kind, ad a given Index. If possible
    ///
    func attachment<T: NSTextAttachment>(ofType: T.Type, at index: Int) -> T? {
        guard index < textStorage.length else {
            return nil
        }

        return attributedText.attribute(.attachment, at: index, effectiveRange: nil) as? T
    }
}


// MARK: - Geometry
//
extension UITextView {

    /// Returns the Bounding Rect for the specified `Range<String.Index>`
    ///
    func boundingRect(for range: Range<String.Index>) -> CGRect {
        let nsRange = NSRange(range, in: text)
        return boundingRect(for: nsRange)
    }

    /// Returns the Bounding Rect for the specified NSRange
    ///
    func boundingRect(for range: NSRange) -> CGRect {
        let glyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
        let rect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)

        return rect.offsetBy(dx: textContainerInset.left, dy: textContainerInset.top)
    }

    /// Returns the "Editing Rect": We rely on this calculation to determine the "available area" in which Interlinks Autocomplete
    /// can be presented.
    ///
    /// - Note: `contentInset.bottom` is expected to contain the bottom padding required by the keyboard. Capisce?
    ///
    func editingRect() -> CGRect {
        let paddingTop = safeAreaInsets.top
        let paddingBottom = safeAreaInsets.bottom + contentInset.bottom
        let editingHeight = frame.height - paddingTop - paddingBottom

        return CGRect(x: .zero, y: paddingTop, width: frame.width, height: editingHeight)
    }

    /// Returns the Window Location for the text at the specified range
    ///
    func locationInSuperviewForText(in range: Range<String.Index>) -> CGRect {
        let rectInEditor = boundingRect(for: range)
        return superview?.convert(rectInEditor, from: self) ?? rectInEditor
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
}
