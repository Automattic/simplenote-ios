//
//  ShareViewController.swift
//  SimplenoteShare
//
//  Created by Jorge Leandro Perez on 12/15/15.
//  Copyright © 2015 Automattic. All rights reserved.
//

import UIKit
import Social
import SSKeychain


/// Simplenote's Share Extension.

open class ShareViewController: SLComposeServiceViewController
{
    // MARK: - Private Properties
    fileprivate var simperiumToken: String? {
        return SSKeychain.password(forService: kShareExtensionServiceName, account: kShareExtensionAccountName)
    }
    
    
    
    // MARK: - UIViewController Methods
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dismissIfNeeded()
    }
    
    
    
    // MARK: - Private Helpers
    fileprivate func dismissIfNeeded() {
        guard simperiumToken == nil else {
            return
        }

        let title = NSLocalizedString("No Simplenote Account", comment: "Extension Missing Token Alert Title")
        let message = NSLocalizedString("Please log into your Simplenote account first by using the Simplenote app.", comment: "Extension Missing Token Alert Title")
        let accept = NSLocalizedString("Cancel Share", comment: "")
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: accept, style: .default) { (action: UIAlertAction) -> Void in
            self.cancel()
        }
        
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func contentWithSourceURL(_ url: URL?) -> String {
        guard let url = url else {
            return contentText
        }
        
        // Append the URL to the content itself
        return contentText + "\n\n[" + url.absoluteString + "]"
    }
    
    fileprivate func loadWebsiteUrl(_ completion: @escaping ((URL?) -> Void)) {
        guard let item = extensionContext?.inputItems.first as? NSExtensionItem,
            let itemProvider = item.attachments?.first as? NSItemProvider else
        {
            completion(nil)
            return
        }
        
        if itemProvider.hasItemConformingToTypeIdentifier("public.url") == false {
            completion(nil)
            return
        }
        
        itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil) { (url, error) -> Void in
            if let theURL = url as? URL {
                completion(theURL)
            } else {
                completion(nil)
            }
        }
    }
    
    fileprivate func submitNote(_ content: String, url: URL?) {
        let note = Note(content: contentWithSourceURL(url))
        let uploader = Uploader(simperiumToken: simperiumToken!)
        uploader.send(note)
    }
    
    
    
    // MARK: - ComposeService Methods
    override open func isContentValid() -> Bool {
        return contentText.isEmpty == false
    }
    
    override open func didSelectPost() {
        loadWebsiteUrl { (url: URL?) in
            self.submitNote(self.contentText, url: url)
            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        }
    }
    
    override open func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
    
    
    
    /// The purpose of this class is to encapsulate NSURLSession's interaction code, required to upload
    /// a note to Simperium's REST endpoint.
    
    fileprivate class Uploader: NSObject, URLSessionDelegate
    {
        // MARK: - Properties
        fileprivate let token : String

        // MARK: - Constants
        fileprivate let authHeader  = "X-Simperium-Token"
        fileprivate let bucketName  = "note"
        fileprivate let httpMethod  = "POST"

        // MARK: - Initializers
        init(simperiumToken: String) {
            token = simperiumToken
        }
        
        
        
        // MARK: - Public Methods
        func send(_ note: Note) {
            // Build the targetURL
            let endpoint = String(format: "%@/%@/%@/i/%@", kSimperiumBaseURL, SPCredentials.simperiumAppID(), bucketName, note.simperiumKey)
            let targetURL = URL(string: endpoint.lowercased())!
            
            // Request
            var request = URLRequest(url: targetURL)
            request.httpMethod = httpMethod
            request.httpBody = note.toJsonData()
            request.setValue(token, forHTTPHeaderField: authHeader)

            // Task!
            let sc = URLSessionConfiguration.backgroundSessionConfigurationWithRandomizedIdentifier()

            let session = Foundation.URLSession(configuration: sc, delegate: self, delegateQueue: OperationQueue.main)
            let task = session.downloadTask(with: request)
            task.resume()
        }
        
        
        
        // MARK: - NSURLSessionDelegate
        @objc func URLSession(_ session: Foundation.URLSession, task: URLSessionTask, didCompleteWithError error: NSError?) {
            print("<> Uploader.didCompleteWithError: \(String(describing: error))")
        }
        
        @objc func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
            print("<> Uploader.didBecomeInvalidWithError: \(String(describing: error))")
        }
        
        @objc func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
            print("<> Uploader.URLSessionDidFinishEventsForBackgroundURLSession")
        }
    }
    
    
    
    /// This class encapsulates the Note entity. It's the main project (non core data) counterpart.
    
    fileprivate class Note
    {
        // MARK: - Properties
        let simperiumKey : String
        let content : String
        let modificationDate : Date
        
        
        
        // MARK: - Initializers
        init(content: String) {
            self.content = content
            self.simperiumKey = UUID().uuidString.replacingOccurrences(of: "-", with: "")
            self.modificationDate = Date()
        }
        
        
        
        // MARK: - Public Methods
        func toDictionary() -> NSDictionary {
            return [
                "tags"              : [],
                "deleted"           : 0,
                "shareURL"          : String(),
                "publishURL"        : String(),
                "content"           : content,
                "systemTags"        : [],
                "modificationDate"  : modificationDate.timeIntervalSince1970,
                "creationDate"      : modificationDate.timeIntervalSince1970
            ]
        }
        
        func toJsonData() -> Data? {
            do {
                return try JSONSerialization.data(withJSONObject: toDictionary(), options: .prettyPrinted)
            } catch {
                print("Error converting Note to JSON: \(error)")
                return nil
            }
        }
    }
}
