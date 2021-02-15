import XCTest

class Preview {

    class func getText() -> String {
        return app.webViews.descendants(matching: .staticText).element.value as! String
    }

    class func leavePreviewViaBackButton() {
        app.navigationBars[uidNavBar_NoteEditor_Preview].buttons[uidButton_Back].tap()
    }

    class func tapLink(linkText: String) {
        // Should be replaced with proper way to determine if page is loaded
        let link = app.descendants(matching: .link).element(matching: .link, identifier: linkText)
        link.tap()
        sleep(3)
    }
}

class PreviewAssert {

    class func linkShown(linkText: String) {
        let linkPredicate = NSPredicate(format: "label MATCHES '" + linkText + "'")
        let link = app.links.element(matching: linkPredicate)

        XCTAssertTrue(link.exists, "\"" + linkText + linkNotFoundInPreview)
    }

    class func previewShown() {
        let previewNavBar = app.navigationBars[uidNavBar_NoteEditor_Preview]

        XCTAssertTrue(previewNavBar.waitForExistence(timeout: minLoadTimeout), uidNavBar_NoteEditor_Preview + navBarNotFound)
        XCTAssertTrue(previewNavBar.buttons[uidButton_Back].waitForExistence(timeout: minLoadTimeout), uidButton_Back + buttonNotFound)
        XCTAssertTrue(previewNavBar.staticTexts[uidText_NoteEditor_Preview].waitForExistence(timeout: minLoadTimeout), uidText_NoteEditor_Preview + labelNotFound)
    }

    class func wholeTextShown(text: String) {
        XCTAssertEqual(text, Preview.getText(), "Preview text" + notExpectedEnding);
    }

    class func substringShown(text: String) {
        let textPredicate = NSPredicate(format: "label MATCHES '" + text + "'")
        let staticText = app.staticTexts.element(matching: textPredicate)

        XCTAssertTrue(staticText.exists, "\"" + text + textNotFoundInPreview)
    }

    class func boxesTotalNumber(expectedSwitchesNumber: Int) {
        XCTAssertEqual(expectedSwitchesNumber, app.switches.count, numberOfBoxesInPreviewNotExpected)
    }

    class func boxesStates(expectedCheckedBoxesNumber: Int, expectedEmptyBoxesNumber: Int) {
        let expectedBoxesCount = expectedCheckedBoxesNumber + expectedEmptyBoxesNumber,
            actualBoxesCount = app.switches.count
        
        var actualCheckedBoxesCount = 0,
            actualEmptyBoxesCount = 0

        print("Number of boxes found: " + String(actualBoxesCount))
        
        XCTAssertEqual(expectedBoxesCount, actualBoxesCount, numberOfBoxesInPreviewNotExpected)
        
        if actualBoxesCount < 1 { return }
        
        for index in 0...actualBoxesCount - 1 {
            let box = app.descendants(matching: .switch).element(boundBy: index)
            print("Current box debug description: " + box.value.debugDescription)

            if box.value.debugDescription == "Optional(1)" {
                actualCheckedBoxesCount += 1
            } else if box.value.debugDescription == "Optional(0)" {
                actualEmptyBoxesCount += 1
            }
        }

        XCTAssertEqual(expectedCheckedBoxesNumber, actualCheckedBoxesCount, numberOfCheckedBoxesInPreviewNotExpected)
        XCTAssertEqual(expectedEmptyBoxesNumber, actualEmptyBoxesCount, numberOfEmptyBoxesInPreviewNotExpected)
    }
}
