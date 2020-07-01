import UIKit

extension SPNoteEditorViewController {

    @objc func showHistory() {
        let historyViewController = SPNoteHistoryViewController()
        let viewController = SPCardViewController(viewController: historyViewController)

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

        historyViewController.eventHandler = { [weak viewController] event in
            switch event {
            case .close:
                viewController?.willMove(toParent: nil)
                viewController?.view.removeFromSuperview()
                viewController?.removeFromParent()
            }
        }
    }

}
