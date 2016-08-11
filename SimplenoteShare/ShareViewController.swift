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

public class ShareViewController: SLComposeServiceViewController
{
    // MARK: - Private Properties
    private var simperiumToken: String? {
        return SSKeychain.passwordForService(kShareExtensionServiceName, account: kShareExtensionAccountName)
    }
    
    
    
    // MARK: - UIViewController Methods
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        dismissIfNeeded()
    }
    
    
    
    // MARK: - Private Helpers
    private func dismissIfNeeded() {
        guard simperiumToken == nil else {
            return
        }

        let title = NSLocalizedString("No Simplenote Account", comment: "Extension Missing Token Alert Title")
        let message = NSLocalizedString("Please log into your Simplenote account first by using the Simplenote app.", comment: "Extension Missing Token Alert Title")
        let accept = NSLocalizedString("Cancel Share", comment: "")
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: accept, style: .Default) { (action: UIAlertAction) -> Void in
            self.cancel()
        }
        
        alertController.addAction(alertAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func contentWithSourceURL(url: NSURL?) -> String {
        guard let url = url else {
            return contentText
        }
        
        // Append the URL to the content itself
        return contentText + "\n\n[" + url.absoluteString + "]"
    }
    
    private func loadWebsiteUrl(completion: (NSURL? -> Void)) {
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
        
        itemProvider.loadItemForTypeIdentifier("public.url", options: nil) { (url, error) -> Void in
            if let theURL = url as? NSURL {
                completion(theURL)
            } else {
                completion(nil)
            }
        }
    }
    
    private func submitNote(content: String, url: NSURL?) {
        let note = Note(content: contentWithSourceURL(url))
        let uploader = Uploader(simperiumToken: simperiumToken!)
        uploader.send(note)
    }
    
    
    
    // MARK: - ComposeService Methods
    override public func isContentValid() -> Bool {
        return contentText.isEmpty == false
    }
    
    override public func didSelectPost() {
        loadWebsiteUrl { (url: NSURL?) in
            self.submitNote(self.contentText, url: url)
            self.extensionContext!.completeRequestReturningItems([], completionHandler: nil)
        }
    }
    
    override public func configurationItems() -> [AnyObject]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
    
    
    
    /// The purpose of this class is to encapsulate NSURLSession's interaction code, required to upload
    /// a note to Simperium's REST endpoint.
    
    private class Uploader: NSObject, NSURLSessionDelegate
    {
        // MARK: - Properties
        private let token : String

        // MARK: - Constants
        private let authHeader  = "X-Simperium-Token"
        private let bucketName  = "note"
        private let httpMethod  = "POST"

        // MARK: - Initializers
        init(simperiumToken: String) {
            token = simperiumToken
        }
        
        
        
        // MARK: - Public Methods
        func send(note: Note) {
            // Build the targetURL
            let endpoint = String(format: "%@/%@/%@/i/%@", kSimperiumBaseURL, SPCredentials.simperiumAppID(), bucketName, note.simperiumKey)
            let targetURL = NSURL(string: endpoint.lowercaseString)!
            
            // Request
            let request = NSMutableURLRequest(URL: targetURL)
            request.HTTPMethod = httpMethod
            request.HTTPBody = note.toJsonData()
            request.setValue(token, forHTTPHeaderField: authHeader)

            // Task!
            let sc = NSURLSessionConfiguration.backgroundSessionConfigurationWithRandomizedIdentifier()

            let session = NSURLSession(configuration: sc, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
            let task = session.downloadTaskWithRequest(request)
            task.resume()
        }
        
        
        
        // MARK: - NSURLSessionDelegate
        @objc func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
            print("<> Uploader.didCompleteWithError: \(error)")
        }
        
        @objc func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
            print("<> Uploader.didBecomeInvalidWithError: \(error)")
        }
        
        @objc func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
            print("<> Uploader.URLSessionDidFinishEventsForBackgroundURLSession")
        }
    }
    
    
    
    /// This class encapsulates the Note entity. It's the main project (non core data) counterpart.
    
    private class Note
    {
        // MARK: - Properties
        let simperiumKey : String
        let content : String
        let modificationDate : NSDate
        
        
        
        // MARK: - Initializers
        init(content: String) {
            self.content = content
            self.simperiumKey = NSUUID().UUIDString.stringByReplacingOccurrencesOfString("-", withString: "")
            self.modificationDate = NSDate()
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
        
        func toJsonData() -> NSData? {
            do {
                return try NSJSONSerialization.dataWithJSONObject(toDictionary(), options: .PrettyPrinted)
            } catch {
                print("Error converting Note to JSON: \(error)")
                return nil
            }
        }
    }
}
