import UIKit

// MARK: - History
//
extension SPNoteEditorViewController {

    /// Indicates if note history is shown on screen
    ///
    @objc
    var isShowingHistory: Bool {
        return historyViewController != nil
    }

    /// Shows note history
    ///
    @objc
    func showHistory() {
        let loader = SPHistoryLoader(note: currentNote)
        let viewController = newHistoryViewController(with: loader, delegate: self)

        historyViewController = viewController
        historyLoader = loader

        let transitioningManager = SPCardTransitioningManager()
        transitioningManager.presentationDelegate = self
        historyTransitioningManager = transitioningManager

        present(viewController, with: transitioningManager)
    }

    private func newHistoryViewController(with loader: SPHistoryLoader,
                                          delegate: SPNoteHistoryControllerDelegate) -> UIViewController {
        let controller = SPNoteHistoryController(note: currentNote, loader: loader)
        let historyViewController = SPNoteHistoryViewController(controller: controller)

        controller.delegate = delegate

        return historyViewController
    }

    /// Dismiss note history
    ///
    @objc(dismissHistoryAnimated:)
    func dismissHistory(animated: Bool) {
        guard let viewController = historyViewController else {
            return
        }

        cleanUpAfterHistoryDismissal()
        viewController.dismiss(animated: animated, completion: nil)

        resetAccessibilityFocus()
    }

    private func cleanUpAfterHistoryDismissal() {
        historyViewController = nil
        historyLoader = nil
        historyTransitioningManager = nil
    }
}

// MARK: - History Delegate
//
extension SPNoteEditorViewController: SPNoteHistoryControllerDelegate {
    func noteHistoryControllerDidCancel() {
        dismissHistory(animated: true)
        restoreOriginalNoteContent()
    }

    func noteHistoryControllerDidFinish() {
        dismissHistory(animated: true)
        isModified = true
        save()
    }

    func noteHistoryControllerDidSelectVersion(with content: String) {
        updateEditor(with: content, animated: true)
    }
}

// MARK: - History Card transition delegate
//
extension SPNoteEditorViewController: SPCardPresentationControllerDelegate {
    func cardWasSwipedToDismiss(_ viewController: UIViewController) {
        cleanUpAfterHistoryDismissal()
        restoreOriginalNoteContent()
    }
}

// MARK: - Transitioning
//
private extension SPNoteEditorViewController {
    func present(_ viewController: UIViewController, with transitioningManager: UIViewControllerTransitioningDelegate) {
        viewController.transitioningDelegate = transitioningManager
        viewController.modalPresentationStyle = .custom

        present(viewController, animated: true, completion: nil)
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

    func restoreOriginalNoteContent() {
        updateEditor(with: currentNote.content, animated: true)
    }
}

// MARK: - Accessibility
//
private extension SPNoteEditorViewController {
    func resetAccessibilityFocus() {
        UIAccessibility.post(notification: .layoutChanged, argument: nil)
    }
}
