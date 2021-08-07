import XCTest

class SimplenoteUISmokeTestsNoteEditor: XCTestCase {
    let usualLinkText = "https://simplenote.com/"
    let complexLinkPreviewText = "Simplenote"
    let complexLinkRawText = "[Simplenote](https://simplenote.com/)"
    let webViewTexts = [String](
        arrayLiteral: "Simplenote",
        "The simplest way to keep notes",
        "All your notes, synced on all your devices. Get Simplenote now for iOS, Android, Mac, Windows, Linux, or in your browser.",
        "Sign up now")

    override class func setUp() {
        app.launch()
        getToAllNotes()
        let _ = attemptLogOut()
        EmailLogin.open()
        EmailLogin.logIn()

        // Extra check for certain emails
        if testDataEmail.contains("trial") {
            dismissVerifyEmailIfNeeded()
        }

        NoteList.waitForLoad()
    }

    override func setUpWithError() throws {
        getToAllNotes()
        NoteList.trashAllNotes()
        Trash.empty()
        NoteList.openAllNotes()
    }

    func testCanPreviewMarkdownBySwiping() throws {
        trackTest()

        trackStep()
        NoteList.addNoteTap()
        NoteEditorAssert.editorShown()

        trackStep()
        NoteEditor.markdownEnable()
        NoteEditor.clearAndEnterText(enteredValue: complexLinkRawText)
        NoteEditorAssert.textViewWithExactValueShownOnce(value: complexLinkRawText)

        trackStep()
        NoteEditor.swipeToPreview()
        PreviewAssert.previewShown()
        PreviewAssert.staticTextWithExactValueShownOnce(value: complexLinkPreviewText)
    }

    func testCanFlipToEditMode() throws {
        trackTest()

        trackStep()
        NoteList.addNoteTap()
        NoteEditorAssert.editorShown()

        trackStep()
        NoteEditor.markdownEnable()
        NoteEditor.clearAndEnterText(enteredValue: complexLinkRawText)
        NoteEditorAssert.textViewWithExactValueShownOnce(value: complexLinkRawText)

        trackStep()
        NoteEditor.swipeToPreview()
        PreviewAssert.previewShown()
        PreviewAssert.staticTextWithExactValueShownOnce(value: complexLinkPreviewText)

        trackStep()
        Preview.leavePreviewViaBackButton()
        NoteEditor.setFocus()
        NoteEditorAssert.editorShown()
        NoteEditorAssert.textViewWithExactValueShownOnce(value: complexLinkRawText)
    }

    func testUsingInsertChecklistInsertsChecklist() throws {
        trackTest()
        let noteTextInitial = "Inserting checkbox with a button",
            noteNameInitial = noteTextInitial,
            noteTextWithCheckbox = " " + noteTextInitial,
            noteNameWithCheckbox = "- [ ]" + noteTextWithCheckbox

        trackStep()
        NoteList.addNoteTap()
        NoteEditorAssert.editorShown()

        trackStep()
        NoteEditor.clearAndEnterText(enteredValue: noteTextInitial)
        NoteEditor.leaveEditor()
        NoteListAssert.noteExists(noteName: noteNameInitial)

        trackStep()
        NoteList.openNote(noteName: noteNameInitial)
        NoteEditor.markdownEnable()
        NoteEditorAssert.textViewWithExactValueShownOnce(value: noteTextInitial)

        trackStep()
        NoteEditor.swipeToPreview()
        PreviewAssert.staticTextWithExactValueShownOnce(value: noteTextInitial)
        PreviewAssert.boxesStates(expectedCheckedBoxesNumber: 0, expectedEmptyBoxesNumber: 0)

        trackStep()
        Preview.leavePreviewViaBackButton()
        NoteEditor.setFocus()
        NoteEditor.insertChecklist()
        NoteEditor.leaveEditor()
        NoteListAssert.noteExists(noteName: noteNameWithCheckbox)
        NoteListAssert.noteAbsent(noteName: noteNameInitial)

        trackStep()
        NoteList.openNote(noteName: noteNameWithCheckbox)
        NoteEditorAssert.textViewWithExactValueShownOnce(value: noteTextWithCheckbox)

        trackStep()
        NoteEditor.swipeToPreview()
        PreviewAssert.staticTextWithExactValueShownOnce(value: noteNameInitial)
        PreviewAssert.boxesStates(expectedCheckedBoxesNumber: 0, expectedEmptyBoxesNumber: 1)
    }

