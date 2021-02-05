import UIKit

// MARK: - SPMarkdownPreviewViewController
//
extension SPMarkdownPreviewViewController {
    open override var canBecomeFirstResponder: Bool {
        return true
    }

    open override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: "p",
                         modifierFlags: [.command, .shift],
                         action: #selector(keyboardToggleMarkdownPreview),
                         title: Localization.Shortcuts.toggleMarkdown)
        ]
    }

    @objc
    private func keyboardToggleMarkdownPreview() {
        SPTracker.trackShortcutToggleMarkdownPreview()
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Localization
//
private enum Localization {
    enum Shortcuts {
        static let toggleMarkdown = NSLocalizedString("Toggle Markdown", comment: "Keyboard shortcut: Toggle Markdown")
    }
}
