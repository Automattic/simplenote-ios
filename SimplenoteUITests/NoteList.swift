import XCTest

class NoteList {

    class func openNote(noteName: String) {
        app.tables.cells[noteName].tap()
    }

    class func getNavBarIdentifier() -> String? {
        let navBar = app.navigationBars.element
        guard navBar.exists else { return .none }
        print(">>> Currently active navigation bar: " + navBar.identifier)
        return navBar.identifier
    }

    class func isAllNotesListOpen() -> Bool {
        return app.navigationBars[UID.NavBar.allNotes].exists
    }

    class func isNoteListOpen(forTag tag: String) -> Bool {
        return app.navigationBars[tag].exists
    }

    class func openAllNotes() {
        guard !NoteList.isAllNotesListOpen() else { return }
        print(">>> Opening \"All Notes\"")
        Sidebar.open()
        app.tables.staticTexts[UID.Button.allNotes].tap()
    }

    class func addNoteTap() {
        app.navigationBars.buttons[UID.Button.newNote].tap()
    }

    class func createNoteAndLeaveEditor(noteName: String, tags: [String] = []) {
        print(">>> Creating a note: " + noteName)
        NoteList.addNoteTap()
        NoteEditor.clearAndEnterText(enteredValue: noteName)

        for tag in tags {
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
        return Table.getVisibleLabelledCellsNumber()
    }

    class func getTagsSuggestionsNumber() -> Int {
        return Table.getVisibleNonLabelledCellsNumber()
    }

    class func tagSuggestionTap(tag: String) {
        print(">>> Tapping '\(tag)' tag suggestion")
        Table.getStaticText(label: tag).tap()
    }

    class func trashAllNotes() {
        NoteList.openAllNotes()
        let noteNames = Table.getVisibleLabelledCellsNames()
        guard noteNames.isEmpty == false else { return }
        noteNames.forEach { Table.trashCell(noteName: $0) }
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
        print(">>> Searching for '\(text)'")
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

class NoteListAssert {

    class func searchHeaderShown(header: String, numberOfOccurences: Int) {
        switch numberOfOccurences {
        case 0:
            print(assertSearchHeaderNotShown + header)
        case 1:
            print(assertSearchHeaderShown + header)
        default:
            print("Invalid value of \"numberOfOccurences\". Valid values are 0 or 1")
            return
        }

        let matches = Table.getStaticTextsWithExactLabelCount(label: header)
        XCTAssertEqual(matches, numberOfOccurences)
    }

    class func tagsSearchHeaderShown() {
        NoteListAssert.searchHeaderShown(header: UID.Text.searchByTag, numberOfOccurences: 1)
    }

    class func tagsSearchHeaderNotShown() {
        NoteListAssert.searchHeaderShown(header: UID.Text.searchByTag, numberOfOccurences: 0)
    }

    class func notesSearchHeaderShown() {
        NoteListAssert.searchHeaderShown(header: UID.Text.notes, numberOfOccurences: 1)
    }

    class func notesSearchHeaderNotShown() {
        NoteListAssert.searchHeaderShown(header: UID.Text.notes, numberOfOccurences: 0)
    }

    class func tagSuggestionExists(tag: String) {
        print(">>> Asserting that '\(tag)' tag suggestion is shown once")
        let matches = Table.getStaticTextsWithExactLabelCount(label: tag)
        XCTAssertEqual(matches, 1)
    }

    class func tagSuggestionsExist(tags: [String]) {
        for tag in tags {
            NoteListAssert.tagSuggestionExists(tag: tag)
        }
    }

    class func noteExists(noteName: String) {
        print(">>> Asserting that note is shown once: " + noteName)
        let matches = Table.getCellsWithExactLabelCount(label: noteName)
        XCTAssertEqual(matches, 1)
    }

    class func notesExist(names: [String]) {
        for noteName in names {
            NoteListAssert.noteExists(noteName: noteName)
        }
    }

    class func noteAbsent(noteName: String) {
        XCTAssertFalse(app.tables.cells[noteName].exists, noteName + noteNotAbsentInAllNotes)
    }

    class func notesNumber(expectedNotesNumber: Int) {
        let actualNotesNumber = NoteList.getNotesNumber()
        XCTAssertEqual(actualNotesNumber, expectedNotesNumber, numberOfNotesInAllNotesNotExpected)
    }

    class func tagsSuggestionsNumber(number: Int) {
        let actualNumber = NoteList.getTagsSuggestionsNumber()
        XCTAssertEqual(actualNumber, number, numberOfTagsSuggestionsNotExpected)
    }

    class func noteListShown(forSelection selection: String ) {
        print(assertNavBarIdentifier + selection)
        XCTAssertTrue(app.navigationBars[selection].waitForExistence(timeout: maxLoadTimeout))

        if let navBarID = NoteList.getNavBarIdentifier() {
            XCTAssertEqual(navBarID, selection, selection + navBarNotFound)
        } else {
            XCTFail(foundNoNavBar)
        }
    }

    class func allNotesShown() {
        NoteListAssert.noteListShown(forSelection: UID.NavBar.allNotes)
    }

    class func trashShown() {
        NoteListAssert.noteListShown(forSelection: UID.NavBar.trash)
    }

    class func noteContentIsShownInSearch(noteName: String, expectedContent: String) {
        print(">>> Asserting that note '\(noteName)' shows the following content:")
        print(">>>> " + expectedContent)

        if let noteContent = Table.getContentOfCell(noteName: noteName) {
            XCTAssertTrue(noteContent.contains(expectedContent), "Content NOT found")
        } else {
            XCTFail("Could not find note")
        }
    }

    class func searchStringIsShown(searchString: String) {
        print(">>> Asserting that search string is '\(searchString)'")
        let searchField = app.searchFields[UID.SearchField.search]

        guard searchField.exists else {
            XCTFail(">>> Search field not found")
            return
        }

        guard let actualSearchString = searchField.value as? String else {
            XCTFail(">>> Search field has no value")
            return
        }

        print(">>> Actual search string is '\(actualSearchString)'")
        XCTAssertEqual(actualSearchString, searchString)
    }
}
