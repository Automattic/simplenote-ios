import XCTest
@testable import Simplenote


// MARK: - NSString Simplenote Tests
//
class NSStringSimplenoteTests: XCTestCase {

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
        let sampleD = NSString(stringLiteral: "\u{0065}\u{0301}")
        let sampleE = NSString(stringLiteral: "\u{00E9}")

        testNonEqualStringsCreateSameHash([sampleA, sampleB, sampleC])
        testNonEqualStringsCreateSameHash([sampleD, sampleE])
    }
}

extension NSStringSimplenoteTests {
    func testNonEqualStringsCreateSameHash(_ samples: [NSString]) {
        var count = 0
        
        while count + 1 < samples.count {
            var testCount = count + 1
            while testCount < samples.count {
                XCTAssertNotEqual(samples[count], samples[testCount])
                XCTAssertEqual(samples[count].byEncodingAsTagHash, samples[testCount].byEncodingAsTagHash)
                testCount += 1
            }
            count += 1
        }
    }
}
