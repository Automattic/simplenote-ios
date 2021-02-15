import UIKit


// MARK: - PopoverViewController
//
class PopoverViewController: UIViewController {

    /// Container view
    ///
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var backgroundView: UIVisualEffectView!
    @IBOutlet private var shadowView: SPShadowView!

    /// Layout Constraints for Container View
    ///
    @IBOutlet private(set) var containerLeftConstraint: NSLayoutConstraint!
    @IBOutlet private(set) var containerMaxHeightConstraint: NSLayoutConstraint!
    @IBOutlet private(set) var containerTopToTopConstraint: NSLayoutConstraint!
    @IBOutlet private(set) var containerTopToBottomConstraint: NSLayoutConstraint!

    private let viewController: UIViewController

    init(viewController: UIViewController) {
        self.viewController = viewController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overridden API(s)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRootView()
        setupBackgroundView()
        setupContainerView()
        setupShadowView()
        setupContainerViewController()
    }
}


// MARK: - Initialization
//
private extension PopoverViewController {

    func setupRootView() {
        view.backgroundColor = .clear
    }

    func setupBackgroundView() {
        backgroundView.backgroundColor = .simplenoteAutocompleteBackgroundColor
        backgroundView.layer.cornerRadius = Metrics.cornerRadius
        backgroundView.layer.masksToBounds = true
    }

    func setupContainerView() {
        containerView.backgroundColor = .clear
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = Metrics.cornerRadius
    }

    func setupShadowView() {
        shadowView.cornerRadius = Metrics.cornerRadius
    }

    func setupContainerViewController() {
        if viewController.parent != nil && viewController.parent != self {
            viewController.willMove(toParent: nil)
            viewController.view.removeFromSuperview()
            viewController.removeFromParent()
        }

        addChild(viewController)
        containerView.addFillingSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
}


// MARK: - Metrics
//
private enum Metrics {
    static let cornerRadius = CGFloat(10)
}
