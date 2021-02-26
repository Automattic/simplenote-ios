import XCTest

class SimplenoteUISmokeTestsTrash: XCTestCase {

    override class func setUp() {
        app.launch()
        let _ = attemptLogOut()
        EmailLogin.open()
        EmailLogin.logIn(email: testDataExistingEmail, password: testDataExistingPassword)
        AllNotes.waitForLoad()
    }

    override func setUpWithError() throws {
        AllNotes.clearAllNotes()
        Trash.empty()
        AllNotes.open()
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
        AllNotes.open()
        AllNotes.createNotes(names: noteNamesArray)
        AllNotesAssert.notesExist(names: noteNamesArray)
        AllNotesAssert.notesNumber(expectedNotesNumber: 3)

        // Step 3
        AllNotes.trashNote(noteName: noteOneName)
        AllNotesAssert.noteAbsent(noteName: noteOneName)
        AllNotesAssert.noteExists(noteName: noteTwoName)
        AllNotesAssert.noteExists(noteName: noteThreeName)
        AllNotesAssert.notesNumber(expectedNotesNumber: 2)

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
        AllNotes.open()
        AllNotes.createNotes(names: noteNamesArray)
        AllNotesAssert.notesExist(names: noteNamesArray)
        AllNotesAssert.notesNumber(expectedNotesNumber: 3)

        // Step 3
        AllNotes.trashNote(noteName: noteOneName)
        AllNotes.trashNote(noteName: noteTwoName)
        AllNotesAssert.noteAbsent(noteName: noteOneName)
        AllNotesAssert.noteAbsent(noteName: noteTwoName)
        AllNotesAssert.noteExists(noteName: noteThreeName)
        AllNotesAssert.notesNumber(expectedNotesNumber: 1)

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
        AllNotes.open()
        AllNotesAssert.noteAbsent(noteName: noteOneName)
        AllNotesAssert.noteAbsent(noteName: noteTwoName)
        AllNotesAssert.noteExists(noteName: noteThreeName)
        AllNotesAssert.notesNumber(expectedNotesNumber: 1)
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
        AllNotes.open()
        AllNotes.createNotes(names: noteNamesArray)
        AllNotesAssert.notesExist(names: noteNamesArray)
        AllNotesAssert.notesNumber(expectedNotesNumber: 3)

        // Step 3
        AllNotes.trashNote(noteName: noteOneName)
        AllNotes.trashNote(noteName: noteTwoName)
        AllNotesAssert.noteAbsent(noteName: noteOneName)
        AllNotesAssert.noteAbsent(noteName: noteTwoName)
        AllNotesAssert.noteExists(noteName: noteThreeName)
        AllNotesAssert.notesNumber(expectedNotesNumber: 1)

        //Step 4
        Trash.open()
        TrashAssert.noteExists(noteName: noteOneName)
        TrashAssert.noteExists(noteName: noteTwoName)
        TrashAssert.notesNumber(expectedNotesNumber: 2)

        //Step 5
        Trash.empty()
        TrashAssert.notesNumber(expectedNotesNumber: 0)

        // Step 6
        AllNotes.open()
        AllNotesAssert.noteAbsent(noteName: noteOneName)
        AllNotesAssert.noteAbsent(noteName: noteTwoName)
        AllNotesAssert.noteExists(noteName: noteThreeName)
        AllNotesAssert.notesNumber(expectedNotesNumber: 1)
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
        AllNotes.open()
        AllNotes.createNotes(names: noteNamesArray)
        AllNotesAssert.notesExist(names: noteNamesArray)
        AllNotesAssert.notesNumber(expectedNotesNumber: 3)

        // Step 3
        AllNotes.trashNote(noteName: noteOneName)
        AllNotesAssert.noteAbsent(noteName: noteOneName)
        AllNotesAssert.noteExists(noteName: noteTwoName)
        AllNotesAssert.noteExists(noteName: noteThreeName)
        AllNotesAssert.notesNumber(expectedNotesNumber: 2)

        //Step 4
        Trash.open()
        TrashAssert.noteExists(noteName: noteOneName)
        TrashAssert.notesNumber(expectedNotesNumber: 1)

        //Step 5
        Trash.restoreNote(noteName: noteOneName)
        TrashAssert.notesNumber(expectedNotesNumber: 0)

        //Step 6
        AllNotes.open()
        AllNotesAssert.notesExist(names: noteNamesArray)
        AllNotesAssert.notesNumber(expectedNotesNumber: 3)
    }

    func testCanTrashNote() throws {
        let noteName = "can trash note"

        // Step 1
        Trash.open()
        TrashAssert.notesNumber(expectedNotesNumber: 0)

        // Step 2
        AllNotes.open()
        AllNotes.createNoteAndLeaveEditor(noteName: noteName)
        AllNotesAssert.noteExists(noteName: noteName)
        AllNotesAssert.notesNumber(expectedNotesNumber: 1)

        // Step 3
        AllNotes.trashNote(noteName: noteName)
        AllNotesAssert.noteAbsent(noteName: noteName)
        AllNotesAssert.notesNumber(expectedNotesNumber: 0)

        //Step 4
        Trash.open()
        TrashAssert.noteExists(noteName: noteName)
        TrashAssert.notesNumber(expectedNotesNumber: 1)
    }
}
