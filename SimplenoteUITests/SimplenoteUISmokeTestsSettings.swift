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
        let note = NoteData(
            name: "Condensed Mode Test",
            content: "Condensed Mode Content",
            tags: []
        )

        trackStep()
        NoteList.openAllNotes()
        NoteList.createNoteThenLeaveEditor(note)
        NoteListAssert.noteContentIsShown(note)

        trackStep()
        Settings.open()
        Settings.condensedModeEnable()
        Settings.close()
        NoteList.openAllNotes()
        NoteListAssert.noteContentIsShownInSearch(noteName: note.name, expectedContent: "")
        NoteListAssert.noteHeight(note, 44.0)

        trackStep()
        Settings.open()
        Settings.condensedModeDisable()
        Settings.close()
        NoteList.openAllNotes()
        NoteListAssert.noteContentIsShown(note)
        NoteListAssert.noteHeight(note, 81.0)
    }
}
