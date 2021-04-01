import XCTest

class Trash {

    class func open() {
        print(">>> Opening \"Trash\"")
        Sidebar.open()
        app.tables.staticTexts[UID.Button.trash].tap()
    }

    class func restoreNote(noteName: String) {
        app.tables.cells[noteName].swipeLeft()
        app.tables.cells[noteName].buttons[UID.Button.trashRestore].tap()
    }

    class func deleteNote(noteName: String) {
        Table.trashCell(noteName: noteName)
    }

    class func empty() {
        Trash.open()
        let emptyTrashButton = app.buttons[UID.Button.trashEmptyTrash]
        guard emptyTrashButton.isEnabled else { return }

        emptyTrashButton.tap()
        app.alerts.scrollViews.otherElements.buttons[UID.Button.yes].tap()
    }

    class func getNotesNumber() -> Int {
        return Table.getVisibleLabelledCells().count
    }
}

class TrashAssert {

    class func noteExists(noteName: String) {
        XCTAssertTrue(app.tables.cells[noteName].exists, noteName + noteNotFoundInTrash)
    }

    class func noteAbsent(noteName: String) {
        XCTAssertFalse(app.tables.cells[noteName].exists, noteName + noteNotAbsentInTrash)
    }

    class func notesNumber(expectedNotesNumber: Int) {
        let actualNotesNumber = Trash.getNotesNumber()
        XCTAssertEqual(actualNotesNumber, expectedNotesNumber, numberOfNotesInTrashNotExpected)
    }
}
