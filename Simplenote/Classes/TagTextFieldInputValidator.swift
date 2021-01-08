import Foundation

// MARK: - TagTextFieldInputValidator
//
struct TagTextFieldInputValidator {

    /// Validation Result
    ///
    enum Result: Equatable {
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

        if validateLength(tag: tag) {
            if isEndingWithWhitespace {
                return .endingWithWhitespace(tag)
            }
            return .valid
        }

        return .invalid
    }

    /// Trim whitespaces and replace internal whitespaces with -
    ///
    func sanitize(tag: String) -> String {
        return tag.components(separatedBy: .whitespacesAndNewlines)
            .filter({ !$0.isEmpty })
            .joined(separator: "-")
    }

    /// Indicates if the receivers length is within allowed values
    /// - Important: `Tag.name` is used as the entity's `simperiumKey`, and the backend imposes a length.
    ///              For that reason we must check on the `encoded` lenght (and not the actual raw string length)
    private func validateLength(tag: String) -> Bool {
        tag.byEncodingAsTagHash.count <= Constants.maximumTagLength
    }
}

// MARK: - Constants
//
private struct Constants {
    static let maximumTagLength = 256
}
