import XCTest

class SimplenoteUISmokeTestsSettings: XCTestCase {

    override class func setUp() {
        app.launch()
        getToAllNotes()
        _ = attemptLogOut()
        EmailLogin.open()
        EmailLogin.logIn(email: testDataExistingEmail, password: testDataExistingPassword)
        NoteList.waitForLoad()
    }

    override func setUpWithError() throws {
        getToAllNotes()
        NoteList.trashAllNotes()
        Trash.empty()
        NoteList.openAllNotes()
    }

    override class func tearDown() {
        Settings.open()
        Settings.condensedModeDisable()
        Settings.close()
    }

    func testUsingCondensedNoteList() throws {
        trackTest()
        let cellHeightCondensed: CGFloat = 44.0
        let cellHeightUsual: CGFloat = 81.0
        let note = NoteData(
            name: "Condensed Mode Test",
            content: "Condensed Mode Content"
        )

        trackStep()
        NoteList.openAllNotes()
        NoteList.createNoteThenLeaveEditor(note)
        NoteListAssert.contentIsShown(for: note)

        trackStep()
        Settings.open()
        Settings.condensedModeEnable()
        Settings.close()
        NoteList.openAllNotes()
        NoteListAssert.noteContentIsShownInSearch(noteName: note.name, expectedContent: "")
        NoteListAssert.note(note, hasHeight: cellHeightCondensed)

        trackStep()
        Settings.open()
        Settings.condensedModeDisable()
        Settings.close()
        NoteList.openAllNotes()
        NoteListAssert.contentIsShown(for: note)
        NoteListAssert.note(note, hasHeight: cellHeightUsual)
    }


}
