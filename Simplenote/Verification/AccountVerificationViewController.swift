import UIKit

// MARK: - AccountVerificationViewController
//
class AccountVerificationViewController: UIViewController {

    /// Configuration
    ///
    struct Configuration: Equatable {
        static let review = Configuration(iconName: .warning,
                                          title: Localization.Review.title,
                                          messageTemplate: Localization.Review.messageTemplate,
                                          primaryButton: Localization.Review.confirm,
                                          secondaryButton: Localization.Review.changeEmail,
                                          errorMessageTitle: Localization.Review.errorMessageTitle)

        static let verify = Configuration(iconName: .mail,
                                          title: Localization.Verify.title,
                                          messageTemplate: Localization.Verify.messageTemplate,
                                          primaryButton: nil,
                                          secondaryButton: Localization.Verify.resendEmail,
                                          errorMessageTitle: Localization.Verify.errorMessageTitle)
        let iconName: UIImageName

        let title: String
        let messageTemplate: String

        let primaryButton: String?
        let secondaryButton: String

        let errorMessageTitle: String

        private init(iconName: UIImageName,
                     title: String,
                     messageTemplate: String,
                     primaryButton: String?,
                     secondaryButton: String,
                     errorMessageTitle: String) {
            self.iconName = iconName
            self.title = title
            self.messageTemplate = messageTemplate
            self.primaryButton = primaryButton
            self.secondaryButton = secondaryButton
            self.errorMessageTitle = errorMessageTitle
        }
    }

    @IBOutlet private weak var iconView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var primaryButton: ActivityIndicatorButton!
    @IBOutlet private weak var secondaryButton: ActivityIndicatorButton!

    @IBOutlet private weak var dismissButton: UIButton!

    @IBOutlet private weak var contentStackView: UIStackView!
    @IBOutlet private weak var scrollView: UIScrollView!

    private var configuration: Configuration {
        didSet {
            refreshStyle()
            refreshContent()
            trackScreen()
        }
    }

    private let controller: AccountVerificationController

    init(configuration: Configuration, controller: AccountVerificationController) {
        self.configuration = configuration
        self.controller = controller

        super.init(nibName: nil, bundle: nil)
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshStyle()
        refreshContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trackScreen()
    }
}

// MARK: - Private
//
private extension AccountVerificationViewController {
    func verifyEmail(onSuccess: (() -> Void)? = nil) {
        let button = primaryButton.isHidden ? secondaryButton : primaryButton
        button?.inProgress = true
        updateButtons(isEnabled: false)

        controller.verify { [weak self] (result) in
            switch result {
            case .success:
                onSuccess?()
            case .failure:
                self?.showErrorMessage()
            }

            button?.inProgress = false
            self?.updateButtons(isEnabled: true)
        }
    }

    func showErrorMessage() {
        let alertController = UIAlertController(title: configuration.errorMessageTitle,
                                                message: Localization.errorMessage,
                                                preferredStyle: .alert)

        alertController.addDefaultActionWithTitle(Localization.okButton)

        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Buttons
//
extension AccountVerificationViewController {
    @IBAction private func handleTapOnDismissButton() {
        dismiss()
        SPTracker.trackVerificationDismissed()
    }

    @IBAction private func handleTapOnPrimaryButton() {
        guard configuration == .review else {
            return
        }

        verifyEmail(onSuccess: { [weak self] in
            self?.transitionToVerificationScreen()
        })
        SPTracker.trackVerificationConfirmButtonTapped()
    }

    @IBAction private func handleTapOnSecondaryButton() {
        switch configuration {
        case .review:
            if let url = URL(string: SimplenoteConstants.settingsURL) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                dismiss()
            }
            SPTracker.trackVerificationChangeEmailButtonTapped()

        case .verify:
            verifyEmail()
            SPTracker.trackVerificationResendEmailButtonTapped()

        default:
            return
        }
    }

    private func updateButtons(isEnabled: Bool) {
        [primaryButton, secondaryButton].forEach {
            $0?.isEnabled = isEnabled
        }
    }
}

// MARK: - Transitions
//
private extension AccountVerificationViewController {
    func transitionToVerificationScreen() {
        contentStackView.reload(with: .slideLeading, in: view) {
            self.configuration = .verify

            self.primaryButton.inProgress = false
            self.secondaryButton.inProgress = false
            self.updateButtons(isEnabled: true)
        }
    }

    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Style
//
private extension AccountVerificationViewController {
    func refreshStyle() {
        view.backgroundColor = .simplenoteVerificationScreenBackgroundColor
        iconView.tintColor = .simplenoteTitleColor

        titleLabel.textColor = .simplenoteTextColor
        titleLabel.font = UIFont.preferredFont(for: .largeTitle, weight: .bold)
        textLabel.textColor = .simplenoteTextColor

        primaryButton.backgroundColor = .simplenoteBlue50Color
        primaryButton.setTitleColor(.white, for: .normal)
        primaryButton.activityIndicatorColor = .white
        primaryButton.layer.cornerRadius = Constants.primaryButtonCornerRadius
        primaryButton.titleLabel?.adjustsFontForContentSizeCategory = true

        secondaryButton.backgroundColor = .clear
        secondaryButton.setTitleColor(.simplenoteTintColor, for: .normal)
        secondaryButton.titleLabel?.adjustsFontForContentSizeCategory = true

        scrollView.contentInset = Constants.scrollContentInset
    }
}

// MARK: - Content
//
private extension AccountVerificationViewController {
    func refreshContent() {
        let message = String(format: configuration.messageTemplate, controller.email)

        iconView.image = UIImage.image(name: configuration.iconName)
        titleLabel.text = configuration.title
        textLabel.attributedText = attributedText(message, highlighting: controller.email)
        primaryButton.setTitle(configuration.primaryButton, for: .normal)
        secondaryButton.setTitle(configuration.secondaryButton, for: .normal)

        primaryButton.isHidden = configuration.primaryButton == nil
    }

