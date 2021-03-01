import XCTest

class SimplenoteUISmokeTestsTrash: XCTestCase {

    override class func setUp() {
        app.launch()
        let _ = attemptLogOut()
        EmailLogin.open()
        EmailLogin.logIn(email: testDataExistingEmail, password: testDataExistingPassword)
        NoteList.waitForLoad()
    }

    override func setUpWithError() throws {
        NoteList.trashAllNotes()
        Trash.empty()
        NoteList.openAllNotes()
    }

    func testCanViewTrashedNotes() throws {
        let noteOneName = "CanView"
        let noteTwoName = "Trashed"
        let noteThreeName = "Notes"
        let noteNamesArray = [noteOneName, noteTwoName, noteThreeName]

        // Step 1
        Trash.open()
        TrashAssert.notesNumber(expectedNotesNumber: 0)

        // Step 2
        NoteList.openAllNotes()
        NoteList.createNotes(names: noteNamesArray)
        NoteListAssert.notesExist(names: noteNamesArray)
        NoteListAssert.notesNumber(expectedNotesNumber: 3)

        // Step 3
        NoteList.trashNote(noteName: noteOneName)
        NoteListAssert.noteAbsent(noteName: noteOneName)
        NoteListAssert.noteExists(noteName: noteTwoName)
        NoteListAssert.noteExists(noteName: noteThreeName)
        NoteListAssert.notesNumber(expectedNotesNumber: 2)

        //Step 4
        Trash.open()
        TrashAssert.noteExists(noteName: noteOneName)
        TrashAssert.notesNumber(expectedNotesNumber: 1)
    }

    func testCanDeleteNoteForeverIndividually() throws {
        let noteOneName = "CanDelete"
        let noteTwoName = "Note"
        let noteThreeName = "Forever"
        let noteNamesArray = [noteOneName, noteTwoName, noteThreeName]

        // Step 1
        Trash.open()
        TrashAssert.notesNumber(expectedNotesNumber: 0)

        // Step 2
        NoteList.openAllNotes()
        NoteList.createNotes(names: noteNamesArray)
        NoteListAssert.notesExist(names: noteNamesArray)
        NoteListAssert.notesNumber(expectedNotesNumber: 3)

        // Step 3
        NoteList.trashNote(noteName: noteOneName)
        NoteList.trashNote(noteName: noteTwoName)
        NoteListAssert.noteAbsent(noteName: noteOneName)
        NoteListAssert.noteAbsent(noteName: noteTwoName)
        NoteListAssert.noteExists(noteName: noteThreeName)
        NoteListAssert.notesNumber(expectedNotesNumber: 1)

        //Step 4
        Trash.open()
        TrashAssert.noteExists(noteName: noteOneName)
        TrashAssert.noteExists(noteName: noteTwoName)
        TrashAssert.notesNumber(expectedNotesNumber: 2)

        //Step 5
        Trash.deleteNote(noteName: noteOneName)
        TrashAssert.noteAbsent(noteName: noteOneName)
        TrashAssert.noteExists(noteName: noteTwoName)
        TrashAssert.notesNumber(expectedNotesNumber: 1)

        // Step 6
        NoteList.openAllNotes()
        NoteListAssert.noteAbsent(noteName: noteOneName)
        NoteListAssert.noteAbsent(noteName: noteTwoName)
        NoteListAssert.noteExists(noteName: noteThreeName)
        NoteListAssert.notesNumber(expectedNotesNumber: 1)
    }

    func testCanDeleteNotesForeverViaEmpty() throws {
        let noteOneName = "CanDelete"
        let noteTwoName = "Note"
        let noteThreeName = "Forever"
        let noteNamesArray = [noteOneName, noteTwoName, noteThreeName]

        // Step 1
        Trash.open()
        TrashAssert.notesNumber(expectedNotesNumber: 0)

        // Step 2
        NoteList.openAllNotes()
        NoteList.createNotes(names: noteNamesArray)
        NoteListAssert.notesExist(names: noteNamesArray)
        NoteListAssert.notesNumber(expectedNotesNumber: 3)

        // Step 3
        NoteList.trashNote(noteName: noteOneName)
        NoteList.trashNote(noteName: noteTwoName)
        NoteListAssert.noteAbsent(noteName: noteOneName)
        NoteListAssert.noteAbsent(noteName: noteTwoName)
        NoteListAssert.noteExists(noteName: noteThreeName)
        NoteListAssert.notesNumber(expectedNotesNumber: 1)

        //Step 4
        Trash.open()
        TrashAssert.noteExists(noteName: noteOneName)
        TrashAssert.noteExists(noteName: noteTwoName)
        TrashAssert.notesNumber(expectedNotesNumber: 2)

        //Step 5
        Trash.empty()
        TrashAssert.notesNumber(expectedNotesNumber: 0)

        // Step 6
        NoteList.openAllNotes()
        NoteListAssert.noteAbsent(noteName: noteOneName)
        NoteListAssert.noteAbsent(noteName: noteTwoName)
        NoteListAssert.noteExists(noteName: noteThreeName)
        NoteListAssert.notesNumber(expectedNotesNumber: 1)
    }

    func testCanRestoreNote() throws {
        let noteOneName = "CanRestore"
        let noteTwoName = "Trashed"
        let noteThreeName = "Notes"
        let noteNamesArray = [noteOneName, noteTwoName, noteThreeName]

        // Step 1
        Trash.open()
        TrashAssert.notesNumber(expectedNotesNumber: 0)

        // Step 2
        NoteList.openAllNotes()
        NoteList.createNotes(names: noteNamesArray)
        NoteListAssert.notesExist(names: noteNamesArray)
        NoteListAssert.notesNumber(expectedNotesNumber: 3)

        // Step 3
        NoteList.trashNote(noteName: noteOneName)
        NoteListAssert.noteAbsent(noteName: noteOneName)
        NoteListAssert.noteExists(noteName: noteTwoName)
        NoteListAssert.noteExists(noteName: noteThreeName)
        NoteListAssert.notesNumber(expectedNotesNumber: 2)

        //Step 4
        Trash.open()
        TrashAssert.noteExists(noteName: noteOneName)
        TrashAssert.notesNumber(expectedNotesNumber: 1)

        //Step 5
        Trash.restoreNote(noteName: noteOneName)
        TrashAssert.notesNumber(expectedNotesNumber: 0)

        //Step 6
        NoteList.openAllNotes()
        NoteListAssert.notesExist(names: noteNamesArray)
        NoteListAssert.notesNumber(expectedNotesNumber: 3)
    }

    func testCanTrashNote() throws {
        let noteName = "can trash note"

        // Step 1
        Trash.open()
        TrashAssert.notesNumber(expectedNotesNumber: 0)

        // Step 2
        NoteList.openAllNotes()
        NoteList.createNoteAndLeaveEditor(noteName: noteName)
        NoteListAssert.noteExists(noteName: noteName)
        NoteListAssert.notesNumber(expectedNotesNumber: 1)

        // Step 3
        NoteList.trashNote(noteName: noteName)
        NoteListAssert.noteAbsent(noteName: noteName)
        NoteListAssert.notesNumber(expectedNotesNumber: 0)

        //Step 4
        Trash.open()
        TrashAssert.noteExists(noteName: noteName)
        TrashAssert.notesNumber(expectedNotesNumber: 1)
    }
}
