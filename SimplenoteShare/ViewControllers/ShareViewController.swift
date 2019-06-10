import UIKit
import Social
import SAMKeychain


/// Simplenote's Share Extension
///
class ShareViewController: SLComposeServiceViewController {

    /// Returns the Main App's SimperiumToken
    ///
    private var simperiumToken: String? {
        return SAMKeychain.password(forService: kShareExtensionServiceName, account: kShareExtensionAccountName)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadContent()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ensureSimperiumTokenIsValid()
    }

    override func isContentValid() -> Bool {
        return contentText.isEmpty == false
    }
    
    override func didSelectPost() {
        guard let extensionContext = extensionContext else {
            fatalError()
        }

        submitNote(with: contentText)
        extensionContext.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
}


// MARK: - Token Validation
//
private extension ShareViewController {

    func ensureSimperiumTokenIsValid() {
        guard isSimperiumTokenInvalid() else {
            return
        }

        displayMissingAccountAlert()
    }

    func isSimperiumTokenInvalid() -> Bool {
        return simperiumToken == nil
    }

    func displayMissingAccountAlert() {
        let title = NSLocalizedString("No Simplenote Account", comment: "Extension Missing Token Alert Title")
        let message = NSLocalizedString("Please log into your Simplenote account first by using the Simplenote app.", comment: "Extension Missing Token Alert Title")
        let accept = NSLocalizedString("Cancel Share", comment: "")

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: accept, style: .default) { _ in
            self.cancel()
        }

        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
}


// MARK: - Loading!
//
private extension ShareViewController {

    func loadContent() {
        guard let extensionContext = extensionContext else {
            fatalError()
        }

        let extractor = NoteExtractor(extensionContext: extensionContext)
        extractor.extractContent { content in
            self.textView.text = content
        }
    }
}


// MARK: - Uploader
//
private extension ShareViewController {

    func submitNote(with content: String) {
        guard let simperiumToken = simperiumToken else {
            fatalError()
        }

        let note = Note(content: content)
        let uploader = Uploader(simperiumToken: simperiumToken)
        uploader.send(note)
    }
}
