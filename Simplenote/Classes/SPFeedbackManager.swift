import Foundation
import MessageUI
import SafariServices

// MARK: - SPFeedbackManager
//
@objcMembers
class SPFeedbackManager: NSObject {

    /// Ladies and gentlemen, yet another Singleton!
    ///
    static let shared = SPFeedbackManager()

    /// Let's just hide the initializer?
    ///
    private override init() {
        // NO-OP
    }

    /// Returns a ViewController capable of dealing with User Feedback. By default: MailComposer, and as a fallback... Safari!
    ///
    func feedbackViewController() -> UIViewController {
        guard MFMailComposeViewController.canSendMail() else {
            return SFSafariViewController(url: SPCredentials.simplenoteFeedbackURL)
        }

        let subjectText = NSLocalizedString("Simplenote iOS Feedback", comment: "Simplenote's Feedback Email Title")

        let mailViewController = MFMailComposeViewController()
        mailViewController.setSubject(subjectText)
        mailViewController.setToRecipients([SPCredentials.simplenoteFeedbackMail])
        mailViewController.mailComposeDelegate = self

        return mailViewController
    }
}

// MARK: - MFMailComposeViewControllerDelegate
//
extension SPFeedbackManager: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
         controller.dismiss(animated: true, completion: nil)
    }
}
