import XCTest
@testable import Simplenote


// MARK: - NSString Simplenote Tests
//
class NSStringSimplenoteTests: XCTestCase {

    /// Verifies that `substringUpToFirstSpace` returns the unmodified string, whenever there are no actual spaces.
    ///
    func testSubstringUpToFirstSpaceReturnsTheUnmodifiedStringWhenThereAreNoSpaces() {
        let sample = "1234567890!@#$%^&*()-_+[]';./,qwertyuiop"
        XCTAssertEqual(sample.substringUpToFirstSpace, sample)
    }

    /// Verifies that `substringUpToFirstSpace` returns the actual substring "before" the first space
    ///
    func testSubstringUpToFirstSpaceReturnsTheSubstringContainedBeforeTheFirstSace() {
        let textBeforeSpace = "1234567890!@#$%^&*()-_+[]';./,qwertyuiop"
        let sample = textBeforeSpace + .space + "1234" + .space + "67890"
        XCTAssertEqual(sample.substringUpToFirstSpace, textBeforeSpace)
    }

    /// Verifies that `byEncodingAsTagHash` effectively escapes all of the non alphanumeric characters
    ///
    func testByEncodingAsTagHashEncodesAllOfTheNonAlphanumericCharactersInTheReceiver() {
        let sample = "1234567890!@#$%^&*()-_+[]';./,qwertyuiopasdfghjkl;'zxcvbnm,./🔥😂😃🤪👍🦆🏴‍☠️☝️😯"
        let encoded = sample.byEncodingAsTagHash
        let escapedSet = CharacterSet(charactersIn: encoded)
        let expectedSet = CharacterSet(charactersIn: "%").union(.alphanumerics)

        XCTAssertTrue(expectedSet.isSuperset(of: escapedSet))
    }

    /// Verifies that `byEncodingAsTagHash` allows us to properly compare Unicode Strings that would otherwise evaluate as not equal.
    /// Although our (three) sample strings yield the exact same character`ṩ`, regular `isEqualString` API returns `false`.
    ///
    /// By relying on `byEncodingAsTagHash` we can properly identify matching strings.
    ///
    /// - Note: When using the `Swift.String` class, the same comparison is actually correct.
    ///
    func testByEncodingTagAsHashAllowsUsToProperlyCompareStringsThatEvaluateAsNotEqualOtherwise() {
        let sampleA = NSString(stringLiteral: "\u{0073}\u{0323}\u{0307}")
        let sampleB = NSString(stringLiteral: "\u{0073}\u{0307}\u{0323}")
        let sampleC = NSString(stringLiteral: "\u{1E69}")

        let hashA = sampleA.byEncodingAsTagHash
        let hashB = sampleB.byEncodingAsTagHash
        let hashC = sampleC.byEncodingAsTagHash

        XCTAssertNotEqual(sampleA, sampleB)
        XCTAssertNotEqual(sampleA, sampleC)
        XCTAssertNotEqual(sampleB, sampleC)

        XCTAssertEqual(hashA, hashB)
        XCTAssertEqual(hashA, hashC)
        XCTAssertEqual(hashB, hashC)
    }
}
