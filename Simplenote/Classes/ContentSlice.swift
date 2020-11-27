import Foundation

// MARK: - ContentSlice
//
struct ContentSlice: Equatable {
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

    /// Content sliced to the range
    ///
    var slicedContent: String {
        return String(content[range])
    }

    /// Constructor
    ///
    init(content: String, range: Range<String.Index>, matches: [Range<String.Index>]) {
        self.content = content
        self.range = range
        self.matches = matches
    }
}
