//
//  SPCredentials.swift
//  Simplenote
//
//  Created by Will Kwon on 8/9/16.
//  Copyright © 2016 Automattic. All rights reserved.
//

import UIKit

open class SPCredentials: NSObject
{
    static let configName = "config"
    static let plistType = "plist"
    
    open static func simperiumAppID() -> String {
        if let value = configDictionary().value(forKey: "SPSimperiumAppID") {
            return value as! String
        } else {
            return ""
        }
    }
    
    open static func simperiumApiKey() -> String {
        if let value = configDictionary().value(forKey: "SPSimperiumApiKey") {
            return value as! String
        } else {
            return ""
        }
    }
    
    open static func simperiumSettingsObjectKey() -> String {
        if let value = configDictionary().value(forKey: "SPSimperiumSettingsObjectKey") {
            return value as! String
        } else {
            return ""
        }
    }
    
    open static func simplenoteCrashlyticsKey() -> String {
        if let value = configDictionary().value(forKey: "SimplenoteCrashlyticsKey") {
            return value as! String
        } else {
            return ""
        }
    }
    
    open static func bitHockeyIdentifier() -> String {
        if let value = configDictionary().value(forKey: "BitHockeyIdentifier") {
            return value as! String
        } else {
            return ""
        }
    }
    
    open static func googleAnalyticsID() -> String {
        if let value = configDictionary().value(forKey: "GoogleAnalyticsID") {
            return value as! String
        } else {
            return ""
        }
    }
    
    open static func appbotKey() -> String {
        if let value = configDictionary().value(forKey: "AppbotKey") {
            return value as! String
        } else {
            return ""
        }
    }

    
    open static func iTunesAppId() -> String {
        if let value = configDictionary().value(forKey: "SimplenoteiTunesAppId") {
            return value as! String
        } else {
            return ""
        }
    }
    
    open static func iTunesReviewURL() -> String {
        if let value = configDictionary().value(forKey: "SimplenoteiTunesReviewURL") {
            return value as! String
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
