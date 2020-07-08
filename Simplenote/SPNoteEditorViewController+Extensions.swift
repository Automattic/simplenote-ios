import UIKit

// MARK: - History
//
extension SPNoteEditorViewController {

    /// Indicates if note history is shown on screen
    ///
    @objc
    var isShowingHistory: Bool {
        return swiftCollaborators.historyCardViewController != nil
    }

    /// Receives a note version. This is called from objc counterpart, which has delegate methods from Simperium
    ///
    @objc(handleVersion:data:)
    func handle(version: Int, data: [String: Any]) {
        swiftCollaborators.historyLoader?.process(data: data, forVersion: version)
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

        swiftCollaborators.historyLoader = loader
        swiftCollaborators.historyCardViewController = cardViewController

        return cardViewController
    }

    private func dismissHistory() {
        guard let viewController = swiftCollaborators.historyCardViewController else {
            return
        }
        swiftCollaborators.historyCardViewController = nil
        swiftCollaborators.historyLoader = nil

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
        var snapshot: UIView?
        if animated {
            snapshot = noteEditorTextView.snapshotView(afterScreenUpdates: false)
            if let snapshot = snapshot {
                snapshot.frame = noteEditorTextView.frame
                view.insertSubview(snapshot, aboveSubview: noteEditorTextView)
            }
        }

        noteEditorTextView.attributedText = NSAttributedString(string: content)
        noteEditorTextView.processChecklists()

        if animated {
            let animations = { () -> Void in
                snapshot?.alpha = 0.0
            }

            let completion: (Bool) -> Void = { _ in
                snapshot?.removeFromSuperview()
            }

            UIView.animate(withDuration: UIKitConstants.animationShortDuration,
                           animations: animations,
                           completion: completion)
        }
    }
}

// MARK: - Accessibility
//
private extension SPNoteEditorViewController {
    func resetAccessibilityFocus() {
        UIAccessibility.post(notification: .layoutChanged, argument: nil)
    }
}
