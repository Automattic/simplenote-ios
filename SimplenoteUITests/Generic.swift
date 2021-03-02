import XCTest

let app = XCUIApplication()
private var stepIndex = 0

func attemptLogOut() -> Bool {
    let allNotesNavBar = app.navigationBars[UID.NavBar.allNotes]
    var loggedOut: Bool = false

    if allNotesNavBar.exists {
        loggedOut = logOut()
    } else {
        loggedOut = true
    }

    return loggedOut
}

func logOut() -> Bool {
    Sidebar.open()
    Sidebar.getButtonSettings().tap()
    app.tables.staticTexts[UID.Button.settingsLogOut].tap()
    return app.buttons[UID.Button.logIn].waitForExistence(timeout: maxLoadTimeout)
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

    class func getVisibleLabelledCellsNumber() -> Int {
        // We need only the table cells that have X = 0 and a non-empty label
        // otherwise we will include invisible elements from Sidebar pane, when Notes List is open
        // or the elements from Notes List when Settings are open
        // or the visible tags search suggestions
        let cellsNum = app.tables.element.children(matching: .cell).count
        var matchesNum: Int = 0
        guard cellsNum > 0 else { return matchesNum }

        for index in 0...cellsNum - 1 {
            let cell = app.tables.cells.element(boundBy: index)
            if cell.frame.minX == 0.0 && cell.label.count > 0 {
                matchesNum += 1
            }
        }

        return matchesNum
    }

    class func getVisibleNonLabelledCellsNumber() -> Int {
        // We need only the table cells that have X = 0 and an empty label
        // Currently (besides using object dimentions) this is the way to
        // locate tags search suggestions
        let cellsNum = app.tables.element.children(matching: .cell).count
        var matchesNum: Int = 0
        guard cellsNum > 0 else { return matchesNum }

        for index in 0...cellsNum - 1 {
            let cell = app.tables.cells.element(boundBy: index)
            if cell.frame.minX == 0.0 && cell.label.count == 0 {
                matchesNum += 1
            }
        }

        return matchesNum
    }

    class func trashCell(noteName: String) {
        Table.getCell(label: noteName).swipeLeft()
        sleep(1)
        Table.getCell(label: noteName).buttons[UID.Button.itemTrash].tap()
    }

    class func getCell(label: String) -> XCUIElement {
        let cell = app.tables.cells[label]
        return cell
    }

    class func getCellsWithExactLabelCount(label: String) -> Int {
        let predicate = NSPredicate(format: "label == '" + label + "'")
        let matchingCells = app.cells.matching(predicate)
        let matchesCount = matchingCells.count
        print(">>> Found " + String(matchesCount) + " Cell(s) with '" + label + "' label")
        return matchesCount
    }

    class func getStaticTextsWithExactLabelCount(label: String) -> Int {
        let predicate = NSPredicate(format: "label == '" + label + "'")
        let table = app.tables
        print(table.debugDescription)
        let matchingCells = app.tables.staticTexts.matching(predicate)
        let matchesCount = matchingCells.count
        print(">>> Found " + String(matchesCount) + " StaticText(s) with '" + label + "' label")
        return matchesCount
    }

    class func getContentOfCell(noteName: String) -> String? {
        let cell = Table.getCell(label: noteName)
        guard cell.exists else { return "" }

        // We need to find a child element of the cell from above,
        // a static text that has a content different from note name -
        // this is the one we need.
        let predicate = NSPredicate(format: "label != '" + noteName + "'")
        let staticTextWithContent = cell.staticTexts.element(matching: predicate)
        guard staticTextWithContent.exists else { return .none }

        return staticTextWithContent.label
    }
}

class WebView {

    class func tapDone() {
        let doneButton = app.buttons[UID.Button.done]
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

        let confirmPredicate = NSPredicate(format: "label == '" + UID.Button.accept + "' || label == 'AnythingElse'")
        let confirmationButton = alert.buttons.element(matching: confirmPredicate)
        guard confirmationButton.exists else { return }

        confirmationButton.tap()
    }
}
