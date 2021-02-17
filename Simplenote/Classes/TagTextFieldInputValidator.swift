import Foundation

// MARK: - TagTextFieldInputValidator
//
struct TagTextFieldInputValidator {
    private var disallowedCharacterSet: CharacterSet {
        get {
            var whitespaceCharset = CharacterSet.whitespacesAndNewlines
            whitespaceCharset.insert(",")
            return whitespaceCharset
        }
    }

    /// Validation Result
    ///
    enum Result: Equatable {
        case valid
        case invalid
        case endingWithDisallowedCharacter(_ trimmedTag: String)
    }

    /// Validate text field input
    ///
    func validateInput(originalText: String, range: Range<String.Index>, replacement: String) -> Result {
        var isEndingWithDisallowedCharacter = false

        if let disallowedCharacterRange = replacement.rangeOfCharacter(from: disallowedCharacterSet) {
            if disallowedCharacterRange.upperBound == replacement.endIndex,
               range.upperBound == originalText.endIndex {
                isEndingWithDisallowedCharacter = true
            } else {
                return .invalid
            }
        }

        var tag = originalText.replacingCharacters(in: range, with: replacement)
        if isEndingWithDisallowedCharacter {
            tag = tag.trimmingCharacters(in: disallowedCharacterSet)
        }

        if validateLength(tag: tag) {
            if isEndingWithDisallowedCharacter {
                return .endingWithDisallowedCharacter(tag)
            }
            return .valid
        }

        return .invalid
    }

    /// Trim disallowed characters and return the first part before whitespace or newline
    ///
    func preprocessForPasting(tag: String) -> String? {
        return tag.components(separatedBy: disallowedCharacterSet)
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
