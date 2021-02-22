import XCTest

private var stepIndex = 0

func attemptLogOut() -> Bool {
    let allNotesNavBar = app.navigationBars[UID.NavBar.AllNotes]
    var loggedOut: Bool = false

    if allNotesNavBar.exists {
        loggedOut = logOut()
    } else {
        loggedOut = true
    }

    return loggedOut
}

func logOut() -> Bool {
    app.navigationBars[UID.NavBar.AllNotes].buttons[UID.Button.Menu].tap()
    app.tables.staticTexts[UID.Cell.Settings].tap()
    app.tables.staticTexts[UID.Button.SettingsLogOut].tap()
    return app.buttons[UID.Button.LogIn].waitForExistence(timeout: maxLoadTimeout)
}

func trackTest(_ function: String = #function) {
    print("> Test: \(function)")
    stepIndex = 1
}

func trackStep() {
    print(">> Step " + String(stepIndex))
    stepIndex += 1
}

func getToAllNotes() {
    WebView.tapDone()
    Preview.leavePreviewViaBackButton()
    NoteEditor.leaveEditor()
}

class Table {

    class func getNotesNumber() -> Int {
        // We need to count only the table cells that have X = 0 (this is a case for notes)
        // Otherwise we will include invisible elements from left pane, which are still found
        let cellsNum = app.tables.element.children(matching: .cell).count
        var notesNum: Int = 0

        if cellsNum == 0 {
            return notesNum
        }

        for index in 0...cellsNum - 1 {
            let cell = app.tables.cells.element(boundBy: index)

            if cell.frame.minX == 0.0 {
                notesNum += 1
            }
        }

        return notesNum
    }

    class func trashNote(noteName: String) {
        app.tables.cells[noteName].swipeLeft()
        sleep(1)
        app.tables.cells[noteName].buttons[UID.Button.NoteCellTrash].tap()
    }
}

class WebView {

    class func tapDone() {
        let doneButton = app.buttons[UID.Button.Done]
        guard doneButton.exists else { return }
        doneButton.tap()
    }
}

class WebViewAssert {

    class func textShownOnScreen(textToFind: String) {
        let textPredicate = NSPredicate(format: "label MATCHES '" + textToFind + "'")
        let staticText = app.staticTexts.element(matching: textPredicate)

        XCTAssertTrue(staticText.exists, "\"" + textToFind + textNotFoundInWebView)
    }
}

class Alert {

    class func closeAny() {
        let alert = app.alerts.element
        guard alert.exists else { return }

        let confirmPredicate = NSPredicate(format: "label == '" + UID.Button.Accept + "' || label == 'AnythingElse'")
        let confirmationButton = alert.buttons.element(matching: confirmPredicate)
        guard confirmationButton.exists else { return }

        confirmationButton.tap()
    }
}
