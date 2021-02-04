//
//  SimplenoteUITests.swift
//  SimplenoteUITests
//
//  Created by Sergiy Fedosov on 03.02.2021.
//  Copyright © 2021 Automattic. All rights reserved.
//

import XCTest

let app = XCUIApplication()

class SimplenoteUISmokeTestsLogin: XCTestCase {

    let testDataInvalidEmail = "user@gmail."
    let testDataNotExistingEmail = "nevergonnagiveyouup@gmail.com"
    let testDataInvalidPassword = "ABC"
    let testDataNotExistingPassword = "ABCD"

    override func setUpWithError() throws {
        app.launchArguments = ["enable-testing"]
        continueAfterFailure = true
        app.launch()
        let _ = attemptLogOut()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLogInWithNoEmailNoPassword() throws {
        EmailLogin.open()
        EmailLogin.logIn(email: "", password: "")

        Assert.labelExists(labelText: text_LoginEmailInvalid)
        Assert.labelExists(labelText: text_LoginPasswordShort)
    }

    func testLogInWithNoEmail() throws {
        EmailLogin.open()
        EmailLogin.logIn(email: "", password: testDataExistingPassword)

        Assert.labelExists(labelText: text_LoginEmailInvalid)
        Assert.labelAbsent(labelText: text_LoginPasswordShort)
    }

    func testLogInWithInvalidEmail() throws {
        EmailLogin.open()
        EmailLogin.logIn(email: testDataInvalidEmail, password: testDataExistingPassword)

        Assert.labelExists(labelText: text_LoginEmailInvalid)
        Assert.labelAbsent(labelText: text_LoginPasswordShort)
    }

    func testLogInWithNoPassword() throws {
        EmailLogin.open()
        EmailLogin.logIn(email: testDataExistingEmail, password: "")

        Assert.labelAbsent(labelText: text_LoginEmailInvalid)
        Assert.labelExists(labelText: text_LoginPasswordShort)
    }

    func testLogInWithTooShortPassword() throws {
        EmailLogin.open()
        EmailLogin.logIn(email: testDataExistingEmail, password: testDataInvalidPassword)

        Assert.labelAbsent(labelText: text_LoginEmailInvalid)
        Assert.labelExists(labelText: text_LoginPasswordShort)
    }

    func testLogInWithExistingEmailIncorrectPassword() throws {
        EmailLogin.open()
        EmailLogin.logIn(email: testDataExistingEmail, password: testDataNotExistingPassword)
        Assert.alertExistsAndClose(headingText: text_AlertHeading_Sorry, content: text_AlertContent_LoginFailed, buttonText: uidButton_Accept)
    }

    func testLogInWithCorrectCredentials() throws {
        EmailLogin.open()
        EmailLogin.logIn(email: testDataExistingEmail, password: testDataExistingPassword)
        AllNotesAssert.screenShown()
    }

    func testLogOut() throws {
        // Step 1
        EmailLogin.open()
        EmailLogin.logIn(email: testDataExistingEmail, password: testDataExistingPassword)
        AllNotesAssert.screenShown()

        // Step 2
        _ = logOut()
        Assert.signUpLogInScreenShown()
    }

    // Test below is automatically generated one, disabled for now to save time
    /*
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }*/
}

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
        app.launchArguments = ["enable-testing"]
        app.launch()
        let _ = attemptLogOut()
        EmailLogin.open()
        EmailLogin.logIn(email: testDataExistingEmail, password: testDataExistingPassword)
        AllNotes.waitForLoad()
    }

    override func setUpWithError() throws {
        continueAfterFailure = true
        app.launch()

        AllNotes.clearAllNotes()
        Trash.empty()
        AllNotes.open()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCanPreviewMarkdownBySwiping() throws {

        // Step 1
        AllNotes.addNoteTap()
        NoteEditorAssert.editorShown();

        // Step 2
        NoteEditor.markdownEnable()
        NoteEditor.clearAndEnterText(enteredValue: complexLinkRawText)
        NoteEditorAssert.wholeTextShown(text: complexLinkRawText)

        // Step 3
        NoteEditor.swipeToPreview()
        PreviewAssert.previewShown()
        PreviewAssert.wholeTextShown(text: complexLinkPreviewText)
    }

    func testCanFlipToEditMode() throws {

        // Step 1
        AllNotes.addNoteTap()
        NoteEditorAssert.editorShown();

        // Step 2
        NoteEditor.markdownEnable()
        NoteEditor.clearAndEnterText(enteredValue: complexLinkRawText)
        NoteEditorAssert.wholeTextShown(text: complexLinkRawText)

        // Step 3
        NoteEditor.swipeToPreview()
        PreviewAssert.previewShown()
        PreviewAssert.wholeTextShown(text: complexLinkPreviewText)

        // Step 4
        Preview.leavePreviewViaBackButton()
        NoteEditor.setFocus()
        NoteEditorAssert.editorShown()
        NoteEditorAssert.wholeTextShown(text: complexLinkRawText)
    }

    func testUndoUndoesTheLastEdit() throws {
        let editorText = "ABCD"

        // Step 1
        AllNotes.addNoteTap()
        NoteEditorAssert.editorShown();

        // Step 2
        NoteEditor.clearAndEnterText(enteredValue: editorText)
        NoteEditorAssert.wholeTextShown(text: editorText)

        // Step 3
        NoteEditor.undo()
        NoteEditorAssert.wholeTextShown(text: "")
    }

    func testAddedURLIsLinkified() throws {

        // Step 1
        AllNotes.addNoteTap()
        NoteEditorAssert.editorShown();

        // Step 2
        NoteEditor.markdownEnable()
        NoteEditor.clearAndEnterText(enteredValue: usualLinkText)
        NoteEditorAssert.wholeTextShown(text: usualLinkText)

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
        NoteEditorAssert.editorShown();

        // Step 2
        NoteEditor.markdownEnable()
        NoteEditor.clearAndEnterText(enteredValue: usualLinkText)
        NoteEditorAssert.wholeTextShown(text: usualLinkText)

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
        NoteEditorAssert.editorShown();

        // Step 2
        NoteEditor.markdownEnable()
        NoteEditor.clearAndEnterText(enteredValue: usualLinkText)
        NoteEditorAssert.wholeTextShown(text: usualLinkText)

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
        NoteEditorAssert.editorShown();

        // Step 2
        NoteEditor.markdownEnable()
        NoteEditor.clearAndEnterText(enteredValue: completeText)

        // Step 3
        NoteEditor.leaveEditor()
        AllNotesAssert.noteExists(noteName: completeText)

        // Step 4
        AllNotes.openNote(noteName: completeText)
        NoteEditorAssert.substringShown(text: checklistText)

        // Step 5
        NoteEditor.swipeToPreview()
        PreviewAssert.substringShown(text: checklistText)
        PreviewAssert.boxesStates(expectedCheckedBoxesNumber: 1, expectedEmptyBoxesNumber: 0)
    }

    func testCreateUncheckedItem() throws {
        let checklistText = "Unchecked Item"
        let completeText = "- [ ]" + checklistText

        // Step 1
        AllNotes.addNoteTap()
        NoteEditorAssert.editorShown();

        // Step 2
        NoteEditor.markdownEnable()
        NoteEditor.clearAndEnterText(enteredValue: completeText)

        // Step 3
        NoteEditor.leaveEditor()
        AllNotesAssert.noteExists(noteName: completeText)

        // Step 4
        AllNotes.openNote(noteName: completeText)
        NoteEditorAssert.substringShown(text: checklistText)

        // Step 5
        NoteEditor.swipeToPreview()
        PreviewAssert.substringShown(text: checklistText)
        PreviewAssert.boxesStates(expectedCheckedBoxesNumber: 0, expectedEmptyBoxesNumber: 1)
    }
}

