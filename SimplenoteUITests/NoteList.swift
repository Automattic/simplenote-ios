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
        let navBar = app.navigationBars[UID.NavBar.allNotes]
        guard navBar.exists else { return false}
        return navBar.frame.minX == 0.0
    }

    class func isNoteListOpen(forTag tag: String) -> Bool {
        return app.navigationBars[tag].exists
    }

    class func getNoteCell(_ noteName: String) -> XCUIElement {
        return Table.getCell(label: noteName)
    }

    class func isNotePresent(_ noteName: String) -> Bool {
        return NoteList.getNoteCell(noteName).exists
    }

    class func getNoteCellHeight(_ noteName: String) -> CGFloat {
        return NoteList.getNoteCell(noteName).frame.height
    }

    class func openAllNotes() {
        guard !NoteList.isAllNotesListOpen() else { return }
        print(">>> Opening \"All Notes\"")
        Sidebar.open()
        let allNotesButton = app.tables.staticTexts[UID.Button.allNotes]
        guard allNotesButton.waitForExistence(timeout: averageLoadTimeout) else { return }
        allNotesButton.tap()
    }

    class func addNoteTap() {
        app.buttons[UID.Button.newNote].tap()
    }

    static func createNoteThenLeaveEditor(_ note: NoteData, usingPaste: Bool = false) {
        NoteList.createNoteAndLeaveEditor(
            noteName: note.formattedForAutomatedInput,
            tags: note.tags,
            usingPaste: usingPaste
        )
    }

    class func createNoteAndLeaveEditor(noteName: String, tags: [String] = [], usingPaste: Bool = false) {
        print(">>> Creating a note: " + noteName)
        NoteList.addNoteTap()
        NoteEditor.clearAndEnterText(enteredValue: noteName, usingPaste: usingPaste)

        for tag in tags {
            NoteEditor.addTag(tagName: tag)
        }

        NoteEditor.leaveEditor()
    }

    class func createNotes(names: [String], usingPaste: Bool = false) {
        for noteName in names {
            createNoteAndLeaveEditor(noteName: noteName, usingPaste: usingPaste)
        }
    }

    class func trashNote(noteName: String) {
        Table.trashCell(noteName: noteName)
    }

    class func getNotesNumber() -> Int {
        return Table.getVisibleLabelledCells().count
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
        Table
            .getVisibleLabelledCellsNames()
            .forEach { Table.trashCell(noteName: $0) }
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
        sleep(5)
    }

    class func searchCancel() {
        print(">>> Canceling Search")
        let searchCancelButton = app.buttons[UID.Button.cancel]
        guard searchCancelButton.exists else { return }
        searchCancelButton.tap()
    }

    class func longPressNote(title: String) {
        app.tables.cells[title].press(forDuration: 3)
    }

    class func selectNote() {
        let selectButton = app.buttons[UID.Button.select]
        guard selectButton.exists else { return }
        selectButton.tap()
    }

    class func selectAll() {
        let selectAllButton = app.buttons[UID.Button.selectAll]
        guard selectAllButton.exists else { return }
        selectAllButton.tap()
    }

    class func tapTrashButton() {
        let trashIcon = app.buttons[UID.Button.trashIcon]
        guard trashIcon.exists else { return }
        trashIcon.tap()
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

    static func noteExists(_ note: NoteData) {
        notesExist([note])
    }

    static func notesExist(_ notes: [NoteData]) {
        notesExist(names: notes.map { $0.name })
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

    class func note(_ note: NoteData, hasHeight height: CGFloat) {
        print(">>> Asserting that note height is \(height)")
        XCTAssertEqual(NoteList.getNoteCellHeight(note.name), height)
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

    class func contentIsShown(for note: NoteData) {
        noteContentIsShownInSearch(noteName: note.name, expectedContent: note.content)
    }

    class func noteContentIsShownInSearch(noteName: String, expectedContent: String) {
        print(">>> Asserting that note '\(noteName)' has the following content:")
        print(">>>> \"\(expectedContent)\"")

        guard NoteList.isNotePresent(noteName) else {
            return XCTFail(">>>> Note not found")
        }

        if let noteContent = Table.getContentOfCell(noteName: noteName) {
            XCTAssertTrue(noteContent.contains(expectedContent), "Content is different.")
        } else if expectedContent.isEmpty {
            // If note content is nil, but we assert for empty content, we should not fail
            XCTAssert(true, "Content is not empty.")
        } else {
            // Otherwise, we should fail
            XCTFail("Note has no content. Only title.")
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

    class func isDeselectAllButtonDisplayed() {
        XCTAssertTrue(app.buttons[UID.Button.deselectAll].waitForExistence(timeout: maxLoadTimeout))
    }
}
