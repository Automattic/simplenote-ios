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
        guard #available(iOS 13, *) else {
            setupAppearanceIOS10()
            return
        }

        setupAppearanceIOS12()
    }

    func setupAppearanceIOS10() {
        let appearance = UINavigationBar.appearance()
        appearance.barTintColor = .white
        appearance.barStyle = .default
        appearance.tintColor = UIColor.simplenoteBlue()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.isTranslucent = false
    }

    @available (iOS 12, *)
    func setupAppearanceIOS12() {
        let appearance = UINavigationBar.appearance()
        appearance.barTintColor = .simplenoteBackgroundColor
        appearance.barStyle = .default
        appearance.tintColor = .simplenoteTintColor
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.simplenoteNavigationBarTitleColor
        ]
        appearance.isTranslucent = false
    }
}
