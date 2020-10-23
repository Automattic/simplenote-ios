import Foundation
import UIKit
import SimplenoteInterlinks


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
        guard index < textStorage.length else {
            return nil
        }

        return attributedText.attribute(.attachment, at: index, effectiveRange: nil) as? T
    }
}

// MARK: - Updating!
//
extension UITextView {

    /// Inserts the specified Text at a given range
    ///
    func insertText(text: String, in range: Range<String.Index>) {
        registerUndoCheckpointAndPerform { storage in
            let range = text.utf16NSRange(from: range)
            storage.replaceCharacters(in: range, with: text)
        }
    }
}


// MARK: - Private!
//
private extension UITextView {

    /// Registers an Undo Checkpoint, and performs a given block `in a transactional fashion`: an Undo Group will wrap its execution
    ///
    ///     1.  Registers an Undo Operation which is expected to restore the TextView to its previous state
    ///     2.  Wraps up a given `Block` within an Undo Group
    ///     3.  Post a TextDidChange Notification
    ///
    @discardableResult
    func registerUndoCheckpointAndPerform(block: (NSTextStorage) -> Void) -> Bool {
        guard let undoManager = undoManager else {
            return false
        }

        undoManager.beginUndoGrouping()
        registerUndoCheckpoint(in: undoManager, storage: textStorage)
        block(textStorage)
        undoManager.endUndoGrouping()

        notifyDidChangeText()

        return true
    }

    /// Registers an Undo Checkpoint, which is expected to restore the receiver to its previous state:
    ///
    ///     1.  Restores the full contents of our TextStorage
    ///     2.  Reverts the SelectedRange
    ///     3.  Post a textDidChange Notification
    ///
    func registerUndoCheckpoint(in undoManager: UndoManager, storage: NSTextStorage) {
        let oldSelectedRange = selectedRange
        let oldText = storage.attributedSubstring(from: storage.fullRange)

        undoManager.registerUndo(withTarget: self) { textView in
            // Register an Undo *during* an Undo? > Also known as Redo!
            textView.registerUndoCheckpoint(in: undoManager, storage: storage)

            // And the actual Undo!
            storage.replaceCharacters(in: storage.fullRange, with: oldText)
            textView.selectedRange = oldSelectedRange
            textView.notifyDidChangeText()
        }
    }

    func notifyDidChangeText() {
        delegate?.textViewDidChange?(self)
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


// MARK: - Geometry
//
extension UITextView {

    /// Returns the Bounding Rect for the specified `Range<String.Index>`
    ///
    func boundingRect(for range: Range<String.Index>) -> CGRect {
        let nsRange = text.utf16NSRange(from: range)
        return boundingRect(for: nsRange)
    }

    /// Returns the Bounding Rect for the specified NSRange
    ///
    func boundingRect(for range: NSRange) -> CGRect {
        let glyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
        let rect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)

        return rect.offsetBy(dx: textContainerInset.left, dy: textContainerInset.top)
    }

    /// Returns the Window Location for the text at the specified range
    ///
    func locationInSuperviewForText(in range: Range<String.Index>) -> CGRect {
        let rectInEditor = boundingRect(for: range)
        return superview?.convert(rectInEditor, from: self) ?? rectInEditor
    }
}
