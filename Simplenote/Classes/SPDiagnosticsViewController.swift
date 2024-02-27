import Foundation
import UIKit

// MARK: - SPDiagnosticsViewController
//
class SPDiagnosticsViewController: UIViewController {

    /// Label: Title
    ///
    @IBOutlet private var titleLabel: UILabel!

    /// TextView: Details
    ///
    @IBOutlet private var detailsTextView: UITextView!

    /// Text to be presented
    ///
    var attributedText: NSAttributedString?

    // MARK: - Overridden Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitleLabel()
        setupTextView()
        setupNavigationItem()
    }
}

// MARK: - Interface
//
private extension SPDiagnosticsViewController {

    func setupTitleLabel() {
        titleLabel.text = NSLocalizedString("Diagnostics", comment: "Title displayed in the extended diagnostics UI")
    }

    func setupTextView() {
        assert(attributedText != nil, "Missing Diagnostics Text")
        detailsTextView.attributedText = attributedText
        detailsTextView.backgroundColor = .white
    }

    func setupNavigationItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Share", comment: "Share Action"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(shareWasPressed))

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                            target: self,
                                                            action: #selector(dismissWasPressed))
    }
}

// MARK: - Actions
//
private extension SPDiagnosticsViewController {

    @IBAction
    func shareWasPressed() {
        guard let attributedText = attributedText else {
            fatalError()
        }

        let items = [attributedText.string]
        let excludedActivities: [UIActivity.ActivityType] = [.print, .message, .postToFacebook, .postToTwitter, .assignToContact, .airDrop]

        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.excludedActivityTypes = excludedActivities

        present(activityViewController, animated: true)

    }

    @IBAction
    func dismissWasPressed() {
        dismiss(animated: true, completion: nil)
    }
}
