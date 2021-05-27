import XCTest
@testable import Simplenote

class UIColorSimplenoteTests: XCTestCase {
    func testUIColorFromHexStringReturnsCorrectColor() {
        //spBlue20 in RGB is r: 132 g: 164 b: 240
        let spBlue20 = UIColor(hexString: "84a4f0")
        //gray5 in RGB is r: 220 g: 220 b: 222
        let gray5 = UIColor(hexString: "dcdcde")


        let spBlue20RGB = UIColor(red: rgbPercent(132), green: rgbPercent(164), blue: rgbPercent(240), alpha: 1)
        let gray5RGB = UIColor(red: rgbPercent(220), green: rgbPercent(220), blue: rgbPercent(222), alpha: 1)

        XCTAssertEqual(spBlue20, spBlue20RGB)
        XCTAssertEqual(gray5, gray5RGB)
    }

    func rgbPercent(_ value: Double) -> CGFloat {
        return CGFloat(value / 255.0)
    }

    func testUIColorFromHexStringRemovesHashtagIfPresent() {
        //spBlue20 in RGB is r: 132 g: 164 b: 240
        let spBlue20 = UIColor(hexString: "#84a4f0")
        //gray5 in RGB is r: 220 g: 220 b: 222
        let gray5 = UIColor(hexString: "#dcdcde")


        let spBlue20RGB = UIColor(red: rgbPercent(132), green: rgbPercent(164), blue: rgbPercent(240), alpha: 1)
        let gray5RGB = UIColor(red: rgbPercent(220), green: rgbPercent(220), blue: rgbPercent(222), alpha: 1)

        XCTAssertEqual(spBlue20, spBlue20RGB)
        XCTAssertEqual(gray5, gray5RGB)
    }
}
