import XCTest

class AllNotes {

    class func openNote(noteName: String) {
        app.tables.cells[noteName].tap()
    }

    class func isOpen() -> Bool {
		//Warning for future: this works only for 'All Notes' obviously
		//Will not work when a tag is selected.
        return app.navigationBars[UID.NavBar.allNotes].exists
    }

    class func open() {
        guard !isOpen() else { return }

		Sidebar.open()
        app.tables.staticTexts[UID.Button.allNotes].tap()
    }

    class func addNoteTap() {
		app.navigationBars.buttons[UID.Button.newNote].tap()
    }

	class func createNoteAndLeaveEditor(noteName: String, tagsOptional: [String] = []) {
        print(">>> Creating a note: " + noteName)
        AllNotes.addNoteTap()
        NoteEditor.clearAndEnterText(enteredValue: noteName)

		for tag in tagsOptional {
			NoteEditor.addTag(tagName: tag)
		}

        NoteEditor.leaveEditor()
    }

    class func createNotes(names: [String]) {
        for noteName in names {
            createNoteAndLeaveEditor(noteName: noteName)
        }
    }

    class func trashNote(noteName: String) {
        Table.trashCell(noteName: noteName)
    }

    class func getNotesNumber() -> Int {
        return Table.getCellsNumber()
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
            cell.buttons[UID.Button.itemTrash].tap()
        }
    }

    class func waitForLoad() {
        let allNotesNavBar = app.navigationBars[UID.NavBar.allNotes]
        let predicate = NSPredicate { _, _ in
            allNotesNavBar.staticTexts[UID.Text.allNotesInProgress].exists == false
        }

        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: .none)
        XCTWaiter().wait(for: [expectation], timeout: 10)
    }

	class func searchForText(text: String) {
		print(">>> Searching for '" + text + "'")
		let searchField = app.searchFields[UID.SearchField.search]
		guard searchField.exists else { return }
		searchField.tap()

		let clearTextButton = searchField.buttons[UID.Button.clearText]
		if clearTextButton.exists {
			clearTextButton.tap()
		}

		searchField.typeText(text)
		sleep(2)
	}

	class func searchCancel() {
		print(">>> Canceling Search")
		let searchCancelButton = app.buttons[UID.Button.cancel]
		guard searchCancelButton.exists else { return }
		searchCancelButton.tap()
	}
}

class AllNotesAssert {

    class func noteExists(noteName: String) {
        print(">>> Asserting that note is shown once: " + noteName)
		let matchesCount = Table.getCellsWithExactLabelCount(label: noteName)
		XCTAssertEqual(matchesCount, 1)
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
        XCTAssertEqual(actualNotesNumber, expectedNotesNumber, numberOfNotesInAllNotesNotExpected)
    }

    class func screenShown() {
        XCTAssertTrue(app.navigationBars[UID.NavBar.allNotes].waitForExistence(timeout: maxLoadTimeout), UID.NavBar.allNotes + navBarNotFound)
    }

	class func noteContentIsShownInSearch(noteName: String, expectedContent: String) {
		print(">>> Asserting that note '" + noteName + "' shows the following content:")
		print(">>>> " + expectedContent)
		let noteContent = Table.getContentOfCell(noteName: noteName)
		XCTAssertTrue(noteContent.contains(expectedContent), "Content NOT found")
	}
}
