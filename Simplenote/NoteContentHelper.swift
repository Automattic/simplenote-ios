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
        let titleRange = trimmedTextRange(in: content, startingFrom: 0, endAtNewline: true)
        let bodyRange: NSRange
        if titleRange.isNotFound {
            bodyRange = .notFound
        } else {
            bodyRange = trimmedTextRange(in: content, startingFrom: NSMaxRange(titleRange), endAtNewline: false)
        }

        return (
            title: titleRange,
            body: bodyRange
        )
    }

    private static func trimmedTextRange(in content: String?, startingFrom startLocation: Int, endAtNewline: Bool) -> NSRange {
        guard let content = content else {
            return .notFound
        }
        let fullRange = content.nsString.fullRange

        // Look for the first character ignoring whitespaces and newlines
        let firstCharacterSearchRange = NSRange(location: startLocation,
                                                length: fullRange.length - startLocation)
        let firstCharacterRange = content.nsString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines.inverted,
                                                                    options: [],
                                                                    range: firstCharacterSearchRange)
        guard !firstCharacterRange.isNotFound else {
            return .notFound
        }

        let endRangeLocation: Int = {
            if endAtNewline {
                // Look for the next newline
                let newlineSearchRange = NSRange(location: firstCharacterRange.location,
                                                 length: fullRange.length - firstCharacterRange.location)
                let newlineRange = content.nsString.rangeOfCharacter(from: .newlines,
                                                                     options: [],
                                                                     range: newlineSearchRange)
                if !newlineRange.isNotFound {
                    return newlineRange.location
                }
            }

            return fullRange.length
        }()

        return rangeByTrimmingTrailingWhitespacesAndNewlines(in: content,
                                                             firstCharacterLocation: firstCharacterRange.location,
                                                             endRangeLocation: endRangeLocation)
    }

    private static func rangeByTrimmingTrailingWhitespacesAndNewlines(in content: String, firstCharacterLocation: Int, endRangeLocation: Int) -> NSRange {
        // Look for the last character
        let lastCharacterSearchRange = NSRange(location: firstCharacterLocation,
                                               length: endRangeLocation - firstCharacterLocation)
        let lastCharacterRange = content.nsString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines.inverted,
                                                                   options: [.backwards],
                                                                   range: lastCharacterSearchRange)
        guard !lastCharacterRange.isNotFound else {
            return .notFound
        }

        return NSRange(location: firstCharacterLocation,
                       length: (lastCharacterRange.location + 1) - firstCharacterLocation)
    }
}
