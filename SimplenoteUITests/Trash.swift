import XCTest

class Trash {

    class func open() {
        app.navigationBars.element.buttons[UID.Button.Menu].tap()
        app.tables.staticTexts[UID.Button.Trash].tap()
    }

    class func restoreNote(noteName: String) {
        app.tables.cells[noteName].swipeLeft()
        app.tables.cells[noteName].buttons[UID.Button.TrashRestore].tap()
    }

    class func deleteNote(noteName: String) {
        Table.trashNote(noteName: noteName)
    }

    class func empty() {
        Trash.open()
        let emptyTrashButton = app.buttons[UID.Button.TrashEmptyTrash]
        guard emptyTrashButton.isEnabled else { return }

		emptyTrashButton.tap()
        app.alerts.scrollViews.otherElements.buttons[UID.Button.Yes].tap()
    }

    class func getNotesNumber() -> Int {
        return Table.getNotesNumber()
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
        XCTAssertEqual(expectedNotesNumber, actualNotesNumber, numberOfNotesInTrashNotExpected)
    }
}
