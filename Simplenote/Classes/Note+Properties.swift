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

// MARK: - Previews
//
extension Note {

    /// Create title and body previews from content
    @objc
    func createPreview() {
        let (titleRange, bodyRange) = NoteContentHelper.structure(of: content)

        titlePreview = titlePreview(with: titleRange)
        bodyPreview = bodyPreview(with: bodyRange)

        updateTagsArray()
    }

    private func titlePreview(with range: Range<String.Index>?) -> String {
        guard let range = range, let content = content else {
            return NSLocalizedString("New note...", comment: "Empty Note Placeholder")
        }

        let result = String(content[range])
        return result.droppingPrefix(Constants.titleMarkdownPrefix)
    }

    private func bodyPreview(with range: Range<String.Index>?) -> String? {
        guard let range = range, let content = content else {
            return nil
        }

        let upperBound = content.index(range.lowerBound, offsetBy: Constants.bodyPreviewCap, limitedBy: range.upperBound) ?? range.upperBound
        let cappedRange = range.lowerBound..<upperBound

        return String(content[cappedRange]).replacingNewlinesWithSpaces()
    }
}

// MARK: - Constants
//
private struct Constants {
    static let titleMarkdownPrefix = "# "
    static let bodyPreviewCap = 500
}
