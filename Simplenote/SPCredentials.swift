//
//  SPCredentials.swift
//  Simplenote
//
//  Created by Will Kwon on 8/9/16.
//  Copyright © 2016 Automattic. All rights reserved.
//

import UIKit

class SPCredentials: NSObject {

    static let configName = "config"
    static let plistType = "plist"
    
    @objc static func simperiumAppID() -> String {
        if let value = configDictionary().value(forKey: "SPSimperiumAppID") {
            return value as! String
        } else {
            return ""
        }
    }
    
    @objc static func simperiumApiKey() -> String {
        if let value = configDictionary().value(forKey: "SPSimperiumApiKey") {
            return value as! String
        } else {
            return ""
        }
    }
    
    @objc static func simperiumSettingsObjectKey() -> String {
        if let value = configDictionary().value(forKey: "SPSimperiumSettingsObjectKey") {
            return value as! String
        } else {
            return ""
        }
    }

    @objc static func simperiumPreferencesObjectKey() -> String {
        let output = configDictionary().value(forKey: "SPSimperiumPreferencesObjectKey") as? String
        return output ?? String()
    }
    
    @objc static func simplenoteSentryDSN() -> String {
        if let value = configDictionary().value(forKey: "simplenoteSentryDSN") {
            return value as! String
        } else {
            return ""
        }
    }
    
    @objc static func bitHockeyIdentifier() -> String {
        if let value = configDictionary().value(forKey: "BitHockeyIdentifier") {
            return value as! String
        } else {
            return ""
        }
    }
    
    @objc static func googleAnalyticsID() -> String {
        if let value = configDictionary().value(forKey: "GoogleAnalyticsID") {
            return value as! String
        } else {
            return ""
        }
    }
    
    @objc static func appbotKey() -> String {
        if let value = configDictionary().value(forKey: "AppbotKey") {
            return value as! String
        } else {
            return ""
        }
    }

    
    @objc static func iTunesAppId() -> String {
        if let value = configDictionary().value(forKey: "SimplenoteiTunesAppId") {
            return value as! String
        } else {
            return ""
        }
    }
    
    @objc static func iTunesReviewURL() -> URL? {
        guard let value = configDictionary().value(forKey: "SimplenoteiTunesReviewURL") as? String,
            let targetURL = URL(string: value)
        else {
            return nil
        }

        return targetURL
    }
    
    @objc static func WPCCClientID() -> String? {
        if let value = configDictionary().value(forKey: "WPCCClientID") {
            return (value as! String)
        } else {
            return ""
        }
    }
    
    @objc static func WPCCClientSecret() -> String? {
        if let value = configDictionary().value(forKey: "WPCCClientSecret") {
            return (value as! String)
        } else {
            return ""
        }
    }
    
    @objc static func WPCCRedirectURL() -> String? {
        if let value = configDictionary().value(forKey: "WPCCRedirectURL") {
            return (value as! String)
        } else {
            return ""
        }
    }

    fileprivate static func configDictionary() -> NSDictionary {
        guard let plistPath = Bundle.main.path(forResource: configName, ofType: plistType) else {
            return NSDictionary()
        }
        
        return NSDictionary(contentsOfFile: plistPath)!
    }
}
