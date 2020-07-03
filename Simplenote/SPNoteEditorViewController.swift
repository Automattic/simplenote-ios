import UIKit

// MARK: - SPNoteEditorViewController: Extension for swift code
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

        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            viewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            viewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
        viewController.view.setContentHuggingPriority(.required, for: .vertical)

        viewController.didMove(toParent: self)
    }

    private func newHistoryViewController() -> UIViewController {
        let loader = SPHistoryLoader(note: currentNote)
        let controller = SPNoteHistoryController(note: currentNote, loader: loader)
        let historyViewController = SPNoteHistoryViewController(controller: controller)
        let cardViewController = SPCardViewController(viewController: historyViewController)

        controller.delegate = { [weak self] event in
            guard let self = self else {
                return
            }

            switch event {
            case .dismiss:
                self.dismissHistory()
                self.updateEditor(with: self.currentNote.content)

            case .preview(let content):
                self.updateEditor(with: content, animated: true)

            case .restore:
                self.dismissHistory()
                self.isModified = true
                self.save()
            }
        }

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

        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
}

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
