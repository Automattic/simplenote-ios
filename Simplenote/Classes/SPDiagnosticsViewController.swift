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
    }

    func setupNavigationItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                            target: self,
                                                            action: #selector(dismissWasPressed))
    }
}


// MARK: - Actions
//
private extension SPDiagnosticsViewController {

    @IBAction
    func dismissWasPressed() {
        dismiss(animated: true, completion: nil)
    }
}
