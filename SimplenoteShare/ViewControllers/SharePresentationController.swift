import UIKit



class SharePresentationController: UIViewController {

    private let extensionTransitioningManager: ExtensionTransitioningManager = {
        let manager = ExtensionTransitioningManager()
        manager.direction = .bottom
        return manager
    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        loadAndPresentMainVC()
    }
}

// MARK: - Private Helpers

private extension SharePresentationController {
    func setupAppearance() {
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.barTintColor = .brown
        navigationBarAppearace.barStyle = .default
        navigationBarAppearace.tintColor = .green
        navigationBarAppearace.titleTextAttributes = [.foregroundColor: UIColor.red]
        navigationBarAppearace.isTranslucent = false
    }

    func loadAndPresentMainVC() {
        let shareController = ShareViewController(context: extensionContext)
        shareController.dismissalCompletionBlock = {
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }

        let shareNavController = UINavigationController(rootViewController: shareController)
        shareNavController.transitioningDelegate = extensionTransitioningManager
        shareNavController.modalPresentationStyle = .custom

        present(shareNavController, animated: true)
    }

}
