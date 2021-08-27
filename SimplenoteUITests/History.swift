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
        let closeHistoryButton = app.buttons[UID.Button.dismissHistory]
        let restoreNoteButton = app.buttons[UID.Button.restoreNote]

        XCTAssertTrue(closeHistoryButton.waitForExistence(timeout: minLoadTimeout), UID.Button.dismissHistory + buttonNotFound)
        XCTAssertTrue(restoreNoteButton.waitForExistence(timeout: minLoadTimeout), UID.Button.restoreNote + buttonNotFound)
    }

    class func historyDismissed() {
        let closeHistoryButton = app.buttons[UID.Button.dismissHistory]

        XCTAssertFalse(closeHistoryButton.exists, UID.Button.dismissHistory + buttonNotFound)
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
