import XCTest

// Credits to https://github.com/onmyway133/blog/issues/628
extension XCUIElementQuery: Sequence {

    public typealias Iterator = AnyIterator<XCUIElement>

    public func makeIterator() -> Iterator {

        var index = UInt(0)

        return AnyIterator {
            guard index < self.count else { return nil }

            let element = self.element(boundBy: Int(index))
            index += 1
            return element
        }
    }
}
