import XCTest

extension String {

    func strippingUnicodeObjectReplacementCharacter() -> String {
        replacingOccurrences(of: "\u{fffc}", with: "")
    }
}
