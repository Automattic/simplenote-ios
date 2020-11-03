import Foundation

// MARK: - SPEditorTextView
//
extension SPEditorTextView {

    /// Processes content of note editor, and replaces special string attachments with their plain text counterparts. Currently supports markdown checklists.
    @objc
    var plainText: String {
        return NSAttributedStringToMarkdownConverter.convert(string: attributedText)
    }
}
