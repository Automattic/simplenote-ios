import Foundation

// MARK: - NSAttributedString to Markdown Converter
//
struct NSAttributedStringToMarkdownConverter {

    /// Markdown replacement for "Unchecked Checklist"
    ///
    private static let unchecked = "- [ ]"

    /// Markdown replacement for "Checked Checklist"
    ///
    private static let checked = "- [x]"

    /// Returns the NSString representation of a given NSAttributedString.
    ///
    static func convert(string: NSAttributedString) -> String {
        let fullRange = NSRange(location: 0, length: string.length)
        let adjusted = NSMutableAttributedString(attributedString: string)
        adjusted.enumerateAttribute(.attachment, in: fullRange, options: .reverse) { (value, range, _) in
            guard let attachment = value as? SPTextAttachment else {
                return
            }

            let markdown = attachment.isChecked ? checked : unchecked
            adjusted.replaceCharacters(in: range, with: markdown)
        }

        return adjusted.string
    }
}
