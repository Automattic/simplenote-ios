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
}

// MARK: - Updating!
//
extension UITextView {

    /// Inserts the specified Text at a given range.
    /// - Note: Resulting selected range will end up at the right hand side of the newly inserted text.
    ///
    func insertText(text: String, in range: Range<String.Index>) {
        registerUndoCheckpointAndPerform { storage in
            let range = NSRange(range, in: self.text)
            storage.replaceCharacters(in: range, with: text)

            let insertedTextRange = NSRange(text.fullRange, in: text)
            self.selectedRange = NSRange(location: range.location + insertedTextRange.length, length: .zero)
        }
    }
}

// MARK: - Undo Stack
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
        guard let text = text, let range = Range(selectedRange, in: text) else {
            return nil
        }

        return text.interlinkKeyword(at: range.lowerBound)
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
    func editingRectInWindow() -> CGRect {
        let paddingTop = frame.minY + safeAreaInsets.top
        let paddingBottom = safeAreaInsets.bottom + contentInset.bottom
        let editingHeight = frame.height - paddingTop - paddingBottom

        let output = CGRect(x: frame.minX, y: paddingTop, width: frame.width, height: editingHeight)
        return superview?.convert(output, to: nil) ?? output
    }

    /// Returns the Window Location for the text at the specified range
    ///
    func locationInWindowForText(in range: Range<String.Index>) -> CGRect {
        let rectInEditor = boundingRect(for: range)
        return convert(rectInEditor, to: nil)
    }

    /// Returns the Selected Text's bounds
    ///
    @objc
    var selectedBounds: CGRect {
        guard selectedRange.length > 0 else {
            return .zero
        }

        let glyphRange = layoutManager.glyphRange(forCharacterRange: selectedRange, actualCharacterRange: nil)
        return layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
    }
}
