import UIKit


class SharePresentationController: UIViewController {

    private let extensionTransitioningManager: ExtensionTransitioningManager = {
        let manager = ExtensionTransitioningManager()
        manager.presentDirection = .bottom
        manager.dismissDirection = .top
        return manager
    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadAndPresentMainVC()
    }
}


// MARK: - Private Helpers
//
private extension SharePresentationController {

    func setupAppearance() {
        // FIXME: We should account for dark mode when setting up these 👇 values in the near future.
        UINavigationBar.appearance().barTintColor = .white
        UINavigationBar.appearance().barStyle = .default
        UINavigationBar.appearance().tintColor = UIColor.simplenoteBlue()
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.simplenoteBlue()]
        UINavigationBar.appearance().isTranslucent = false
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
