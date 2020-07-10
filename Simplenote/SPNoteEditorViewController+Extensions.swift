import UIKit

// MARK: - History
//
extension SPNoteEditorViewController {

    /// Indicates if note history is shown on screen
    ///
    @objc
    var isShowingHistory: Bool {
        return historyCardViewController != nil
    }

    /// Shows note history
    ///
    @objc
    func showHistory() {
        let viewController = newHistoryViewController()
        viewController.present(from: self)

        adjustBottomContentInset(forHistoryView: viewController.view)
        noteEditorTextView.isReadOnly = true

        refreshNavigationBarButtons()
    }

    private func newHistoryViewController() -> SPCardViewController {
        let loader = SPHistoryLoader(note: currentNote)
        let controller = SPNoteHistoryController(note: currentNote, loader: loader)
        let historyViewController = SPNoteHistoryViewController(controller: controller)
        let cardViewController = SPCardViewController(viewController: historyViewController)

        controller.delegate = self

        historyLoader = loader
        historyCardViewController = cardViewController

        return cardViewController
    }

    private func dismissHistory() {
        guard let viewController = historyCardViewController else {
            return
        }

        historyCardViewController = nil
        historyLoader = nil

        viewController.dismiss(animated: true, completion: nil)

        noteEditorTextView.isReadOnly = false
        UIView.animate(withDuration: UIKitConstants.animationShortDuration) {
            self.restoreDefaultBottomContentInset()
        }

        refreshNavigationBarButtons()
        resetAccessibilityFocus()
    }
}

// MARK: - Editor insets adjustments
//
private extension SPNoteEditorViewController {
    func adjustBottomContentInset(forHistoryView historyView: UIView) {
        guard let noteEditorSuperview = noteEditorTextView.superview else {
            return
        }
        let historyFrame = noteEditorSuperview.convert(historyView.bounds, from: historyView)
        let bottomInset = noteEditorTextView.frame.maxY - historyFrame.origin.y

        noteEditorTextView.contentInset.bottom = bottomInset
        noteEditorTextView.scrollIndicatorInsets.bottom = bottomInset
    }

    func restoreDefaultBottomContentInset() {
        noteEditorTextView.contentInset.bottom = noteEditorTextView.defaultBottomInset
        noteEditorTextView.scrollIndicatorInsets.bottom = 0
    }
}

// MARK: - History Delegate
//
extension SPNoteEditorViewController: SPNoteHistoryControllerDelegate {
    func noteHistoryControllerDidCancel() {
        dismissHistory()
        updateEditor(with: currentNote.content)
    }

    func noteHistoryControllerDidFinish() {
        dismissHistory()
        isModified = true
        save()
    }

    func noteHistoryControllerDidSelectVersion(with content: String) {
        updateEditor(with: content, animated: true)
    }
}

// MARK: - Editor
//
private extension SPNoteEditorViewController {
    func updateEditor(with content: String, animated: Bool = false) {
        let contentUpdateBlock = {
            self.noteEditorTextView.attributedText = NSAttributedString(string: content)
            self.noteEditorTextView.processChecklists()
        }

        guard animated, let snapshot = noteEditorTextView.snapshotView(afterScreenUpdates: false) else {
            contentUpdateBlock()
            return
        }

        snapshot.frame = noteEditorTextView.frame
        view.insertSubview(snapshot, aboveSubview: noteEditorTextView)

        contentUpdateBlock()

        let animations = { () -> Void in
            snapshot.alpha = 0.0
        }

        let completion: (Bool) -> Void = { _ in
            snapshot.removeFromSuperview()
        }

        UIView.animate(withDuration: UIKitConstants.animationShortDuration,
                       animations: animations,
                       completion: completion)
    }
}

// MARK: - Accessibility
//
private extension SPNoteEditorViewController {
    func resetAccessibilityFocus() {
        UIAccessibility.post(notification: .layoutChanged, argument: nil)
    }
}
