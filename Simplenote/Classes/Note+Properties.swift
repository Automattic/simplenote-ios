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
        let noteStructure = NoteContentHelper.structure(of: content)

        titlePreview = titlePreview(with: noteStructure.title)
        bodyPreview = bodyPreview(with: noteStructure.trimmedBody)

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

// MARK: - Excerpt
//
extension Note {

    /// Returns excerpt of the content around the first match of one of the keywords
    ///
    func bodyExcerpt(keywords: [String]?) -> String? {
        guard let keywords = keywords, !keywords.isEmpty, let content = content?.precomposedStringWithCanonicalMapping else {
            return bodyPreview
        }

        guard let bodyRange = NoteContentHelper.structure(of: content).trimmedBody else {
            return nil
        }

        guard let excerpt = content.contentSlice(matching: keywords,
                                                 in: bodyRange,
                                                 leadingLimit: Constants.excerptLeadingLimit,
                                                 trailingLimit: Constants.excerptTrailingLimit) else {
            return bodyPreview
        }

        let shouldAddEllipsis = excerpt.range.lowerBound > bodyRange.lowerBound
        let excerptString = (shouldAddEllipsis ? "…" : "") + excerpt.slicedContent

        return excerptString.replacingNewlinesWithSpaces()
    }
}

// MARK: - Constants
//
private struct Constants {
    /// Markdown prefix to be removed from title preview
    ///
    static let titleMarkdownPrefix = "# "

    /// Limit for body preview
    ///
    static let bodyPreviewCap = 500

    /// Leading limit for body excerpt
    ///
    static let excerptLeadingLimit = 30

    /// Trailing limit for body excerpt
    static let excerptTrailingLimit = 300
}
