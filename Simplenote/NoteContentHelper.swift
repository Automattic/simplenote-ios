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
        guard let content = content, !content.isEmpty else {
            return (title: .notFound, body: .notFound)
        }

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

    private static func trimmedTextRange(in content: String, startingFrom startLocation: Int, endAtNewline: Bool) -> NSRange {
        let fullRange = content.nsString.fullRange

        guard let firstCharacterLocation = content.locationOfFirstCharacter(from: CharacterSet.whitespacesAndNewlines.inverted,
                                                                            startingFrom: startLocation) else {
            return .notFound
        }

        let endRangeLocation: Int = {
            if !endAtNewline {
                return fullRange.length
            }

            // Look for the next newline
            let newlineLocation = content.locationOfFirstCharacter(from: CharacterSet.newlines,
                                                                   startingFrom: firstCharacterLocation)

            return newlineLocation ?? fullRange.length
        }()

        guard let lastCharacterLocation = content.locationOfFirstCharacter(from: CharacterSet.whitespacesAndNewlines.inverted,
                                                                            startingFrom: endRangeLocation,
                                                                            backwards: true) else {
            return .notFound
        }

        return NSRange(location: firstCharacterLocation,
                       length: lastCharacterLocation + 1 - firstCharacterLocation)
    }
}
