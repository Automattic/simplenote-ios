import XCTest

class SimplenoteUISmokeTestsHistory: XCTestCase {
    let notePrefix = "HistoryTest"

    override class func setUp() {
        app.launch()
        getToAllNotes()
        let _ = attemptLogOut()
        EmailLogin.open()
        EmailLogin.logIn()
    }

    override func setUpWithError() throws {
        getToAllNotes()
        NoteList.trashAllNotes()
        Trash.empty()
        NoteList.openAllNotes()
    }

    override func tearDownWithError() throws {
        History.close()
    }

    func testHistoryCanBeDismissed() throws {
        trackTest()
        let noteText = notePrefix + getRandomId()

        trackStep()
        NoteList.addNoteTap()
        NoteEditor.clearAndEnterText(enteredValue: noteText)
        NoteEditor.openHistory()
        HistoryAssert.historyShown()

        trackStep()
        History.close()
        HistoryAssert.historyDismissed()
    }

    func testRestoreNoteButtonIsDisabledByDefault() throws {
        trackTest()
        let noteText = notePrefix + getRandomId()

        trackStep()
        NoteList.addNoteTap()
        NoteEditor.clearAndEnterText(enteredValue: noteText)
        NoteEditorAssert.textViewWithExactValueShownOnce(value: noteText)
        NoteEditor.openHistory()
        HistoryAssert.historyShown()
        HistoryAssert.restoreButtonIsDisabled()
    }

    func testRestoreButtonIsEnabledWhenAPreviousVersionIsSelected() throws {
        trackTest()
        let initialNoteText = notePrefix + getRandomId()
        let editedNoteText = notePrefix + getRandomId()

        trackStep()
        NoteList.addNoteTap()
        NoteEditor.clearAndEnterText(enteredValue: initialNoteText)
        NoteEditor.waitBeforeEditingText(delayInSeconds: 3, newText: editedNoteText)
        NoteEditor.openHistory()
        HistoryAssert.historyShown()

        trackStep()
        History.setSliderPosition(position: 0.0)
        HistoryAssert.restoreButtonIsEnabled()
    }

    func testCanRestorePreviousVersion() throws {
        trackTest()
        let initialNoteText = notePrefix + getRandomId()
        let editedNoteText = notePrefix + getRandomId()

        trackStep()
        NoteList.addNoteTap()
        NoteEditor.clearAndEnterText(enteredValue: initialNoteText)
        NoteEditor.waitBeforeEditingText(delayInSeconds: 3, newText: editedNoteText)
        NoteEditor.openHistory()
        HistoryAssert.historyShown()

        trackStep()
        History.setSliderPosition(position: 0.0)
        History.restoreNote()
        NoteEditorAssert.textViewWithExactValueShownOnce(value: initialNoteText)
    }

    func testRestoredVersionIsAddedOnTopOfTheOtherChanges() throws {
        trackTest()
        let initialNoteText = notePrefix + getRandomId()
        let editedNoteText = notePrefix + getRandomId()

        trackStep()
        NoteList.addNoteTap()
        NoteEditor.clearAndEnterText(enteredValue: initialNoteText)
        NoteEditor.waitBeforeEditingText(delayInSeconds: 3, newText: editedNoteText)
        NoteEditor.openHistory()
        HistoryAssert.historyShown()

        trackStep()
        History.setSliderPosition(position: 0.0)
        History.restoreNote()
        NoteEditorAssert.textViewWithExactValueShownOnce(value: initialNoteText)

        trackStep()
        NoteEditor.openHistory()
        HistoryAssert.historyShown()

        trackStep()
        History.setSliderPosition(position: 1.0)
        NoteEditorAssert.textViewWithExactValueShownOnce(value: initialNoteText)

        trackStep()
        History.setSliderPosition(position: 0.5)
        NoteEditorAssert.textViewWithExactValueShownOnce(value: editedNoteText)

        trackStep()
        History.setSliderPosition(position: 0.0)
        NoteEditorAssert.textViewWithExactValueShownOnce(value: initialNoteText)
    }

    func testPreviousNoteIsNotRestoredWhenTheHistoryPanelIsDismissed() throws {
        trackTest()
        let initialNoteText = notePrefix + getRandomId()
        let editedNoteText = notePrefix + getRandomId()

        trackStep()
        NoteList.addNoteTap()
        NoteEditor.clearAndEnterText(enteredValue: initialNoteText)
        NoteEditor.waitBeforeEditingText(delayInSeconds: 3, newText: editedNoteText)
        NoteEditor.openHistory()
        HistoryAssert.historyShown()

        trackStep()
        History.setSliderPosition(position: 0.0)
        History.close()
        NoteEditorAssert.textViewWithExactValueShownOnce(value: editedNoteText)
    }

    func testHistoryIsKeptAfterRecoveringNoteFromTrash() throws {
        trackTest()
        let initialNoteText = notePrefix + getRandomId()
        let editedNoteText = notePrefix + getRandomId()

        trackStep()
        NoteList.addNoteTap()
        NoteEditor.clearAndEnterText(enteredValue: initialNoteText)
        NoteEditor.waitBeforeEditingText(delayInSeconds: 3, newText: editedNoteText)
        NoteEditor.leaveEditor()
        NoteListAssert.noteExists(noteName: editedNoteText)

        trackStep()
        NoteList.trashNote(noteName: editedNoteText)
        Trash.open()
        TrashAssert.noteExists(noteName: editedNoteText)

        trackStep()
        Trash.restoreNote(noteName: editedNoteText)
        TrashAssert.noteAbsent(noteName: editedNoteText)

        trackStep()
        NoteList.openAllNotes()
        NoteList.openNote(noteName: editedNoteText)
        NoteEditorAssert.textViewWithExactValueShownOnce(value: editedNoteText)

        trackStep()
        NoteEditor.openHistory()
        HistoryAssert.historyShown()

        trackStep()
        History.setSliderPosition(position: 0.0)
        History.restoreNote()
        NoteEditorAssert.textViewWithExactValueShownOnce(value: initialNoteText)
    }
}
