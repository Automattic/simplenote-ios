import XCTest

class History {

    class func close() {
        guard app.staticTexts[UID.Button.restoreNote].waitForExistence(timeout: minLoadTimeout) else { return }
        app.buttons[UID.Button.dismissHistory].tap()
    }

    class func setSliderPosition(position: CGFloat) {
        app.sliders.element.adjust(toNormalizedSliderPosition: position)
    }

    class func restoreNote() {
        app.buttons[UID.Button.restoreNote].tap()
    }
}

class HistoryAssert {
    class func historyShown() {
        HistoryAssert.historyExistence(shouldExist: true, errorMessage: buttonNotFound)
    }

    class func historyDismissed() {
        HistoryAssert.historyExistence(shouldExist: false, errorMessage: buttonNotAbsent)
    }

    class func historyExistence(shouldExist: Bool, errorMessage: String) {
        let dismissHistoryButton = app.buttons[UID.Button.dismissHistory]
        let restoreNoteButton = app.buttons[UID.Button.restoreNote]

        XCTAssertEqual(dismissHistoryButton.waitForExistence(timeout: minLoadTimeout),
                       shouldExist,
                       UID.Button.dismissHistory + errorMessage)
        XCTAssertEqual(restoreNoteButton.waitForExistence(timeout: minLoadTimeout),
                       shouldExist,
                       UID.Button.restoreNote + errorMessage)
    }

    class func restoreButtonIsDisabled() {
        let restoreNoteButton = app.buttons[UID.Button.restoreNote]

        XCTAssertFalse(restoreNoteButton.isEnabled)
    }

    class func restoreButtonIsEnabled() {
        let restoreNoteButton = app.buttons[UID.Button.restoreNote]

        XCTAssertTrue(restoreNoteButton.isEnabled)
    }
}
