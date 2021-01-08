import UIKit

// MARK: - UITextField
//
extension UITextField {
    /// Preprocess pasteboard content before pasting into tag text field
    ///
    @objc
    func pasteTag() {
        guard let selectedRange = selectedRange,
              let pasteboardText = UIPasteboard.general.string, !pasteboardText.isEmpty else {
            return
        }

        guard let tag = TagTextFieldInputValidator().preprocessForPasting(tag: pasteboardText),
              !tag.isEmpty else {
            return
        }

        guard delegate?.textField?(self, shouldChangeCharactersIn: selectedRange, replacementString: tag) == true else {
            return
        }

        insertText(tag)
    }
}
