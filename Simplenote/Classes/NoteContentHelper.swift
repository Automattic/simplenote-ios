import Foundation

// MARK: - NoteContentHelper
//
enum NoteContentHelper {

    /// Returns structure of the content: range of title and body
    ///
    /// - Parameters:
    ///     - content: note content
    ///
    static func structure(of content: String?) -> (title: Range<String.Index>?, body: Range<String.Index>?) {
        guard let content = content, !content.isEmpty else {
            return (title: nil, body: nil)
        }

        guard let titleRange = trimmedTextRange(in: content, startingFrom: content.startIndex, endAtNewline: true) else {
            return (title: nil, body: nil)
        }

        let bodyRange = trimmedTextRange(in: content, startingFrom: titleRange.upperBound, endAtNewline: false)

        return (title: titleRange, body: bodyRange)
    }

    private static func trimmedTextRange(in content: String, startingFrom startLocation: String.Index, endAtNewline: Bool) -> Range<String.Index>? {
        guard let firstCharacterLocation = content.locationOfFirstCharacter(from: CharacterSet.whitespacesAndNewlines.inverted,
                                                                            startingFrom: startLocation) else {
            return nil
        }

        let endRangeLocation: String.Index = {
            if !endAtNewline {
                return content.endIndex
            }

            // Look for the next newline
            let newlineLocation = content.locationOfFirstCharacter(from: CharacterSet.newlines,
                                                                   startingFrom: firstCharacterLocation)

            return newlineLocation ?? content.endIndex
        }()

        guard let lastCharacterLocation = content.locationOfFirstCharacter(from: CharacterSet.whitespacesAndNewlines.inverted,
                                                                           startingFrom: endRangeLocation,
                                                                           backwards: true) else {
            return nil
        }

        return firstCharacterLocation..<content.index(after: lastCharacterLocation)
    }
}
