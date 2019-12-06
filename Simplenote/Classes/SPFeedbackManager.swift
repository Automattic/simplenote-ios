import Foundation
import MessageUI
import SafariServices


// MARK: - SPFeedbackManager
//
class SPFeedbackManager: NSObject {

    /// Returns a ViewController capable of dealing with User Feedback. By default: MailComposer, and as a fallback... Safari!
    ///
    @objc
    static func feedbackViewController() -> UIViewController {
        guard MFMailComposeViewController.canSendMail() else {
            return SFSafariViewController(url: SPCredentials.simplenoteFeedbackURL)
        }

        let subjectText = NSLocalizedString("Simplenote iOS Feedback", comment: "Simplenote's Feedback Email")

        let mailViewController = MFMailComposeViewController()
        mailViewController.setSubject(subjectText)
        mailViewController.setToRecipients([SPCredentials.simplenoteFeedbackMail])

        return mailViewController
    }
}
