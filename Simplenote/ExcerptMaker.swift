import Foundation

// MARK: - ExcerptMaker: Generate excerpt from a note with specified keywords
//
final class ExcerptMaker {
    private init() {

    }

    static func excerpt(from content: String,
                 matching keywords: [String],
                 in range: Range<String.Index>? = nil,
                 leadingLimit: String.IndexDistance = Constants.excerptLeadingLimit,
                 trailingLimit: String.IndexDistance = Constants.excerptTrailingLimit) -> Excerpt {
        
        let range = range ?? content.startIndex..<content.endIndex

        var leadingWordsRange: [Range<String.Index>] = []
        var matchingWordsRange: [Range<String.Index>] = []
        var trailingWordsRange: [Range<String.Index>] = []

        content.enumerateSubstrings(in: range, options: [.byWords, .localized, .substringNotRequired]) { (_, wordRange, _, stop) in

            if trailingLimit > 0, let firstMatch = matchingWordsRange.first {
                if content.distance(from: firstMatch.upperBound, to: wordRange.upperBound) > trailingLimit {
                    stop = true
                    return
                }

                trailingWordsRange.append(wordRange)
            }

            for keyword in keywords {
                if content.range(of: keyword, options: [.caseInsensitive, .diacriticInsensitive], range: wordRange, locale: Locale.current) != nil {
                    matchingWordsRange.append(wordRange)
                    break
                }
            }

            if leadingLimit > 0 && matchingWordsRange.isEmpty {
                leadingWordsRange.append(wordRange)
            }
        }

        guard let firstMatch = matchingWordsRange.first, let lastMatch = matchingWordsRange.last else {
            return Excerpt(content: content, range: range, matches: matchingWordsRange)
        }

        let lowerBound: String.Index = {
            if leadingLimit == 0 {
                return range.lowerBound
            }

            let upperBound = firstMatch.lowerBound
            var lowerBound = upperBound

            for range in leadingWordsRange.reversed() {
                if content.distance(from: range.lowerBound, to: upperBound) > leadingLimit {
                    break
                }

                lowerBound = range.lowerBound
            }

            return lowerBound
        }()

        let upperBound: String.Index = {
            if trailingLimit == 0 {
                return range.upperBound
            }
            return trailingWordsRange.last?.upperBound ?? lastMatch.upperBound
        }()

        return Excerpt(content: content, range: lowerBound..<upperBound, matches: matchingWordsRange)
    }
}

extension ExcerptMaker {
    /// Generate and return excerpt from the note. Excerpt is based on keywords
    ///
    static func bodyExcerpt(from note: Note, withKeywords keywords: [String]?) -> String? {
        guard let keywords = keywords, !keywords.isEmpty, let content = note.content else {
            return note.bodyPreview
        }

        guard let bodyRange = NoteContentHelper.structure(of: content).body else {
            return note.bodyPreview
        }
        let excerpt = ExcerptMaker.excerpt(from: content, matching: keywords, in: bodyRange)

        let shouldAddEllipsis = excerpt.range.lowerBound > bodyRange.lowerBound
        let excerptString = (shouldAddEllipsis ? "…" : "") + excerpt.normalized.content

        return excerptString.replacingNewlinesWithSpaces()
    }
}

private struct Constants {
    static let excerptLeadingLimit = 30
    static let excerptTrailingLimit = 300
}
