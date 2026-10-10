import XCTest
@testable import Simplenote

@MainActor
class NoteEditorPopoverTests: XCTestCase {
    private var storage: MockupStorageManager!
    private var editor: PopoverTestEditorViewController!
    private var navigationController: SPNavigationController!
    private var window: UIWindow!
    private var scrollPositionCache: NoteScrollPositionCache!

    override func setUpWithError() throws {
        try super.setUpWithError()

        storage = MockupStorageManager()
        scrollPositionCache = NoteScrollPositionCache(storage: PopoverTestScrollPositionStorage(fileURL: URL(fileURLWithPath: "")))
        editor = PopoverTestEditorViewController(note: storage.insertSampleNote(contents: "A note to keep"))
        editor.scrollPositionCache = scrollPositionCache
        navigationController = SPNavigationController(rootViewController: editor)
        window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        window.layoutIfNeeded()

        let rendered = expectation(description: "Editor rendered before snapshot-based actions")
        DispatchQueue.main.async {
            rendered.fulfill()
        }
        wait(for: [rendered], timeout: 5)
        XCTAssertNotNil(editor.view.snapshotView(afterScreenUpdates: true))
    }

    override func tearDownWithError() throws {
        if navigationController.presentedViewController != nil {
            let dismissed = expectation(description: "Dismiss the test presentation")
            navigationController.dismiss(animated: false) {
                dismissed.fulfill()
            }
            wait(for: [dismissed], timeout: 5)
        }

        let replacementNotes = navigationController.viewControllers.compactMap { controller -> Note? in
            guard let replacement = controller as? SPNoteEditorViewController, replacement !== editor else {
                return nil
            }
            replacement.scrollPositionCache = scrollPositionCache
            return replacement.note
        }

        window.endEditing(true)
        window.isHidden = true
        window.rootViewController = nil
        window = nil
        navigationController = nil
        editor = nil
        storage = nil
        scrollPositionCache = nil
        SPAppDelegate.shared().window.makeKeyAndVisible()

        // EditorFactory inserts replacement notes into the app's context, not the in-memory test context.
        for note in replacementNotes {
            guard let context = note.managedObjectContext else {
                continue
            }
            context.delete(note)
            try context.save()
        }

        try super.tearDownWithError()
    }

    func testNewNoteDismissesInformationPopoverBeforeReplacingEditor() throws {
        try requireIPad()
        tap(editor.informationButton)
        let popover = try waitForPresentation(of: NoteInformationViewController.self)

        tap(editor.createNoteButton)

        waitForNewEditor()
        XCTAssertNil(popover.presentingViewController)
        XCTAssertNil(navigationController.presentedViewController)
        XCTAssertEqual(editor.note.content, "A note to keep")
    }

    func testNewNoteDismissesOptionsPopoverBeforeReplacingEditor() throws {
        try requireIPad()
        tap(editor.actionButton)
        let popover = try waitForPresentation(of: OptionsViewController.self)

        tap(editor.createNoteButton)

        waitForNewEditor()
        XCTAssertNil(popover.presentingViewController)
        XCTAssertNil(navigationController.presentedViewController)
    }

    func testOptionsButtonReplacesInformationPopover() throws {
        try requireIPad()
        tap(editor.informationButton)
        let informationPopover = try waitForPresentation(of: NoteInformationViewController.self)

        tap(editor.actionButton)

        let optionsPopover = try waitForPresentation(of: OptionsViewController.self)
        XCTAssertFalse(informationPopover === optionsPopover)
        XCTAssertNil(informationPopover.presentingViewController)
    }

    func testInformationButtonReplacesOptionsPopover() throws {
        try requireIPad()
        tap(editor.actionButton)
        let optionsPopover = try waitForPresentation(of: OptionsViewController.self)

        tap(editor.informationButton)

        let informationPopover = try waitForPresentation(of: NoteInformationViewController.self)
        XCTAssertFalse(optionsPopover === informationPopover)
        XCTAssertNil(optionsPopover.presentingViewController)
    }

    func testNewNoteDismissesPopoverAndKeepsExistingBlankNote() throws {
        try requireIPad()
        editor.note.content = ""
        editor.noteEditorTextView.text = ""
        tap(editor.actionButton)
        let popover = try waitForPresentation(of: OptionsViewController.self)

        tap(editor.createNoteButton)

        waitUntil { self.editor.presentedViewController == nil }
        XCTAssertNil(popover.presentingViewController)
        XCTAssertTrue(navigationController.topViewController === editor)
        XCTAssertTrue(editor.noteEditorTextView.isFirstResponder)
    }

