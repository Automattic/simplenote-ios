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

    /// Indicates if the Markdown flag should be enabled
    ///
    private var isMarkdown = false


    // MARK: - UIViewController Lifecycle

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

        let note = Note(content: contentText, markdown: isMarkdown)
        submit(note: note)

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

    /// Attempts to extract the Note's Payload from the current ExtensionContext
    ///
    func loadContent() {
        guard let extensionContext = extensionContext else {
            fatalError()
        }

        extensionContext.extractNote(from: extensionContext) { note in
            guard let note = note else {
                return
            }

            self.display(note: note)
        }
    }

    /// Displays a given Note's payload onScreen
    ///
    func display(note: Note) {
        isMarkdown = note.markdown
        textView.text = note.content

        validateContent()
    }

    /// Submits a given Note to the user's Simplenote account
    ///
    func submit(note: Note) {
        guard let simperiumToken = simperiumToken else {
            fatalError()
        }

        let uploader = Uploader(simperiumToken: simperiumToken)
        uploader.send(note)
    }
}
