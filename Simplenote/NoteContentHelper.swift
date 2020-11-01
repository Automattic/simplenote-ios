import Foundation

struct NoteContentHelper {
    let content: String?

    /// Range of title in content
    ///
    var titleRange: NSRange {
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

        return NSRange(location: firstCharacterRange.location,
                       length: newlineRange.location - firstCharacterRange.location)
    }

    /// Range of body in content
    ///
    var bodyRange: NSRange {
        let titleRange = self.titleRange
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

        return NSRange(location: firstCharacterRange.location,
                       length: content.fullRange.length - firstCharacterRange.location)
    }
}
