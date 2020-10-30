import Foundation


// MARK: - Note
//
extension Note {

    /// Indicates if the receiver is a blank document
    ///
    @objc
    var isBlank: Bool {
        objectID.isTemporaryID && content?.count == .zero && tagsArray?.count == .zero
    }

    /// Returns the Creation / Modification date for a given SortMode
    ///
    func date(for sortMode: SortMode) -> Date? {
        switch sortMode {
        case .alphabeticallyAscending, .alphabeticallyDescending:
            return nil

        case .createdNewest, .createdOldest:
            return creationDate

        case .modifiedNewest, .modifiedOldest:
            return modificationDate
        }
    }

    /// Returns the collection user emails with who we're sharing this document
    ///
    var emailTags: [String] {
        guard let tags = tagsArray as? [String] else {
            return []
        }

        return tags.filter {
            $0.isValidEmailAddress
        }
    }
}

// MARK: - Content
//
extension Note {

    /// Range of title in content
    ///
    var titleRange: NSRange {
        guard let content = content else {
            return NSRange(location: NSNotFound, length: 0)
        }

        let nsContent = content as NSString
        let fullRange = nsContent.fullRange

        let firstCharacterRange = nsContent.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines.inverted,
                                                           options: [],
                                                           range: fullRange)
        guard firstCharacterRange.location != NSNotFound else {
            return firstCharacterRange
        }

        let newlineSearchRange = NSRange(location: firstCharacterRange.location,
                                         length: fullRange.length - firstCharacterRange.location)
        let newlineRange = nsContent.rangeOfCharacter(from: .newlines, options: [], range: newlineSearchRange)

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

        let nsContent = content as NSString
        let fullRange = nsContent.fullRange

        let untrimmedBodyRange = NSRange(location: NSMaxRange(titleRange),
                                         length: fullRange.length - NSMaxRange(titleRange))

        let firstCharacterRange = nsContent.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines.inverted,
                                                             options: [],
                                                             range: untrimmedBodyRange)
        guard firstCharacterRange.location != NSNotFound else {
            return firstCharacterRange
        }

        return NSRange(location: firstCharacterRange.location,
                       length: content.fullRange.length - firstCharacterRange.location)
    }
}