    func attributedText(_ text: String, highlighting term: String) -> NSAttributedString {
        let attributedMessage = NSMutableAttributedString(string: text, attributes: [
            .foregroundColor: UIColor.simplenoteTextColor,
            .font: UIFont.preferredFont(forTextStyle: .body)
        ])

        if let range = text.range(of: term) {
            attributedMessage.addAttribute(.font,
                                           value: UIFont.preferredFont(forTextStyle: .headline),
                                           range: NSRange(range, in: text))
        }

        return attributedMessage
    }
}

// MARK: - Tracks
//
private extension AccountVerificationViewController {
    func trackScreen() {
        switch configuration {
        case .review:
            SPTracker.trackVerificationReviewScreenViewed()
        case .verify:
            SPTracker.trackVerificationVerifyScreenViewed()
        default:
            break
        }
    }
}

// MARK: - Orientation
//
extension AccountVerificationViewController {
    override public var shouldAutorotate: Bool {
        if UIDevice.isPad {
            return super.shouldAutorotate
        }
        return false
    }

    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.isPad {
            return super.supportedInterfaceOrientations
        }
        return [.portrait, .portraitUpsideDown]
    }

    override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if UIDevice.isPad {
            return super.preferredInterfaceOrientationForPresentation
        }
        return .portrait
    }
}

// MARK: - Constants
//
private struct Constants {
    static let scrollContentInset = UIEdgeInsets(top: 72, left: 0, bottom: 20, right: 0)
    static let primaryButtonCornerRadius: CGFloat = 8
}

// MARK: - Localization
//
private struct Localization {
    static let errorMessage = NSLocalizedString("Please check your network settings and try again.", comment: "Error message. Account verification")
    static let okButton = NSLocalizedString("OK", comment: "Dismisses an AlertController")

    struct Review {
        static let title = NSLocalizedString("Review Your Account", comment: "Title -> Review you account screen")
        static let messageTemplate = NSLocalizedString("You are registered with Simplenote using the email %1$@.\n\nImprovements to account security may result in account loss if you no longer have access to this email address.", comment: "Message -> Review you account screen. Parameter: %1$@ - email address")

        static let confirm = NSLocalizedString("Confirm", comment: "Confirm button -> Review you account screen")
        static let changeEmail = NSLocalizedString("Change Email", comment: "Change email button -> Review you account screen")

        static let errorMessageTitle = NSLocalizedString("Cannot Confirm Account", comment: "Error message title. Review you account screen")
    }

    struct Verify {
        static let title = NSLocalizedString("Verify Your Email", comment: "Title -> Verify your email screen")
        static let messageTemplate = NSLocalizedString("We’ve sent a verification email to %1$@. Please check your inbox and follow the instructions.", comment: "Message -> Verify your email screen. Parameter: %1$@ - email address")

        static let resendEmail = NSLocalizedString("Resend Email", comment: "Resend email button -> Verify your email screen")

        static let errorMessageTitle = NSLocalizedString("Cannot Send Verification Email", comment: "Error message title. Verify your email screen")
    }
}
