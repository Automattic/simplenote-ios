import UIKit

// MARK: - SPTagEntryField
//
extension SPTagEntryField {
    open override func paste(_ sender: Any?) {
        guard let selectedRange = selectedRange,
              let pasteboardText = UIPasteboard.general.string, !pasteboardText.isEmpty else {
            return
        }

        let tag = TagTextFieldInputValidator().sanitize(tag: pasteboardText)
        guard !tag.isEmpty else {
            return
        }

        guard delegate?.textField?(self, shouldChangeCharactersIn: selectedRange, replacementString: tag) == true else {
            return
        }

        insertText(tag)
    }
}
