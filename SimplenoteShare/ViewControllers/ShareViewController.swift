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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ensureSimperiumTokenIsValid()
    }

    override func isContentValid() -> Bool {
        return contentText.isEmpty == false
    }
    
    override func didSelectPost() {
        loadWebsiteUrl { url in
            self.submitNote(self.contentText, url: url)
            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        }
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


// MARK: - Uploader
//
private extension ShareViewController {

    func contentWithSourceURL(_ url: URL?) -> String {
        guard let url = url else {
            return contentText
        }

        // Append the URL to the content itself
        return contentText + "\n\n[" + url.absoluteString + "]"
    }

    func loadWebsiteUrl(_ completion: @escaping ((URL?) -> Void)) {
        guard let item = extensionContext?.inputItems.first as? NSExtensionItem,
            let itemProvider = item.attachments?.first else
        {
            completion(nil)
            return
        }

        if itemProvider.hasItemConformingToTypeIdentifier("public.url") == false {
            completion(nil)
            return
        }

        itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil) { (url, error) in
            let theURL = url as? URL
            completion(theURL)
        }
    }

    func submitNote(_ content: String, url: URL?) {
        let note = Note(content: contentWithSourceURL(url))
        let uploader = Uploader(simperiumToken: simperiumToken!)
        uploader.send(note)
    }
}