class SimplenoteUISmokeTestsTrash: XCTestCase {

    override class func setUp() {
        app.launchArguments = ["enable-testing"]
        app.launch()
        let _ = attemptLogOut()
        EmailLogin.open()
        EmailLogin.logIn(email: testDataExistingEmail, password: testDataExistingPassword)
        AllNotes.waitForLoad()
    }

    override func setUpWithError() throws {
        continueAfterFailure = true
        app.launch()
        AllNotes.waitForLoad()
        AllNotes.clearAllNotes()
        Trash.empty()
        AllNotes.open()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCanViewTrashedNotes() throws {
        let noteOneName = "CanView"
        let noteTwoName = "Trashed"
        let noteThreeName = "Notes"

        // Step 1
        Trash.open()
        TrashAssert.notesNumber(expectedNotesNumber: 0)

        // Step 2
        AllNotes.open()
        AllNotes.createNoteAndLeaveEditor(noteName: noteOneName)
        AllNotes.createNoteAndLeaveEditor(noteName: noteTwoName)
        AllNotes.createNoteAndLeaveEditor(noteName: noteThreeName)
        AllNotesAssert.noteExists(noteName: noteOneName)
        AllNotesAssert.noteExists(noteName: noteTwoName)
        AllNotesAssert.noteExists(noteName: noteThreeName)
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

        // Step 1
        Trash.open()
        TrashAssert.notesNumber(expectedNotesNumber: 0)

        // Step 2
        AllNotes.open()
        AllNotes.createNoteAndLeaveEditor(noteName: noteOneName)
        AllNotes.createNoteAndLeaveEditor(noteName: noteTwoName)
        AllNotes.createNoteAndLeaveEditor(noteName: noteThreeName)
        AllNotesAssert.noteExists(noteName: noteOneName)
        AllNotesAssert.noteExists(noteName: noteTwoName)
        AllNotesAssert.noteExists(noteName: noteThreeName)
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

        // Step 1
        Trash.open()
        TrashAssert.notesNumber(expectedNotesNumber: 0)

        // Step 2
        AllNotes.open()
        AllNotes.createNoteAndLeaveEditor(noteName: noteOneName)
        AllNotes.createNoteAndLeaveEditor(noteName: noteTwoName)
        AllNotes.createNoteAndLeaveEditor(noteName: noteThreeName)
        AllNotesAssert.noteExists(noteName: noteOneName)
        AllNotesAssert.noteExists(noteName: noteTwoName)
        AllNotesAssert.noteExists(noteName: noteThreeName)
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

        // Step 1
        Trash.open()
        TrashAssert.notesNumber(expectedNotesNumber: 0)

        // Step 2
        AllNotes.open()
        AllNotes.createNoteAndLeaveEditor(noteName: noteOneName)
        AllNotes.createNoteAndLeaveEditor(noteName: noteTwoName)
        AllNotes.createNoteAndLeaveEditor(noteName: noteThreeName)
        AllNotesAssert.noteExists(noteName: noteOneName)
        AllNotesAssert.noteExists(noteName: noteTwoName)
        AllNotesAssert.noteExists(noteName: noteThreeName)
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
        AllNotesAssert.noteExists(noteName: noteOneName)
        AllNotesAssert.noteExists(noteName: noteTwoName)
        AllNotesAssert.noteExists(noteName: noteThreeName)
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
