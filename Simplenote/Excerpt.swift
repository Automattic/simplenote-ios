import Foundation

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
