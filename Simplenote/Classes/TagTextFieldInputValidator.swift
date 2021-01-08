import Foundation

// MARK: - TagTextFieldInputValidator
//
struct TagTextFieldInputValidator {

    /// Validation Result
    ///
    enum Result {
        case valid
        case invalid
        case endingWithWhitespace(_ trimmedTag: String)
    }

    /// Validate a tag
    ///
    func validate(tag: String) -> Result {
        let charset = CharacterSet.whitespacesAndNewlines
        var tag = tag
        var isEndingWithWhitespace = false

        if let whitespaceRange = tag.rangeOfCharacter(from: charset) {
            // Whitespace is not at the end of the tag
            if whitespaceRange.upperBound != tag.endIndex {
                return .invalid
            }

            tag = tag.trimmingCharacters(in: charset)
            isEndingWithWhitespace = true
        }

        if tag.isValidTagName {
            if isEndingWithWhitespace {
                return .endingWithWhitespace(tag)
            }
            return .valid
        }

        return .invalid
    }
}
