import XCTest

class AllNotes {

    class func openNote(noteName: String) {
        app.tables.cells[noteName].tap()
    }
    
    class func isOpen() -> Bool {
        return app.navigationBars[uidNavBar_AllNotes].exists
    }

    class func open() {        
        guard !isOpen() else { return }
        
        app.navigationBars.element.buttons[uidButton_Menu].tap()
        app.tables.staticTexts[uidButton_AllNotes].tap()
    }

    class func addNoteTap() {
        print(">>> Adding new note...")
        app.navigationBars[uidNavBar_AllNotes].buttons[uidButton_NewNote].tap()
    }

    class func createNoteAndLeaveEditor (noteName: String) {
        AllNotes.addNoteTap()
        NoteEditor.clearAndEnterText(enteredValue: noteName)
        NoteEditor.leaveEditor()
    }

    class func trashNote(noteName: String) {
        Table.trashNote(noteName: noteName)
    }

    class func getNotesNumber() -> Int {
        return Table.getNotesNumber()
    }

    class func clearAllNotes() {
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
            cell.buttons[uidButton_NoteCell_Trash].tap()
        }
    }
    
    class func waitForLoad() {
        let allNotesNavBar = app.navigationBars[uidNavBar_AllNotes]
        let predicate = NSPredicate { _, _ in
            allNotesNavBar.staticTexts[uidText_AllNotes_InProgress].exists == false
        }
        
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: .none)
        XCTWaiter().wait(for: [expectation], timeout: 10)
    }
}

class AllNotesAssert {

    class func noteExists(noteName: String) {
        XCTAssertTrue(app.tables.cells[noteName].exists, "\"" + noteName + noteNotFoundInAllNotes)
    }

    class func noteAbsent(noteName: String) {
        XCTAssertFalse(app.tables.cells[noteName].exists, noteName + noteNotAbsentInAllNotes)
    }

    class func notesNumber(expectedNotesNumber: Int) {
        let actualNotesNumber = AllNotes.getNotesNumber()
        XCTAssertEqual(expectedNotesNumber, actualNotesNumber, numberOfNotesInAllNotesNotExpected)
    }

    class func screenShown() {
        XCTAssertTrue(app.navigationBars[uidNavBar_AllNotes].waitForExistence(timeout: maxLoadTimeout), uidNavBar_AllNotes + navBarNotFound)
    }
}
