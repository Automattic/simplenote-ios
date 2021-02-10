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

    /// Validate text field input
    ///
    func validateInput(originalText: String, range: Range<String.Index>, replacement: String) -> Result {
        var charset = CharacterSet.whitespacesAndNewlines
        charset.insert(",")

        var isEndingWithWhitespace = false

        if let whitespaceRange = replacement.rangeOfCharacter(from: charset) {
            if whitespaceRange.upperBound == replacement.endIndex,
               range.upperBound == originalText.endIndex {
                isEndingWithWhitespace = true
            } else {
                return .invalid
            }
        }

        var tag = originalText.replacingCharacters(in: range, with: replacement)
        if isEndingWithWhitespace {
            tag = tag.trimmingCharacters(in: charset)
        }

        if validateLength(tag: tag) {
            if isEndingWithWhitespace {
                return .endingWithWhitespace(tag)
            }
            return .valid
        }

        return .invalid
    }

    /// Trim whitespaces and return the first part before whitespace or newline
    ///
    func preprocessForPasting(tag: String) -> String? {
        return tag.components(separatedBy: .whitespacesAndNewlines)
            .filter({ !$0.isEmpty })
            .first
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
