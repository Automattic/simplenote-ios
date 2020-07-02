import UIKit

extension SPNoteEditorViewController {

    @objc
    var isShowingHistory: Bool {
        return collaborators.historyCardViewController != nil
    }

    @objc
    func showHistory() {
        let loader = SPHistoryLoader(note: currentNote)
        let controller = SPNoteHistoryController(note: currentNote, loader: loader)
        let historyViewController = SPNoteHistoryViewController(controller: controller)
        let viewController = SPCardViewController(viewController: historyViewController)

        collaborators.historyLoader = loader
        collaborators.historyCardViewController = viewController

        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false

        let constraints = [
            viewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            viewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ]
        viewController.view.setContentHuggingPriority(.required, for: .vertical)
        NSLayoutConstraint.activate(constraints)

        viewController.didMove(toParent: self)

        controller.delegate = { [weak self] event in
            switch event {
            case .dismiss:
                self?.dismissHistory()
//                _noteEditorTextView.attributedText = [_currentNote.content attributedString]
//                [_noteEditorTextView processChecklists];
            case .preview:
                break
            case .restore:
                self?.dismissHistory()
//                bModified = YES;
//                [self save];
//                [_noteEditorTextView processChecklists];
            }
        }
    }

    @objc(handleVersion:data:)
    func handle(version: Int, data: [String: Any]) {
        collaborators.historyLoader?.process(data: data, forVersion: version)
    }
}

private extension SPNoteEditorViewController {
    func dismissHistory() {
        guard let viewController = collaborators.historyCardViewController else {
            return
        }

        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
}
