import UIKit

// MARK: - SPCardViewController
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

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear

        addShadowView()
        setupContainerView()
        addChildViewController()
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

        containerView.backgroundColor = UIColor.simplenoteBackgroundColor.withAlphaComponent(0.97)
        containerView.layer.cornerRadius = Constants.cornerRadius
        containerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        containerView.layer.masksToBounds = true
    }

    func addChildViewController() {
        addChild(viewController)
        containerView.addFillingSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
}

// MARK: - Constants
//
private extension SPCardViewController {
    struct Constants {
        static let cornerRadius: CGFloat = 10.0
    }
}
