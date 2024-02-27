import XCTest
@testable import Simplenote

// MARK: - String Content Slice Tests
//
class StringContentSliceTests: XCTestCase {
    private let sampleExcerpt = "Download the latest version of Simplenote and you’ll be able to insert links from one note into another note to easily organize and cross-reference information."

    private lazy var sample = """
        Excited to announce that one of our most frequently-requested features, the ability to link to a note from within änóThêR note, is now available.

        \(sampleExcerpt)

        Internal note links begin with simplenote:// instead of the usual https:// prefix, which lets the app know that it should load up a different note within the editor.
    """

    private lazy var sampleExcerptRange = sample.range(of: sampleExcerpt)!

    /// Providing empty keywords will return nil
    ///
    func testProvidingEmptyKeywordsReturnsNil() {
        XCTAssertNil(sample.contentSlice(matching: []))
    }

    /// When no matches are found, return nil
    ///
    func testNoMatchesReturnsNil() {
        XCTAssertNil(sample.contentSlice(matching: ["abcdef"]))
    }

    /// Test that all matches of a given keyword are found
    ///
    func testAllMatchesOfAGivenKeywordAreFound() {
        let expected = ContentSlice(content: sample,
                                    range: sample.fullRange,
                                    matches: sample.ranges(of: "Simplenote"))
        let actual = sample.contentSlice(matching: ["Simplenote"])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(actual?.matches.count, 2)
    }

    /// Test that returned ranges are for full words, even when keywords are substrings
    ///
    func testMatchedRangesAreFullWords() {
        let expected = ContentSlice(content: sample,
                                    range: sample.fullRange,
                                    matches: sample.ranges(of: "Simplenote"))
        let actual = sample.contentSlice(matching: ["mplen"])
        XCTAssertEqual(actual, expected)
    }

    /// Test that by providing range matching is limited to that range
    ///
    func testProvidingRangeWillLimitMatching() {
        let expected = ContentSlice(content: sample,
                                    range: sampleExcerptRange,
                                    matches: [sample.range(of: "Simplenote")!])
        let actual = sample.contentSlice(matching: ["Simplenote"], in: sampleExcerptRange)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(actual?.matches.count, 1)
    }

    /// Test that using leading and trailing limit doesn't cut half word
    ///
    func testLeadingAndTrailingLimitUsesFullWords() {
        let expectedRange = sample.range(of: "version of Simplenote and you’ll")!
        let expected = ContentSlice(content: sample,
                                    range: expectedRange,
                                    matches: [sample.range(of: "Simplenote")!])
        let actual = sample.contentSlice(matching: ["Simplenote"], leadingLimit: 15, trailingLimit: 12)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(actual?.matches.count, 1)
    }

    /// Test that matching is case and diactric insensitive
    ///
    func testMatchingIsCaseAndDiactricInsensitive() {
        let expected = ContentSlice(content: sample,
                                    range: sample.fullRange,
                                    matches: sample.ranges(of: "another"))
        let actual = sample.contentSlice(matching: ["âńotHer"])
        XCTAssertEqual(actual, expected)
    }

    /// Test that all provided keywords are used for matching
    ///
    func testMatchingMultipleKeywords() {
        let keywords = ["Excited", "instead", "editor"]
        let expectedRanges = keywords.map {
            sample.range(of: $0)!
        }

        let expected = ContentSlice(content: sample,
                                    range: sample.fullRange,
                                    matches: expectedRanges)
        let actual = sample.contentSlice(matching: keywords)
        XCTAssertEqual(actual, expected)
    }
}

private extension String {
    func ranges(of substring: String) -> [Range<Index>] {
        var ranges: [Range<Index>] = []
        while let range = range(of: substring, options: [.caseInsensitive, .diacriticInsensitive], range: (ranges.last?.upperBound ?? startIndex)..<endIndex, locale: nil) {
            ranges.append(range)
        }
        return ranges
    }
}
