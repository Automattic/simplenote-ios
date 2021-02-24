import UIKit


class SharePresentationController: UIViewController {

    private let extensionTransitioningManager: ExtensionTransitioningManager = {
        let manager = ExtensionTransitioningManager()
        manager.presentDirection = .bottom
        manager.dismissDirection = .bottom
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


// MARK: - Appearance Helpers
//
private extension SharePresentationController {

    func setupAppearance() {
        let navbarAppearance = UINavigationBar.appearance()
        navbarAppearance.barTintColor = .simplenoteBackgroundColor
        navbarAppearance.barStyle = .default
        navbarAppearance.tintColor = .simplenoteTintColor
        navbarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.simplenoteNavigationBarTitleColor
        ]
        navbarAppearance.isTranslucent = false

        let barButtonTitleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.simplenoteTintColor
        ]

        let barButtonAppearance = UIBarButtonItem.appearance()
        barButtonAppearance.tintColor = .simplenoteTintColor
        barButtonAppearance.setTitleTextAttributes(barButtonTitleAttributes, for: .normal)
    }
}
