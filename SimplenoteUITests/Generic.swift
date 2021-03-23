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
    print(">> Step \(stepIndex)")
    stepIndex += 1
}

func getToAllNotes() {
    WebView.tapDone()
    Preview.leavePreviewViaBackButton()
    NoteEditor.leaveEditor()
}

class Table {

    class func getAllCells() -> XCUIElementQuery {
        return app.tables.element.children(matching: .cell)
    }

    class func getVisibleLabelledCells() -> [XCUIElement] {
        // We need only the table cells that have X = 0 and a non-empty label
        // Currently (besides using object dimensions) this is the way to
        // locate note cells
        return Table.getAllCells()
            .filter { $0.frame.minX == 0.0 && $0.label.isEmpty == false }
    }

    class func getVisibleLabelledCellsNames() -> [String] {
        return Table.getVisibleLabelledCells().compactMap { $0.label }
    }

    class func getVisibleLabelledCellsNumber() -> Int {
        return Table.getVisibleLabelledCells().count
    }

    class func getVisibleNonLabelledCellsNumber() -> Int {
        // We need only the table cells that have X = 0 and an empty label
        // Currently (besides using object dimentions) this is the way to
        // locate tags search suggestions
        return Table.getAllCells()
            .filter { $0.frame.minX == 0.0 && $0.label.isEmpty == true }
            .count
    }

    class func trashCell(noteName: String) {
        // `Trash Note` and `Delete note forever` buttons have different labels
        // since 07fcccf1039495768ecdf9909d3dbd1b255936cd
        // (https://github.com/Automattic/simplenote-ios/pull/1191).
        // To use the correct label, we need to know where we are.
        let deleteButtonLabel = app.navigationBars[UID.NavBar.trash].exists ?
            UID.Button.itemTrash : UID.Button.noteTrash
        let noteCell = Table.getCell(label: noteName)

        noteCell.swipeLeft()
        noteCell.buttons[deleteButtonLabel].tap()
    }

    class func getCell(label: String) -> XCUIElement {
        let cell = app.tables.cells[label]
        return cell
    }

    class func getStaticText(label: String) -> XCUIElement {
        let staticText = app.tables.staticTexts[label]
        return staticText
    }

    class func getCellsWithExactLabelCount(label: String) -> Int {
        let predicate = NSPredicate(format: "label == '" + label + "'")
        let matchingCells = app.cells.matching(predicate)
        let matches = matchingCells.count
        print(">>> Found \(matches) Cell(s) with '\(label)' label")
        return matches
    }

    class func getStaticTextsWithExactLabelCount(label: String) -> Int {
        let predicate = NSPredicate(format: "label == '" + label + "'")
        let matchingCells = app.tables.staticTexts.matching(predicate)
        let matches = matchingCells.count
        print(">>> Found \(matches) StaticText(s) with '\(label)' label")
        return matches
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

    class func textShownOnScreen(text: String) {
        let textPredicate = NSPredicate(format: "label MATCHES '" + text + "'")
        let staticText = app.staticTexts.element(matching: textPredicate)

        XCTAssertTrue(staticText.exists, "\"" + text + textNotFoundInWebView)
    }

    class func textsShownOnScreen(texts: [String]) {
        for text in texts {
            WebViewAssert.textShownOnScreen(text: text)
        }
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
