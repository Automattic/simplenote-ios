import Foundation

// MARK: - ContentSlice
//
struct ContentSlice {
    /// Original content
    ///
    let content: String

    /// Sliced range
    ///
    let range: Range<String.Index>

    /// Ranges of matched words
    ///
    let matches: [Range<String.Index>]

    /// NSRange version of `matches`
    ///
    var nsMatches: [NSRange] {
        return matches.map {
            NSRange($0, in: content)
        }
    }

    /// Constructor
    ///
    init(content: String, range: Range<String.Index>, matches: [Range<String.Index>]) {
        self.content = content
        self.range = range
        self.matches = matches
    }

    /// Return content sliced to the range
    ///
    var normalized: ContentSlice {
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

        return ContentSlice(content: newContent, range: newRange, matches: newMatches)
    }
}