    func testSwitchingPopoversPreservesMarkdownDismissalCallback() throws {
        try requireIPad()
        editor.note.markdown = false
        tap(editor.actionButton)
        _ = try waitForPresentation(of: OptionsViewController.self)
        editor.note.markdown = true

        tap(editor.informationButton)

        _ = try waitForPresentation(of: NoteInformationViewController.self)
        XCTAssertEqual(editor.markdownBounceCount, 1)
    }

    func testRepeatedNewNoteTapDuringDismissalReplacesEditorOnce() throws {
        try requireIPad()
        tap(editor.actionButton)
        _ = try waitForPresentation(of: OptionsViewController.self)

        tap(editor.createNoteButton)
        tap(editor.createNoteButton)

        waitForNewEditor()
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        XCTAssertEqual(editor.saveIfNeededCount, 1)
    }

    func testKeyboardCommandsRemainUnavailableWhilePopoverIsPresented() throws {
        try requireIPad()
        tap(editor.informationButton)
        _ = try waitForPresentation(of: NoteInformationViewController.self)

        XCTAssertNil(editor.keyCommands)
    }

    func testKeyboardNewNoteWithoutPopoverStillReplacesEditor() throws {
        let command = try XCTUnwrap(editor.keyCommands?.first { $0.input == "n" && $0.modifierFlags == .command })

        UIApplication.shared.sendAction(try XCTUnwrap(command.action), to: editor, from: command, for: nil)

        waitForNewEditor()
    }

    func testNewNoteWithoutPopoverStillReplacesEditor() {
        tap(editor.createNoteButton)

        waitForNewEditor()
        XCTAssertEqual(editor.saveIfNeededCount, 1)
    }

    func testCompactInformationStillUsesCardPresentation() throws {
        navigationController.setOverrideTraitCollection(UITraitCollection(horizontalSizeClass: .compact), forChild: editor)

        tap(editor.informationButton)

        let informationController = try waitForPresentation(of: NoteInformationViewController.self)
        XCTAssertTrue(informationController is NoteInformationViewController)
        XCTAssertEqual(informationController.modalPresentationStyle, .custom)
    }

    private func requireIPad() throws {
        try XCTSkipUnless(UIDevice.isPad, "Popover interactions require an iPad.")
    }

    private func tap(_ button: UIBarButtonItem) {
        guard let action = button.action else {
            XCTFail("Expected a button action")
            return
        }
        UIApplication.shared.sendAction(action, to: button.target, from: button, for: nil)
    }

    private func waitForPresentation<Content: UIViewController>(of type: Content.Type) throws -> UIViewController {
        waitUntil {
            guard let presented = self.editor.presentedViewController else {
                return false
            }
            let content = (presented as? UINavigationController)?.topViewController ?? presented
            return content is Content && !presented.isBeingPresented && presented.transitionCoordinator == nil
        }
        return try XCTUnwrap(editor.presentedViewController)
    }

    private func waitForNewEditor() {
        waitUntil { self.navigationController.topViewController !== self.editor }
        XCTAssertTrue((navigationController.topViewController as? SPNoteEditorViewController)?.note.isBlank == true)
    }

    private func waitUntil(_ condition: @escaping () -> Bool, file: StaticString = #filePath, line: UInt = #line) {
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in condition() }, object: nil)
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 5), .completed, file: file, line: line)
    }
}

private class PopoverTestEditorViewController: SPNoteEditorViewController {
    var markdownBounceCount = 0
    var saveIfNeededCount = 0

    override func bounceMarkdownPreview() {
        markdownBounceCount += 1
    }

    override func saveIfNeeded() {
        saveIfNeededCount += 1
        super.saveIfNeeded()
    }
}

private class PopoverTestScrollPositionStorage: FileStorage<NoteScrollPositionCache.ScrollCache> {
    private var data: NoteScrollPositionCache.ScrollCache?

    override func load() throws -> NoteScrollPositionCache.ScrollCache? {
        return data
    }

    override func save(object: NoteScrollPositionCache.ScrollCache) throws {
        data = object
    }
}
