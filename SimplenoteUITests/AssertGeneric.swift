import XCTest

let notFoundEnding = " NOT found",
    notAbsentEnding = " NOT absent"

let labelNotFound = " label" + notFoundEnding,
    labelNotAbsent = " label" + notAbsentEnding

let minLoadTimeout = 5.0

class Assert {

    class func labelExists(labelText: String) {
        XCTAssertTrue(app.staticTexts[labelText].waitForExistence(timeout: minLoadTimeout), labelText + labelNotFound)
    }

    class func labelAbsent(labelText: String) {
        XCTAssertFalse(app.staticTexts[labelText].waitForExistence(timeout: minLoadTimeout), labelText + labelNotAbsent)
    }
}
