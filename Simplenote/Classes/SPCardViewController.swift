import UIKit

// MARK: - SPCardViewController wraps passed viewController in a view with rounded corners and a shadow
//
final class SPCardViewController: UIViewController {
    private let viewController: UIViewController
    private let containerView = UIView()

    init(viewController: UIViewController) {
        self.viewController = viewController
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        stopListeningToNotifications()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear

        addShadowView()
        setupContainerView()
        addChildViewController()

        refreshStyle()

        startListeningToNotifications()
    }
}

// MARK: - Private Methods
//
private extension SPCardViewController {
    func addShadowView() {
        let shadowView = SPShadowView(cornerRadius: Constants.cornerRadius,
                                      roundedCorners: [.topLeft, .topRight])
        view.addFillingSubview(shadowView)
    }

    func setupContainerView() {
        view.addFillingSubview(containerView)

        containerView.layer.cornerRadius = Constants.cornerRadius
        containerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        containerView.layer.masksToBounds = true
    }

    func addChildViewController() {
        addChild(viewController)
        containerView.addFillingSubview(viewController.view)
        viewController.didMove(toParent: self)
    }

    func refreshStyle() {
        containerView.backgroundColor = UIColor.simplenoteCardBackgroundColor.withAlphaComponent(Constants.backgroundAlpha)
    }
}

// MARK: - Notifications
//
private extension SPCardViewController {
    func startListeningToNotifications() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(themeDidChange), name: .VSThemeManagerThemeDidChange, object: nil)
    }

    func stopListeningToNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func themeDidChange() {
        refreshStyle()
    }
}

// MARK: - Constants
//
private extension SPCardViewController {
    struct Constants {
        static let cornerRadius: CGFloat = 10.0
        static let backgroundAlpha: CGFloat = 0.97
    }
}
