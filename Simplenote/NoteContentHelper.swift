import Foundation

// MARK: - NoteContentHelper
//
struct NoteContentHelper {

    private init() {

    }

    /// Returns structure of the content: range of title and body
    ///
    /// - Parameters:
    ///     - content: note content
    ///
    static func structure(of content: String?) -> (title: NSRange, body: NSRange) {
        let titleRange = self.titleRange(in: content)
        return (
            title: titleRange,
            body: bodyRange(in: content, titleRange: titleRange)
        )
    }

    private static func titleRange(in content: String?) -> NSRange {
        guard let content = content else {
            return NSRange(location: NSNotFound, length: 0)
        }
        let fullRange = content.nsString.fullRange

        // Look for the first character ignoring whitespaces and newlines
        let firstCharacterRange = content.nsString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines.inverted,
                                                                    options: [],
                                                                    range: fullRange)
        guard firstCharacterRange.location != NSNotFound else {
            return firstCharacterRange
        }

        // Look for the next newline
        let newlineSearchRange = NSRange(location: firstCharacterRange.location,
                                         length: fullRange.length - firstCharacterRange.location)
        let newlineRange = content.nsString.rangeOfCharacter(from: .newlines,
                                                             options: [],
                                                             range: newlineSearchRange)
        guard newlineRange.location != NSNotFound else {
            return newlineSearchRange
        }

        return rangeByTrimmingTrailingWhitespacesAndNewlines(in: content,
                                                             firstCharacterLocation: firstCharacterRange.location,
                                                             endRangeLocation: newlineRange.location)
    }

    private static func bodyRange(in content: String?, titleRange: NSRange) -> NSRange {
        guard titleRange.location != NSNotFound, let content = content else {
            return titleRange
        }

        let fullRange = content.nsString.fullRange

        // Look for the first character after title
        let untrimmedBodyRange = NSRange(location: NSMaxRange(titleRange),
                                         length: fullRange.length - NSMaxRange(titleRange))
        let firstCharacterRange = content.nsString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines.inverted,
                                                                    options: [],
                                                                    range: untrimmedBodyRange)
        guard firstCharacterRange.location != NSNotFound else {
            return firstCharacterRange
        }

        return rangeByTrimmingTrailingWhitespacesAndNewlines(in: content,
                                                             firstCharacterLocation: firstCharacterRange.location,
                                                             endRangeLocation: content.fullRange.length)
    }

    private static func rangeByTrimmingTrailingWhitespacesAndNewlines(in content: String, firstCharacterLocation: Int, endRangeLocation: Int) -> NSRange {
        // Look for the last character
        let lastCharacterSearchRange = NSRange(location: firstCharacterLocation,
                                               length: endRangeLocation - firstCharacterLocation)
        let lastCharacterRange = content.nsString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines.inverted,
                                                                   options: [.backwards],
                                                                   range: lastCharacterSearchRange)
        guard lastCharacterRange.location != NSNotFound else {
            return lastCharacterRange
        }

        return NSRange(location: firstCharacterLocation,
                       length: (lastCharacterRange.location + 1) - firstCharacterLocation)
    }
}
