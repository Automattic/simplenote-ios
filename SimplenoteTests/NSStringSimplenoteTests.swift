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

    /// Verifies that `byEncodingAsTagHash` effectively escapes special characters
    ///
    func testByEncodingAsTagHashEncodesAllOfSpecialCharacters() {
        let string = String("TáßvĒёи兔子@#$%^&*+-=_`~/?., ><{}[]\\()\"|':;")
        let hash = string.byEncodingAsTagHash
        let expected = "t%C3%A1%C3%9Fv%C4%93%D1%91%D0%B8%E5%85%94%E5%AD%90%40%23%24%25%5E%26%2A%2B%2D%3D%5F%60%7E%2F%3F%2E%2C%20%3E%3C%7B%7D%5B%5D%5C%28%29%22%7C%27%3A%3B"

        XCTAssertEqual(hash, expected)
    }

    /// Verifies that `byEncodingAsTagHash` allows us to properly compare Unicode Strings that would otherwise evaluate as not equal.
    /// Although our (three) sample strings yield the exact same character`ṩ`, regular `isEqualString` API returns `false`.
    ///
    /// By relying on `byEncodingAsTagHash` we can properly identify matching strings.
    ///
    /// - Note: When using the `Swift.String` class, the same comparison is actually correct.
    ///
    func testNonEqualStringsCreateSameHash() {
        let differentStringsOneHashSamples = [
            ["\u{0073}\u{0323}\u{0307}", "\u{0073}\u{0307}\u{0323}", "\u{1E69}"], // ṩ
            ["\u{0065}\u{0301}", "\u{00E9}"] // é
        ]

        for sample in differentStringsOneHashSamples {
            testNonEqualStringsCreateSameHash(sample)
        }
    }
}

extension NSStringSimplenoteTests {
    private func testNonEqualStringsCreateSameHash(_ samples: [String]) {
        let sampleToTest = samples[0]

        for i in 1..<samples.count {
            XCTAssertNotEqual((sampleToTest as NSString), (samples[i] as NSString))
            XCTAssertEqual(sampleToTest.byEncodingAsTagHash, samples[i].byEncodingAsTagHash)
        }
    }
}
