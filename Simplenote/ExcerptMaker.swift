import Foundation

// MARK: - ExcerptMaker: Generate excerpt from a note with specified keywords
//
final class ExcerptMaker {
    private let leadingLimit: String.IndexDistance
    private let trailingLimit: String.IndexDistance

    init(leadingLimit: String.IndexDistance = 30, trailingLimit: String.IndexDistance = 300) {
        self.leadingLimit = leadingLimit
        self.trailingLimit = trailingLimit
    }

    func excerpt(from content: String,
                 matching keywords: [String],
                 in range: Range<String.Index>? = nil) -> Excerpt {
        let range = range ?? content.startIndex..<content.endIndex

        var leadingWordsRange: [Range<String.Index>] = []
        var matchingWordsRange: [Range<String.Index>] = []
        var trailingWordsRange: [Range<String.Index>] = []

        content.enumerateSubstrings(in: range, options: [.byWords, .localized, .substringNotRequired]) { (_, wordRange, _, stop) in

            if self.trailingLimit > 0, let firstMatch = matchingWordsRange.last {
                if content.distance(from: firstMatch.upperBound, to: wordRange.upperBound) > self.trailingLimit {
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

            if self.leadingLimit > 0 && matchingWordsRange.isEmpty {
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
    func bodyExcerpt(from note: Note, withKeywords keywords: [String]?) -> String? {
        guard let keywords = keywords, !keywords.isEmpty, let content = note.content else {
            return note.bodyPreview
        }

        let bodyRange = NoteContentHelper.structure(of: content).body
        let excerptString = excerpt(from: content, matching: keywords, in: bodyRange).normalized.content
        return excerptString.replacingNewlinesWithSpaces()
    }
}

struct Excerpt {
    let content: String
    let range: Range<String.Index>
    let matches: [Range<String.Index>]

    var nsMatches: [NSRange] {
        return matches.map {
            NSRange($0, in: content)
        }
    }

    init(content: String, range: Range<String.Index>, matches: [Range<String.Index>]) {
        self.content = content
        self.range = range
        self.matches = matches
    }

    var normalized: Excerpt {
        if range.lowerBound == content.startIndex && range.upperBound == content.endIndex {
            return self
        }

        let newContent = String(content[range])
        let newRange = newContent.startIndex..<newContent.endIndex
        let offset = content.distance(from: content.startIndex, to: range.lowerBound)
        let newMatches: [Range<String.Index>] = matches.map {
            let lower = content.index($0.lowerBound, offsetBy: -offset)
            let upper = content.index($0.upperBound, offsetBy: -offset)
            return lower..<upper
        }

        return Excerpt(content: newContent, range: newRange, matches: newMatches)
    }
}
