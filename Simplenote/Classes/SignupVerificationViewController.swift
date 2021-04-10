import UIKit

// MARK: SignupVerificationViewController
//
class SignupVerificationViewController: UIViewController {

    @IBOutlet private weak var iconView: UIImageView! {
        didSet {
            iconView.tintColor = .simplenoteTitleColor
        }
    }

    @IBOutlet private weak var textLabel: UILabel! {
        didSet {
            let text = Localization.message(with: email)
            textLabel.attributedText = NSMutableAttributedString(string: text,
                                                                 attributes: [
                                                                    .foregroundColor: UIColor.simplenoteTextColor,
                                                                    .font: UIFont.preferredFont(forTextStyle: .body)
                                                                 ],
                                                                 highlighting: email,
                                                                 highlightAttributes: [
                                                                    .font: UIFont.preferredFont(forTextStyle: .headline)
                                                                 ])
        }
    }

    @IBOutlet private weak var footerTextView: UITextView! {
        didSet {
            let email = SPCredentials.simplenoteFeedbackMail
            guard let emailURL = URL(string: "mailto:\(SPCredentials.simplenoteFeedbackMail)") else {
                footerTextView.text = ""
                return
            }

            footerTextView.textContainerInset = .zero
            footerTextView.linkTextAttributes = [.foregroundColor: UIColor.simplenoteSecondaryTextColor]

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let text = Localization.footer(with: email)
            footerTextView.attributedText = NSMutableAttributedString(string: text,
                                                           attributes: [
                                                            .foregroundColor: UIColor.simplenoteSecondaryTextColor,
                                                            .font: UIFont.preferredFont(forTextStyle: .subheadline),
                                                            .paragraphStyle: paragraphStyle
                                                           ],
                                                           highlighting: email,
                                                           highlightAttributes: [
                                                            .underlineStyle: NSUnderlineStyle.single.rawValue,
                                                            .link: emailURL
                                                           ])
        }
    }

    private let email: String

    init(email: String) {
        self.email = email
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - Localization
//
private struct Localization {
    private static let messageTemplate = NSLocalizedString("We’ve sent an email to %1$@. Please check your inbox and follow the instructions.", comment: "Message -> Sign up verification screen. Parameter: %1$@ - email address")

    static func message(with email: String) -> String {
        String(format: messageTemplate, email)
    }

    private static let footerTemplate = NSLocalizedString("Didn't get an email? There may already be an account associated with this email address. Contact %1$@ for help.", comment: "Footer -> Sign up verification screen. Parameter: %1$@ - support email address")

    static func footer(with email: String) -> String {
        String(format: footerTemplate, email)
    }
}
