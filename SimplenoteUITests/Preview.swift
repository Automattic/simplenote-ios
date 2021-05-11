import UITestHelpers
import XCTest

class Preview {

    class func getText() -> String {
        // swiftlint:disable:next force_cast
        return app.webViews.descendants(matching: .staticText).element.value as! String
    }

    class func getAllStaticTexts() -> XCUIElementQuery {
        return app.webViews.descendants(matching: .staticText)
    }

    class func leavePreviewViaBackButton() {
        let backButton = app.navigationBars[UID.NavBar.noteEditorPreview].buttons[UID.Button.back]
        guard backButton.exists else { return }

        backButton.tap()
    }

    class func tapLink(linkText: String) {
        // Should be replaced with proper way to determine if page is loaded
        let link = app.descendants(matching: .link).element(matching: .link, identifier: linkText)
        link.tap()
        sleep(3)
    }

    class func getStaticTextsWithExactValueCount(value: String) -> Int {
        let predicate = NSPredicate(format: "value == '" + value + "'")
        let matchingStaticTexts = app.webViews.descendants(matching: .staticText).matching(predicate)
        let matches = matchingStaticTexts.count
        print(">>> Found \(matches) StaticTexts(s) with '\(value)' value")
        return matches
    }

    class func getStaticTextsWithExactLabelCount(label: String) -> Int {
        let predicate = NSPredicate(format: "label == '" + label + "'")
        let matchingStaticTexts = app.webViews.descendants(matching: .staticText).matching(predicate)
        let matches = matchingStaticTexts.count
        print(">>> Found \(matches) StaticTexts(s) with '\(label)' label")
        return matches
    }
}

class PreviewAssert {

    class func linkShown(linkText: String) {
        let linkPredicate = NSPredicate(format: "label == '" + linkText + "'")
        let link = app.links.element(matching: linkPredicate)

        XCTAssertTrue(link.exists, "\"" + linkText + linkNotFoundInPreview)
    }

    class func previewShown() {
        let previewNavBar = app.navigationBars[UID.NavBar.noteEditorPreview]

        XCTAssertTrue(
            previewNavBar.waitForExistence(timeout: minLoadTimeout),
            UID.NavBar.noteEditorPreview + navBarNotFound
        )
        XCTAssertTrue(
            previewNavBar.buttons[UID.Button.back].waitForExistence(timeout: minLoadTimeout),
            UID.Button.back + buttonNotFound
        )
        XCTAssertTrue(
            previewNavBar.staticTexts[UID.Text.noteEditorPreview].waitForExistence(timeout: minLoadTimeout),
            UID.Text.noteEditorPreview + labelNotFound
        )
    }

    class func wholeTextShown(text: String) {
        XCTAssertEqual(text, Preview.getText(), "Preview text" + notExpectedEnding)
    }

    class func staticTextWithExactLabelShownOnce(label: String) {
        let matches = Preview.getStaticTextsWithExactLabelCount(label: label)
        XCTAssertEqual(matches, 1)
    }

    class func staticTextWithExactValueShownOnce(value: String) {
        let matches = Preview.getStaticTextsWithExactValueCount(value: value)
        XCTAssertEqual(matches, 1)
    }

    class func staticTextWithExactValuesShownOnce(values: [String]) {
        for value in values {
            PreviewAssert.staticTextWithExactValueShownOnce(value: value)
        }
    }

    class func boxesTotalNumber(expectedSwitchesNumber: Int) {
        XCTAssertEqual(expectedSwitchesNumber, app.switches.count, numberOfBoxesInPreviewNotExpected)
    }

    class func boxesStates(expectedCheckedBoxesNumber: Int, expectedEmptyBoxesNumber: Int) {
        let expectedBoxesCount = expectedCheckedBoxesNumber + expectedEmptyBoxesNumber
        let boxes = app.switches
        let actualBoxesCount = boxes.count
        print(">>> Number of boxes found: \(actualBoxesCount)")
        XCTAssertEqual(actualBoxesCount, expectedBoxesCount, numberOfBoxesInPreviewNotExpected)

        guard actualBoxesCount > 0 else { return }
        let actualCheckedBoxesCount = boxes.filter { $0.value.debugDescription == "Optional(1)" }.count
        let actualEmptyBoxesCount = boxes.filter { $0.value.debugDescription == "Optional(0)" }.count

        XCTAssertEqual(actualCheckedBoxesCount, expectedCheckedBoxesNumber, numberOfCheckedBoxesInPreviewNotExpected)
        XCTAssertEqual(actualEmptyBoxesCount, expectedEmptyBoxesNumber, numberOfEmptyBoxesInPreviewNotExpected)
    }
}
