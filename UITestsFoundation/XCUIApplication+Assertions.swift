import XCTest

extension XCUIApplication {

    public func assertLabelExists(
        withText text: String,
        timetout: TimeInterval = 5.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertTrue(
            staticTexts[text].waitForExistence(timeout: timetout),
            #"Label with text "\#(text)" NOT found"#,
            file: file,
            line: line
        )
    }
}
