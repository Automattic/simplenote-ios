import UIKit

// MARK: - SPCardViewController wraps passed viewController in a view with rounded corners and a shadow
//
final class SPCardViewController: UIViewController {
    private let viewController: UIViewController
    private let containerView = UIView()

    private var bottomToBottomConstraint: NSLayoutConstraint?
    private var topToBottomConstraint: NSLayoutConstraint?

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

// MARK: - Presentation
//
extension SPCardViewController {

    /// Presents card from another view controller animated
    ///
    func present(from viewController: UIViewController) {
        viewController.addChild(self)

        view.translatesAutoresizingMaskIntoConstraints = false
        guard let containerView = viewController.view else {
            fatalError("Can't load view")
        }
        containerView.addSubview(view)

        setupConstraints(withContainerView: containerView)

        containerView.layoutIfNeeded()

        let animations = {
            self.topToBottomConstraint?.isActive = false
            self.bottomToBottomConstraint?.isActive = true
            containerView.layoutIfNeeded()
        }

        let completion: (Bool) -> Void = { _ in
            self.didMove(toParent: viewController)
        }

        UIView.animate(withDuration: UIKitConstants.animationShortDuration,
                       animations: animations,
                       completion: completion)
    }

    /// Dismisses card
    ///
    override func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
        guard parent != nil else {
            return
        }

        willMove(toParent: nil)

        let animations = {
            self.bottomToBottomConstraint?.isActive = false
            self.topToBottomConstraint?.isActive = true
            self.view.superview?.layoutIfNeeded()
        }

        let animationCompletion: (Bool) -> Void = { _ in
            self.view.removeFromSuperview()
            self.removeFromParent()
            completion?()
        }

        if animated {
            UIView.animate(withDuration: UIKitConstants.animationShortDuration,
                           animations: animations,
                           completion: animationCompletion)
        } else {
            animationCompletion(true)
        }
    }

    private func setupConstraints(withContainerView containerView: UIView) {
        let bottomToBottomConstraint = view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        let topToBottomConstraint = view.topAnchor.constraint(equalTo: containerView.bottomAnchor)

        self.bottomToBottomConstraint = bottomToBottomConstraint
        self.topToBottomConstraint = topToBottomConstraint

        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            topToBottomConstraint
        ])
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
