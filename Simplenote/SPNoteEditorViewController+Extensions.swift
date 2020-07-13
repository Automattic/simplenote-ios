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
    }

    private func newHistoryViewController(with loader: SPHistoryLoader, delegate: SPNoteHistoryControllerDelegate) -> SPCardViewController {
        let controller = SPNoteHistoryController(note: currentNote, loader: loader)
        let historyViewController = SPNoteHistoryViewController(controller: controller)
        let cardViewController = SPCardViewController(viewController: historyViewController)

        controller.delegate = delegate

        return cardViewController
    }

    private func dismissHistory() {
        guard let viewController = historyCardViewController else {
            return
        }

        historyCardViewController = nil
        historyLoader = nil

        viewController.dismiss(animated: true, completion: nil)
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
