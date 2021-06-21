import UIKit

// MARK: - Keyboard shortcuts
//
extension SPSidebarContainerViewController {
    open override var canBecomeFirstResponder: Bool {
        return true
    }

    open override var keyCommands: [UIKeyCommand]? {
        guard presentedViewController == nil else {
            return nil
        }

        var commands = [
            UIKeyCommand(input: "n", modifierFlags: [.command], action: #selector(keyboardCreateNewNote), title: Localization.Shortcuts.newNote),
        ]

        if !noteListIsEditing() {
            commands.append(UIKeyCommand(input: "f", modifierFlags: [.command, .shift], action: #selector(keyboardStartSearching), title: Localization.Shortcuts.search))
        }

        let currentFirstResponder = UIResponder.currentFirstResponder
        if !(currentFirstResponder is UITextView) &&
            !(currentFirstResponder is UITextField) {

            commands.append(UIKeyCommand(input: UIKeyCommand.inputLeadingArrow, modifierFlags: [], action: #selector(keyboardGoBack)))
        }

        return commands
    }

    @objc
    private func keyboardGoBack() {
        if isSidebarVisible {
            hideSidebar(withAnimation: true)
            return
        }

        if let mainViewController = mainViewController as? UINavigationController, mainViewController.viewControllers.count > 1 {
            mainViewController.popViewController(animated: true)
            return
        }

        showSidebar()
    }

    private func noteListIsEditing() -> Bool {
        return SPAppDelegate.shared().noteListViewController.isEditing
    }

    @objc
    private func keyboardStartSearching() {
        SPTracker.trackShortcutSearch()
        SPAppDelegate.shared().presentSearch(animated: true)
    }

    @objc
    private func keyboardCreateNewNote() {
        SPTracker.trackShortcutCreateNote()
        SPAppDelegate.shared().presentNewNoteEditor(animated: true)
    }
}

private enum Localization {
    enum Shortcuts {
        static let search = NSLocalizedString("Search", comment: "Keyboard shortcut: Search")
        static let newNote = NSLocalizedString("New Note", comment: "Keyboard shortcut: New Note")
    }
}