    func testUndoUndoesTheLastEdit() throws {
        trackTest()
        let editorText = "ABCD"

        trackStep()
        NoteList.addNoteTap()
        NoteEditorAssert.editorShown()

        trackStep()
        NoteEditor.clearAndEnterText(enteredValue: editorText)
        NoteEditorAssert.textViewWithExactValueShownOnce(value: editorText)

        trackStep()
        NoteEditor.undo()
        NoteEditorAssert.textViewWithExactValueNotShown(value: editorText)
        NoteEditorAssert.textViewWithExactValueShownOnce(value: "ABC")
    }

    func testAddedURLIsLinkified() throws {
        trackTest()

        trackStep()
        NoteList.addNoteTap()
        NoteEditorAssert.editorShown()

        trackStep()
        NoteEditor.markdownEnable()
        NoteEditor.clearAndEnterText(enteredValue: usualLinkText)
        NoteEditorAssert.textViewWithExactValueShownOnce(value: usualLinkText)

        trackStep()
        NoteEditor.leaveEditor()
        NoteListAssert.noteExists(noteName: usualLinkText)

        trackStep()
        NoteList.openNote(noteName: usualLinkText)
        NoteEditorAssert.linkifiedURL(containerText: usualLinkText, linkifiedText: usualLinkText)
    }

    func testLongTappingOnLinkOpensLinkInNewWindow() throws {
        trackTest()

        trackStep()
        NoteList.addNoteTap()
        NoteEditorAssert.editorShown()

        trackStep()
        NoteEditor.markdownEnable()
        NoteEditor.clearAndEnterText(enteredValue: usualLinkText)
        NoteEditorAssert.textViewWithExactValueShownOnce(value: usualLinkText)

        trackStep()
        NoteEditor.leaveEditor()
        NoteListAssert.noteExists(noteName: usualLinkText)

        trackStep()
        NoteList.openNote(noteName: usualLinkText)
        NoteEditorAssert.linkifiedURL(containerText: usualLinkText, linkifiedText: usualLinkText)

        trackStep()
        NoteEditor.pressLink(containerText: usualLinkText, linkifiedText: usualLinkText)
        WebViewAssert.textsShownOnScreen(texts: webViewTexts)
    }

    func testTappingOnLinkInPreviewOpensLinkInNewWindow() throws {
        trackTest()

        trackStep()
        NoteList.addNoteTap()
        NoteEditorAssert.editorShown()

        trackStep()
        NoteEditor.markdownEnable()
        NoteEditor.clearAndEnterText(enteredValue: usualLinkText)
        NoteEditorAssert.textViewWithExactValueShownOnce(value: usualLinkText)

        trackStep()
        NoteEditor.swipeToPreview()
        PreviewAssert.linkShown(linkText: usualLinkText)

        trackStep()
        Preview.tapLink(linkText: usualLinkText)
        WebViewAssert.textsShownOnScreen(texts: webViewTexts)
    }

    func testCreateCheckedItem() throws {
        trackTest()
        let checklistText = "Checked Item"
        let completeText = "- [x]" + checklistText

        trackStep()
        NoteList.addNoteTap()
        NoteEditorAssert.editorShown()

        trackStep()
        NoteEditor.markdownEnable()
        NoteEditor.clearAndEnterText(enteredValue: completeText)

        trackStep()
        NoteEditor.leaveEditor()
        NoteListAssert.noteExists(noteName: completeText)

        trackStep()
        NoteList.openNote(noteName: completeText)
        NoteEditorAssert.textViewWithExactValueShownOnce(value: checklistText)
        NoteEditorAssert.checkboxForTextShownOnce(text: checklistText)

        trackStep()
        NoteEditor.swipeToPreview()
        PreviewAssert.staticTextWithExactLabelShownOnce(label: checklistText)
        PreviewAssert.boxesStates(expectedCheckedBoxesNumber: 1, expectedEmptyBoxesNumber: 0)
    }

    func testCreateUncheckedItem() throws {
        trackTest()
        let checklistText = "Unchecked Item"
        let completeText = "- [ ]" + checklistText

        trackStep()
        NoteList.addNoteTap()
        NoteEditorAssert.editorShown()

        trackStep()
        NoteEditor.markdownEnable()
        NoteEditor.clearAndEnterText(enteredValue: completeText)

        trackStep()
        NoteEditor.leaveEditor()
        NoteListAssert.noteExists(noteName: completeText)

        trackStep()
        NoteList.openNote(noteName: completeText)
        NoteEditorAssert.textViewWithExactValueShownOnce(value: checklistText)
        NoteEditorAssert.checkboxForTextShownOnce(text: checklistText)

        trackStep()
        NoteEditor.swipeToPreview()
        PreviewAssert.staticTextWithExactLabelShownOnce(label: checklistText)
        PreviewAssert.boxesStates(expectedCheckedBoxesNumber: 0, expectedEmptyBoxesNumber: 1)
    }

