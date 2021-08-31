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

    override class func tearDown() {
        NoteList.trashAllNotes()
        Trash.empty()
    }

    func testHistoryCanBeDismissed() throws {
        trackTest()
        let noteText = notePrefix + getRandomId()

        trackStep()
        NoteList.addNoteTap()
        NoteEditorAssert.editorShown()

        trackStep()
        NoteEditor.clearAndEnterText(enteredValue: noteText)
        NoteEditor.openHistory()
        HistoryAssert.historyShown()

        trackStep()
        History.close()
        HistoryAssert.historyDismissed()

        NoteEditor.leaveEditor()
        NoteList.trashNote(noteName: noteText)
    }

    func testRestoreNoteButtonIsDisabledByDefault() throws {
        trackTest()
        let noteText = notePrefix + getRandomId()

        trackStep()
        NoteList.addNoteTap()
        NoteEditorAssert.editorShown()

        trackStep()
        NoteEditor.clearAndEnterText(enteredValue: noteText)
        NoteEditor.openHistory()
        HistoryAssert.historyShown()

        trackStep()
        HistoryAssert.restoreButtonIsDisabled()

        trackStep()
        History.close()
        NoteEditor.leaveEditor()
        NoteList.trashNote(noteName: noteText)
    }

    func testRestoreButtonIsEnabledWhenAPreviousVersionIsSelected() throws {
        trackTest()
        let initialNoteText = notePrefix + getRandomId()
        let editedNoteText = notePrefix + getRandomId()

        trackStep()
        NoteList.addNoteTap()
        NoteEditorAssert.editorShown()

        trackStep()
        NoteEditor.clearAndEnterText(enteredValue: initialNoteText)
        NoteEditor.waitBeforeEditingText(delayInSeconds: 3, newText: editedNoteText)

        trackStep()
        NoteEditor.openHistory()
        HistoryAssert.historyShown()

        trackStep()
        History.setSliderPosition(position: 0.0)
        HistoryAssert.restoreButtonIsEnabled()

        trackStep()
        History.close()
        NoteEditor.leaveEditor()
        NoteList.trashNote(noteName: editedNoteText)
    }

    func testCanRestorePreviousVersion() throws {
        trackTest()
        let initialNoteText = notePrefix + getRandomId()
        let editedNoteText = notePrefix + getRandomId()

        trackStep()
        NoteList.addNoteTap()
        NoteEditorAssert.editorShown()

        trackStep()
        NoteEditor.clearAndEnterText(enteredValue: initialNoteText)
        NoteEditor.waitBeforeEditingText(delayInSeconds: 3, newText: editedNoteText)

        trackStep()
        NoteEditor.openHistory()
        HistoryAssert.historyShown()

        trackStep()
        History.setSliderPosition(position: 0.0)
        History.restoreNote()
        NoteEditorAssert.textViewWithExactValueShownOnce(value: initialNoteText)

        trackStep()
        History.close()
        NoteEditor.leaveEditor()
        NoteList.trashNote(noteName: initialNoteText)
    }

    func testRestoredVersionIsAddedOnTopOfTheOtherChanges() throws {
        trackTest()
        let initialNoteText = notePrefix + getRandomId()
        let editedNoteText = notePrefix + getRandomId()

        trackStep()
        NoteList.addNoteTap()
        NoteEditorAssert.editorShown()

        trackStep()
        NoteEditor.clearAndEnterText(enteredValue: initialNoteText)
        NoteEditor.waitBeforeEditingText(delayInSeconds: 3, newText: editedNoteText)

        trackStep()
        NoteEditor.openHistory()
        HistoryAssert.historyShown()
        History.setSliderPosition(position: 0.0)
        History.restoreNote()
        NoteEditorAssert.textViewWithExactValueShownOnce(value: initialNoteText)

        trackStep()
        NoteEditor.openHistory()
        HistoryAssert.historyShown()
        History.setSliderPosition(position: 1.0)
        NoteEditorAssert.textViewWithExactValueShownOnce(value: initialNoteText)

        trackStep()
        History.setSliderPosition(position: 0.5)
        NoteEditorAssert.textViewWithExactValueShownOnce(value: editedNoteText)

        trackStep()
        History.setSliderPosition(position: 0.0)
        NoteEditorAssert.textViewWithExactValueShownOnce(value: initialNoteText)

        trackStep()
        History.close()
        NoteEditor.leaveEditor()
        NoteList.trashNote(noteName: initialNoteText)
    }

    func testPreviousNoteIsNotRestoredWhenTheHistoryPanelIsDismissed() throws {
        trackTest()
        let initialNoteText = notePrefix + getRandomId()
        let editedNoteText = notePrefix + getRandomId()

        trackStep()
        NoteList.addNoteTap()
        NoteEditorAssert.editorShown()

        trackStep()
        NoteEditor.clearAndEnterText(enteredValue: initialNoteText)
        NoteEditor.waitBeforeEditingText(delayInSeconds: 3, newText: editedNoteText)

        trackStep()
        NoteEditor.openHistory()
        HistoryAssert.historyShown()

        trackStep()
        History.setSliderPosition(position: 0.0)
        History.close()
        NoteEditorAssert.textViewWithExactValueShownOnce(value: editedNoteText)

        trackStep()
        NoteEditor.leaveEditor()
        NoteList.trashNote(noteName: editedNoteText)
    }

    func testHistoryIsKeptAfterRecoveringNoteFromTrash() throws {
        trackTest()
        let initialNoteText = notePrefix + getRandomId()
        let editedNoteText = notePrefix + getRandomId()

        trackStep()
        NoteList.addNoteTap()
        NoteEditorAssert.editorShown()

        trackStep()
        NoteEditor.clearAndEnterText(enteredValue: initialNoteText)
        NoteEditor.waitBeforeEditingText(delayInSeconds: 3, newText: editedNoteText)

        trackStep()
        NoteEditor.leaveEditor()
        NoteList.trashNote(noteName: editedNoteText)

        trackStep()
        Trash.open()
        Trash.restoreNote(noteName: editedNoteText)

        trackStep()
        NoteList.openAllNotes()
        NoteList.openNote(noteName: editedNoteText)
        NoteEditor.openHistory()
        HistoryAssert.historyShown()

        trackStep()
        History.setSliderPosition(position: 0.0)
        History.restoreNote()
        NoteEditorAssert.textViewWithExactValueShownOnce(value: initialNoteText)

        trackStep()
        History.close()
        NoteEditor.leaveEditor()
        NoteList.trashNote(noteName: initialNoteText)
    }

}
