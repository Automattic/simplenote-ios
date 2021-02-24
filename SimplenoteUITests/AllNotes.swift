import XCTest

class AllNotes {

    class func openNote(noteName: String) {
        app.tables.cells[noteName].tap()
    }

    class func isOpen() -> Bool {
        return app.navigationBars[UID.NavBar.AllNotes].exists
    }

    class func open() {
        guard !isOpen() else { return }

        app.navigationBars.element.buttons[UID.Button.Menu].tap()
        app.tables.staticTexts[UID.Button.AllNotes].tap()
    }

    class func addNoteTap() {
        app.navigationBars[UID.NavBar.AllNotes].buttons[UID.Button.NewNote].tap()
    }

    class func createNoteAndLeaveEditor(noteName: String) {
        print(">>> Creating note: " + noteName)
        AllNotes.addNoteTap()
        NoteEditor.clearAndEnterText(enteredValue: noteName)
        NoteEditor.leaveEditor()
    }

    class func createNotes(names: [String]) {
        for noteName in names {
            createNoteAndLeaveEditor(noteName: noteName)
        }
    }

    class func trashNote(noteName: String) {
        Table.trashNote(noteName: noteName)
    }

    class func getNotesNumber() -> Int {
        return Table.getNotesNumber()
    }

    class func clearAllNotes() {
        AllNotes.open()

        let notesNumber = AllNotes.getNotesNumber()
        let cellsNum = app.tables.element.children(matching: .cell).count
        var startingIndex: Int

        if notesNumber == cellsNum {
            // Depending on what happened before, the cells numbering
            // might not include "All Notes", "Trash" and "Settings" cells...
            startingIndex = 0
        } else {
            // Or might include them
            startingIndex = 3
        }

        for _ in 0..<notesNumber {
            let cell = app.tables.cells.element(boundBy: startingIndex)
            cell.swipeLeft()
            cell.buttons[UID.Button.NoteCellTrash].tap()
        }
    }

    class func waitForLoad() {
        let allNotesNavBar = app.navigationBars[UID.NavBar.AllNotes]
        let predicate = NSPredicate { _, _ in
            allNotesNavBar.staticTexts[UID.Text.AllNotesInProgress].exists == false
        }

        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: .none)
        XCTWaiter().wait(for: [expectation], timeout: 10)
    }
}

class AllNotesAssert {

    class func noteExists(noteName: String) {
        print(">>> Asserting note existsence: " + noteName)
        XCTAssertTrue(app.tables.cells[noteName].exists, "\"" + noteName + noteNotFoundInAllNotes)
    }

    class func notesExist(names: [String]) {
        for noteName in names {
            AllNotesAssert.noteExists(noteName: noteName)
        }
    }

    class func noteAbsent(noteName: String) {
        XCTAssertFalse(app.tables.cells[noteName].exists, noteName + noteNotAbsentInAllNotes)
    }

    class func notesNumber(expectedNotesNumber: Int) {
        let actualNotesNumber = AllNotes.getNotesNumber()
        XCTAssertEqual(expectedNotesNumber, actualNotesNumber, numberOfNotesInAllNotesNotExpected)
    }

    class func screenShown() {
        XCTAssertTrue(app.navigationBars[UID.NavBar.AllNotes].waitForExistence(timeout: maxLoadTimeout), UID.NavBar.AllNotes + navBarNotFound)
    }
}
