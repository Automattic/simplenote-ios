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

    /// Setting the following constraints via XIB resulted in weird behaviour
    ///
    private(set) var containerTopToTopConstraint: NSLayoutConstraint!
    private(set) var containerTopToBottomConstraint: NSLayoutConstraint!

    private let viewController: UIViewController

    private var passthruView: PassthruView? {
        return view as? PassthruView
    }

    /// Callback is invoked when interacted with passthru view
    ///
    var onInteractionWithPassthruView: (() -> Void)? {
        get {
            passthruView?.onInteraction
        }

        set {
            passthruView?.onInteraction = newValue
        }
    }

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
        setupContainerConstraints()

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

    func setupContainerConstraints() {
        containerTopToTopConstraint = containerView.topAnchor.constraint(equalTo: view.topAnchor)
        containerTopToBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.topAnchor)
        containerTopToTopConstraint.isActive = true
    }

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
        viewController.attach(to: self, attachmentView: .into(containerView))
    }
}


// MARK: - Metrics
//
private enum Metrics {
    static let cornerRadius = CGFloat(10)
}
