import XCTest

private var stepIndex = 0

func attemptLogOut() -> Bool {
    let allNotesNavBar = app.navigationBars[uidNavBar_AllNotes]
    var loggedOut: Bool = false

    if allNotesNavBar.exists {
        loggedOut = logOut()
    } else {
        loggedOut = true
    }

    return loggedOut
}

func logOut() -> Bool {
    app.navigationBars[uidNavBar_AllNotes].buttons[uidButton_Menu].tap()
    app.tables.staticTexts[uidCell_Settings].tap()
    app.tables.staticTexts[uidButton_Settings_LogOut].tap()
    return app.buttons[uidButton_LogIn].waitForExistence(timeout: maxLoadTimeout)
}

func trackTest(_ function: String = #function) {
    print("> Test: \(function)")
    stepIndex = 1
}

func trackStep() {
    print(">> Step " + String(stepIndex))
    stepIndex += 1
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
        app.tables.cells[noteName].buttons[uidButton_NoteCell_Trash].tap()
    }
}

class WebView {

    class func tapDone() {
        app.buttons[uidButton_Done].tap()
    }
}

class WebViewAssert {

    class func textShownOnScreen(textToFind: String) {
        let textPredicate = NSPredicate(format: "label MATCHES '" + textToFind + "'")
        let staticText = app.staticTexts.element(matching: textPredicate)

        XCTAssertTrue(staticText.exists, "\"" + textToFind + textNotFoundInWebView)
    }
}
