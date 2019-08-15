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

    /// View containing the Buttons
    ///
    @IBOutlet private var stackView: UIStackView!

    /// Constraint attaching the Actions View to the bottom of its container
    ///
    @IBOutlet private var actionsBottomConstraint: NSLayoutConstraint!



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

    func insertButton(_ button: UIControl) {
        setupButton(button)
        loadViewIfNeeded()
        stackView.addArrangedSubview(button)
    }
}


// MARK: - Private Methods
//
private extension SPSheetController {

    func setupButton(_ button: UIControl) {
        button.heightAnchor.constraint(equalToConstant: SPSheetConstants.buttonHeight).isActive = true
        button.layer.cornerRadius = SPSheetConstants.buttonCornerRadius
        button.addTarget(self, action: #selector(buttonWasPressed), for: .touchUpInside)
    }

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

    @IBAction func buttonWasPressed() {
        dismissWithAnimation()
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
        var safeAreaInsets = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            safeAreaInsets = view.safeAreaInsets
        }

        backgroundView.alpha = UIKitConstants.alphaZero
        actionsBottomConstraint.constant = actionsView.frame.height + safeAreaInsets.bottom
        view.layoutIfNeeded()
    }

    func showSubviews() {
        backgroundView.alpha = UIKitConstants.alphaFull
        actionsBottomConstraint.constant = .zero
        view.layoutIfNeeded()
    }
}


// MARK: - Constants
//
private enum SPSheetConstants {
    static let buttonHeight = CGFloat(44)
    static let buttonCornerRadius = CGFloat(4)
}
