//
//  ShareViewController.swift
//  SimplenoteShare
//
//  Created by Jorge Leandro Perez on 12/15/15.
//  Copyright © 2015 Automattic. All rights reserved.
//

import UIKit
import Social
import SAMKeychain


/// Simplenote's Share Extension.

class ShareViewController: SLComposeServiceViewController {

    /// Returns the Main App's SimperiumToken
    ///
    private var simperiumToken: String? {
        return SAMKeychain.password(forService: kShareExtensionServiceName, account: kShareExtensionAccountName)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dismissIfNeeded()
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


// MARK: - Private Methods
//
private extension ShareViewController {

    func dismissIfNeeded() {
        guard simperiumToken == nil else {
            return
        }

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
            if let theURL = url as? URL {
                completion(theURL)
            } else {
                completion(nil)
            }
        }
    }

    func submitNote(_ content: String, url: URL?) {
        let note = Note(content: contentWithSourceURL(url))
        let uploader = Uploader(simperiumToken: simperiumToken!)
        uploader.send(note)
    }
}