    func testBulletedLists() throws {
        trackTest()
        let noteTitle = "Bulleted Lists"
        let noteContent = "\n\nMinuses:\n\n- Minus1\nMinus2\nMinus3" +
            "\n\nPluses:\n\n+ Plus1\nPlus2\nPlus3" +
            "\n\nAsterisks:\n\n* Asterisk1\nAsterisk2\nAsterisk3"

        trackStep()
        NoteList.addNoteTap()
        NoteEditorAssert.editorShown()
        NoteEditor.markdownEnable()

        trackStep()
        NoteEditor.clearAndEnterText(enteredValue: noteTitle + noteContent)
        NoteEditor.leaveEditor()
        NoteListAssert.noteExists(noteName: noteTitle)

        trackStep()
        NoteList.openNote(noteName: noteTitle)
        NoteEditorAssert.textViewWithExactLabelsShownOnce(labels: ["- Minus1", "- Minus2", "- Minus3"])
        NoteEditorAssert.textViewWithExactLabelsShownOnce(labels: ["+ Plus1", "+ Plus2", "+ Plus3"])
        NoteEditorAssert.textViewWithExactLabelsShownOnce(labels: ["* Asterisk1", "* Asterisk2", "* Asterisk3"])

        trackStep()
        NoteEditor.swipeToPreview()
        PreviewAssert.staticTextWithExactValuesShownOnce(values: ["• Minus1", "• Minus2", "• Minus3"])
        PreviewAssert.staticTextWithExactValuesShownOnce(values: ["• Plus1", "• Plus2", "• Plus3"])
        PreviewAssert.staticTextWithExactValuesShownOnce(values: ["• Asterisk1", "• Asterisk2", "• Asterisk3"])
    }

    func testSelectAllAndTrashNotes() throws {
        trackTest()
        let noteTitle = "Note Title"

        trackStep()
        populateNoteList(title: noteTitle, numberToCreate: 2)

        trackStep()
        NoteList.longPressNote(title: noteTitle + "-1")
        NoteList.selectNoteFromContextMenu()
        NoteList.selectAll()
        NoteListAssert.deselectAllButtonDisplayed()

        trackStep()
        NoteList.tapTrashNotesButton()
        NoteListAssert.notesNumber(expectedNotesNumber: 0)

        trackStep()
        Trash.open()
        TrashAssert.notesNumber(expectedNotesNumber: 2)
        TrashAssert.noteExists(noteName: noteTitle + "-1")
        TrashAssert.noteExists(noteName: noteTitle + "-2")
    }

    func testUndoTrashFromSnackbar() throws {
        trackTest()
        let noteName = "Note Title"

        trackStep()
        populateNoteList(title: noteName, numberToCreate: 1)

        trackStep()
        NoteList.longPressNote(title: noteName + "-1")
        NoteList.deleteNoteFromContextMenu()
        NoteListAssert.notesNumber(expectedNotesNumber: 0)

        trackStep()
        NoteList.tapUndoOnSnackbar()
        NoteListAssert.notesNumber(expectedNotesNumber: 1)
        NoteListAssert.noteExists(noteName: noteName + "-1")
    }

    func testCopyAndPasteInterlink() throws {
        trackTest()
        let toCopyNoteTitle = "Copy Internal Link Title"
        let toPasteNoteTitle = "Paste Internal Link Title\n"
        let note = NoteData(
            name: "Paste Internal Link Title",
            content: "[Copy Internal Link Title-1](simplenote://note/"
        )

        trackStep()
        populateNoteList(title: toCopyNoteTitle, numberToCreate: 1)

        trackStep()
        NoteList.longPressNote(title: toCopyNoteTitle + "-1")
        NoteList.copyInternalLinkFromContextMenu()

        trackStep()
        NoteList.addNoteTap()
        NoteEditor.enterTitle(enteredValue: toPasteNoteTitle)
        NoteEditor.pasteNoteContent()
        NoteEditor.leaveEditor()

        trackStep()
        NoteListAssert.notesNumber(expectedNotesNumber: 2)
        NoteListAssert.contentIsShown(for: note)
    }
}
