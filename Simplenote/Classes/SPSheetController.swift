import Foundation
import UIKit


// MARK: - Renders a customized Action Sheet
//
class SPSheetController: UIViewController {

    /// Dimming Background
    ///
    @IBOutlet private var backgroundView: UIView!

    /// View containing the bottom actions
    ///
    @IBOutlet private var actionsView: UIView!

    /// Constraint attaching the Actions View to the bottom of its container
    ///
    @IBOutlet private var actionsBottomConstraint: NSLayoutConstraint!

    /// Button #0: Top Button!
    ///
    @IBOutlet private var button0: SPSquaredButton! {
        didSet {
            button0.backgroundColor = .simplenoteBlue50Color
        }
    }

    /// Button #1: Bottom Button!
    ///
    @IBOutlet private var button1: SPSquaredButton! {
        didSet {
            button1.backgroundColor = .simplenoteWPBlue50Color
        }
    }

    /// Closure to be executed whenever button0 is clicked
    ///
    var onClickButton0: (() -> Void)?

    /// Closure to be executed whenever button1 is clicked
    ///
    var onClickButton1: (() -> Void)?



    /// Designated Initializer
    ///
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
    }

    /// Required!
    ///
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Required Methods

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideSubviews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        performSlideUpAnimation()
    }


    // MARK: - Public Methods

    func present(from viewController: UIViewController) {
        guard let containerView = viewController.view else {
            fatalError()
        }

        viewController.addChild(self)
        attachView(to: containerView)
    }

    func setTitleForButton0(title: String) {
        loadViewIfNeeded()
        button0.setTitle(title, for: .normal)
    }

    func setTitleForButton1(title: String) {
        loadViewIfNeeded()
        button1.setTitle(title, for: .normal)
    }
}


// MARK: - Private Methods
//
private extension SPSheetController {

    func attachView(to containerView: UIView) {
        containerView.addSubview(view)

        NSLayoutConstraint.activate([
            view.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            view.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            view.topAnchor.constraint(equalTo: containerView.topAnchor),
            view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }

    func dismissWithAnimation() {
        performSlideDownAnimation { _ in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
}


// MARK: - Actions
//
private extension SPSheetController {

    @IBAction func button0WasPressed() {
        dismissWithAnimation()
        onClickButton0?()
    }

    @IBAction func button1WasPressed() {
        dismissWithAnimation()
        onClickButton1?()
    }

    @IBAction func backgroundWasPressed() {
        dismissWithAnimation()
    }
}


// MARK: - Animations
//
private extension SPSheetController {

    func performSlideUpAnimation(onCompletion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: UIKitConstants.animationShortDuration, delay: .zero, usingSpringWithDamping: UIKitConstants.animationTightDampening, initialSpringVelocity: .zero, options: [], animations: {
            self.showSubviews()
        }, completion: onCompletion)
    }

    func performSlideDownAnimation(onCompletion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: UIKitConstants.animationShortDuration, delay: .zero, usingSpringWithDamping: UIKitConstants.animationTightDampening, initialSpringVelocity: .zero, options: [], animations: {
            self.hideSubviews()
        }, completion: onCompletion)
    }

    func hideSubviews() {
        backgroundView.alpha = UIKitConstants.alpha0_0
        actionsBottomConstraint.constant = actionsView.frame.height + view.safeAreaInsets.bottom
        view.layoutIfNeeded()
    }

    func showSubviews() {
        backgroundView.alpha = UIKitConstants.alpha1_0
        actionsBottomConstraint.constant = .zero
        view.layoutIfNeeded()
    }
}
