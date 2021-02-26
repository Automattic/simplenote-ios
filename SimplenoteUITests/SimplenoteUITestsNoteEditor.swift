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
        EmailLogin.logIn(email: testDataExistingEmail, password: testDataExistingPassword)
        AllNotes.waitForLoad()
    }

    override func setUpWithError() throws {
        getToAllNotes()
        AllNotes.clearAllNotes()
        Trash.empty()
        AllNotes.open()
    }

    func testCanPreviewMarkdownBySwiping() throws {

        // Step 1
        AllNotes.addNoteTap()
        NoteEditorAssert.editorShown()

        // Step 2
        NoteEditor.markdownEnable()
        NoteEditor.clearAndEnterText(enteredValue: complexLinkRawText)
        NoteEditorAssert.textViewWithExactValueShownOnce(value: complexLinkRawText)

        // Step 3
        NoteEditor.swipeToPreview()
        PreviewAssert.previewShown()
        PreviewAssert.staticTextWithExactValueShownOnce(value: complexLinkPreviewText)
        //PreviewAssert.wholeTextShown(text: complexLinkPreviewText)
    }

    func testCanFlipToEditMode() throws {

        // Step 1
        AllNotes.addNoteTap()
        NoteEditorAssert.editorShown()

        // Step 2
        NoteEditor.markdownEnable()
        NoteEditor.clearAndEnterText(enteredValue: complexLinkRawText)
        NoteEditorAssert.textViewWithExactValueShownOnce(value: complexLinkRawText)

        // Step 3
        NoteEditor.swipeToPreview()
        PreviewAssert.previewShown()
        PreviewAssert.staticTextWithExactValueShownOnce(value: complexLinkPreviewText)
        //PreviewAssert.wholeTextShown(text: complexLinkPreviewText)

        // Step 4
        Preview.leavePreviewViaBackButton()
        NoteEditor.setFocus()
        NoteEditorAssert.editorShown()
        NoteEditorAssert.textViewWithExactValueShownOnce(value: complexLinkRawText)
    }

    func testUsingInsertChecklistInsertsChecklist() throws {
        let noteTextInitial = "Inserting checkbox with a button",
            noteNameInitial = noteTextInitial,
            noteTextWithCheckbox = " " + noteTextInitial,
            noteNameWithCheckbox = "- [ ]" + noteTextWithCheckbox

        trackTest()

        trackStep()
        AllNotes.addNoteTap()
        NoteEditorAssert.editorShown()

        trackStep()
        NoteEditor.clearAndEnterText(enteredValue: noteTextInitial)
        NoteEditor.leaveEditor()
        AllNotesAssert.noteExists(noteName: noteNameInitial)

        trackStep()
        AllNotes.openNote(noteName: noteNameInitial)
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
        AllNotesAssert.noteExists(noteName: noteNameWithCheckbox)
        AllNotesAssert.noteAbsent(noteName: noteNameInitial)

        trackStep()
        AllNotes.openNote(noteName: noteNameWithCheckbox)
        NoteEditorAssert.textViewWithExactValueShownOnce(value: noteTextWithCheckbox)

        trackStep()
        NoteEditor.swipeToPreview()
        PreviewAssert.staticTextWithExactValueShownOnce(value: noteNameInitial)
        PreviewAssert.boxesStates(expectedCheckedBoxesNumber: 0, expectedEmptyBoxesNumber: 1)
    }

    func testUndoUndoesTheLastEdit() throws {
        let editorText = "ABCD"

        // Step 1
        AllNotes.addNoteTap()
        NoteEditorAssert.editorShown()

        // Step 2
        NoteEditor.clearAndEnterText(enteredValue: editorText)
        NoteEditorAssert.textViewWithExactValueShownOnce(value: editorText)

        // Step 3
        NoteEditor.undo()
        NoteEditorAssert.textViewWithExactValueNotShown(value: editorText)
        NoteEditorAssert.textViewWithExactValueShownOnce(value: "ABC")
    }

    func testAddedURLIsLinkified() throws {

        // Step 1
        AllNotes.addNoteTap()
        NoteEditorAssert.editorShown()

        // Step 2
        NoteEditor.markdownEnable()
        NoteEditor.clearAndEnterText(enteredValue: usualLinkText)
        NoteEditorAssert.textViewWithExactValueShownOnce(value: usualLinkText)

        // Step 3
        NoteEditor.leaveEditor()
        AllNotesAssert.noteExists(noteName: usualLinkText)

        // Step 4
        AllNotes.openNote(noteName: usualLinkText)
        NoteEditorAssert.linkifiedURL(containerText: usualLinkText, linkifiedText: usualLinkText)
    }

    func testLongTappingOnLinkOpensLinkInNewWindow() throws {

        // Step 1
        AllNotes.addNoteTap()
        NoteEditorAssert.editorShown()

        // Step 2
        NoteEditor.markdownEnable()
        NoteEditor.clearAndEnterText(enteredValue: usualLinkText)
        NoteEditorAssert.textViewWithExactValueShownOnce(value: usualLinkText)

        // Step 3
        NoteEditor.leaveEditor()
        AllNotesAssert.noteExists(noteName: usualLinkText)

        // Step 4
        AllNotes.openNote(noteName: usualLinkText)
        //NoteEditorAssert.editorText(text: usualURL)
        NoteEditorAssert.linkifiedURL(containerText: usualLinkText, linkifiedText: usualLinkText)

        // Step 5
        NoteEditor.pressLink(containerText: usualLinkText, linkifiedText: usualLinkText)
        for text in webViewTexts {
            WebViewAssert.textShownOnScreen(textToFind: text)
        }
    }

    func testTappingOnLinkInPreviewOpensLinkInNewWindow() throws {

        // Step 1
        AllNotes.addNoteTap()
        NoteEditorAssert.editorShown()

        // Step 2
        NoteEditor.markdownEnable()
        NoteEditor.clearAndEnterText(enteredValue: usualLinkText)
        NoteEditorAssert.textViewWithExactValueShownOnce(value: usualLinkText)

        // Step 3
        NoteEditor.swipeToPreview()
        PreviewAssert.linkShown(linkText: usualLinkText)

        // Step 4
        Preview.tapLink(linkText: usualLinkText)
        for text in webViewTexts {
            WebViewAssert.textShownOnScreen(textToFind: text)
        }
    }

    func testCreateCheckedItem() throws {
        let checklistText = "Checked Item"
        let completeText = "- [x]" + checklistText

        // Step 1
        AllNotes.addNoteTap()
        NoteEditorAssert.editorShown()

        // Step 2
        NoteEditor.markdownEnable()
        NoteEditor.clearAndEnterText(enteredValue: completeText)

        // Step 3
        NoteEditor.leaveEditor()
        AllNotesAssert.noteExists(noteName: completeText)

        // Step 4
        AllNotes.openNote(noteName: completeText)
        NoteEditorAssert.textViewWithExactValueShownOnce(value: checklistText)
        NoteEditorAssert.checkboxForTextShownOnce(text: checklistText)

        // Step 5
        NoteEditor.swipeToPreview()
        //PreviewAssert.substringShown(text: checklistText)
        PreviewAssert.staticTextWithExactLabelShownOnce(label: checklistText)
        PreviewAssert.boxesStates(expectedCheckedBoxesNumber: 1, expectedEmptyBoxesNumber: 0)
    }

    func testCreateUncheckedItem() throws {
        let checklistText = "Unchecked Item"
        let completeText = "- [ ]" + checklistText

        // Step 1
        AllNotes.addNoteTap()
        NoteEditorAssert.editorShown()

        // Step 2
        NoteEditor.markdownEnable()
        NoteEditor.clearAndEnterText(enteredValue: completeText)

        // Step 3
        NoteEditor.leaveEditor()
        AllNotesAssert.noteExists(noteName: completeText)

        // Step 4
        AllNotes.openNote(noteName: completeText)
        NoteEditorAssert.textViewWithExactValueShownOnce(value: checklistText)
        NoteEditorAssert.checkboxForTextShownOnce(text: checklistText)

        // Step 5
        NoteEditor.swipeToPreview()
        //PreviewAssert.substringShown(text: checklistText)
        PreviewAssert.staticTextWithExactLabelShownOnce(label: checklistText)
        PreviewAssert.boxesStates(expectedCheckedBoxesNumber: 0, expectedEmptyBoxesNumber: 1)
    }

    func testBulletedLists() throws {
        let noteTitle = "Bulleted Lists"
        let noteContent = "\n\nMinuses:\n\n- Minus1\nMinus2\nMinus3" +
            "\n\nPluses:\n\n+ Plus1\nPlus2\nPlus3" +
            "\n\nAsterisks:\n\n* Asterisk1\nAsterisk2\nAsterisk3"

        trackTest()

        trackStep()
        AllNotes.addNoteTap()
        NoteEditorAssert.editorShown()

        trackStep()
        NoteEditor.clearAndEnterText(enteredValue: noteTitle + noteContent)
        NoteEditor.leaveEditor()
        AllNotesAssert.noteExists(noteName: noteTitle)

        trackStep()
        AllNotes.openNote(noteName: noteTitle)
        NoteEditorAssert.textViewWithExactLabelsShownOnce(labels: ["- Minus1", "- Minus2", "- Minus3"])
        NoteEditorAssert.textViewWithExactLabelsShownOnce(labels: ["+ Plus1", "+ Plus2", "+ Plus3"])
        NoteEditorAssert.textViewWithExactLabelsShownOnce(labels: ["* Asterisk1", "* Asterisk2", "* Asterisk3"])

        trackStep()
        NoteEditor.markdownEnable()
        NoteEditor.swipeToPreview()
        PreviewAssert.staticTextWithExactValuesShownOnce(values: ["• Minus1", "• Minus2", "• Minus3"])
        PreviewAssert.staticTextWithExactValuesShownOnce(values: ["• Plus1", "• Plus2", "• Plus3"])
        PreviewAssert.staticTextWithExactValuesShownOnce(values: ["• Asterisk1", "• Asterisk2", "• Asterisk3"])
    }
}
