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
        let loader = SPHistoryLoader(note: currentNote)
        let cardViewController = newHistoryViewController(with: loader, delegate: self)

        historyCardViewController = cardViewController
        historyLoader = loader

        cardViewController.present(from: self)

        adjustEditorBottomContentInset(accommodating: cardViewController.view)
        noteEditorTextView.isReadOnly = true

        refreshNavigationBarButtons()
    }

    private func newHistoryViewController(with loader: SPHistoryLoader, delegate: SPNoteHistoryControllerDelegate) -> SPCardViewController {
        let controller = SPNoteHistoryController(note: currentNote, loader: loader)
        let historyViewController = SPNoteHistoryViewController(controller: controller)
        let cardViewController = SPCardViewController(viewController: historyViewController)

        controller.delegate = delegate

        return cardViewController
    }

    /// Dismiss note history
    ///
    @objc(dismissHistoryAnimated:)
    func dismissHistory(animated: Bool) {
        guard let viewController = historyCardViewController else {
            return
        }

        historyCardViewController = nil
        historyLoader = nil

        viewController.dismiss(animated: true, completion: nil)

        noteEditorTextView.isReadOnly = false
        restoreDefaultEditorBottomContentInset(animated: true)

        refreshNavigationBarButtons()
        resetAccessibilityFocus()
    }
}

// MARK: - Editor bottom insets adjustments
//
private extension SPNoteEditorViewController {
    func adjustEditorBottomContentInset(accommodating bottomView: UIView) {
        guard let noteEditorSuperview = noteEditorTextView.superview else {
            return
        }
        let bottomViewFrame = noteEditorSuperview.convert(bottomView.bounds, from: bottomView)
        let bottomInset = noteEditorTextView.frame.maxY - bottomViewFrame.origin.y

        noteEditorTextView.contentInset.bottom = bottomInset
        noteEditorTextView.scrollIndicatorInsets.bottom = bottomInset
    }

    func restoreDefaultEditorBottomContentInset(animated: Bool) {
        let animationBlock = {
            self.noteEditorTextView.contentInset.bottom = self.noteEditorTextView.defaultBottomInset
            self.noteEditorTextView.scrollIndicatorInsets.bottom = 0
        }

        if animated {
            UIView.animate(withDuration: UIKitConstants.animationShortDuration,
                           animations: animationBlock)
        } else {
            animationBlock()
        }
    }
}

// MARK: - History Delegate
//
extension SPNoteEditorViewController: SPNoteHistoryControllerDelegate {
    func noteHistoryControllerDidCancel() {
        dismissHistory(animated: true)
        updateEditor(with: currentNote.content)
    }

    func noteHistoryControllerDidFinish() {
        dismissHistory(animated: true)
        isModified = true
        save()
    }

    func noteHistoryControllerDidSelectVersion(withContent content: String) {
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
