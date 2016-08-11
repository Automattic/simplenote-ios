//
//  SPCredentials.swift
//  Simplenote
//
//  Created by Will Kwon on 8/9/16.
//  Copyright © 2016 Automattic. All rights reserved.
//

import UIKit

public class SPCredentials: NSObject
{
    static let configName = "config"
    static let plistType = "plist"
    
    public static func simperiumAppID() -> String {
        if let value = configDictionary().valueForKey("SPSimperiumAppID") {
            return value as! String
        } else {
            return ""
        }
    }
    
    public static func simperiumApiKey() -> String {
        if let value = configDictionary().valueForKey("SPSimperiumApiKey") {
            return value as! String
        } else {
            return ""
        }
    }
    
    public static func simperiumSettingsObjectKey() -> String {
        if let value = configDictionary().valueForKey("SPSimperiumSettingsObjectKey") {
            return value as! String
        } else {
            return ""
        }
    }
    
    public static func simplenoteCrashlyticsKey() -> String {
        if let value = configDictionary().valueForKey("SimplenoteCrashlyticsKey") {
            return value as! String
        } else {
            return ""
        }
    }
    
    public static func bitHockeyIdentifier() -> String {
        if let value = configDictionary().valueForKey("BitHockeyIdentifier") {
            return value as! String
        } else {
            return ""
        }
    }
    
    public static func googleAnalyticsID() -> String {
        if let value = configDictionary().valueForKey("GoogleAnalyticsID") {
            return value as! String
        } else {
            return ""
        }
    }
    
    public static func appbotKey() -> String {
        if let value = configDictionary().valueForKey("AppbotKey") {
            return value as! String
        } else {
            return ""
        }
    }

    
    public static func iTunesAppId() -> String {
        if let value = configDictionary().valueForKey("SimplenoteiTunesAppId") {
            return value as! String
        } else {
            return ""
        }
    }
    
    public static func iTunesReviewURL() -> String {
        if let value = configDictionary().valueForKey("SimplenoteiTunesReviewURL") {
            return value as! String
        } else {
            return ""
        }
    }
    
    private static func configDictionary() -> NSDictionary {
        guard let plistPath = NSBundle.mainBundle().pathForResource(configName, ofType: plistType) else {
            return NSDictionary()
        }
        
        return NSDictionary(contentsOfFile: plistPath)!
    }
}
