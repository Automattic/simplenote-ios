//
//  SPPinLockManager.swift
//  Simplenote
//
//  Helper functions for accessing the apps pin lock settings
//

import Foundation

class SPPinLockManager: NSObject {
    @objc static func shouldBypassPinLock() -> Bool {
        let lastUsedString = SPKeychain.password(forService: kSimplenotePasscodeServiceName, account: kShareExtensionAccountName)
        if (lastUsedString == nil) {
            return false
        }
        
        let lastUsedSeconds = Int(lastUsedString!);
        if (lastUsedSeconds == 0) {
            return false
        }
        
        var ts = timespec.init()
        clock_gettime(CLOCK_MONOTONIC_RAW, &ts)
        let nowSeconds = ts.tv_sec
        let intervalSinceLastUsed = Int(nowSeconds) - lastUsedSeconds!
        let maxTimeoutSeconds = getPinLockTimeoutSeconds()
        
        return intervalSinceLastUsed < maxTimeoutSeconds;
    }
    
    static func getPinLockTimeoutSeconds() -> Int {
        let timeoutPref = UserDefaults.standard.integer(forKey: kPinTimeoutPreferencesKey)
        let timeoutValues = [0, 15, 30, 60, 120, 180, 240, 300]
        
        if (timeoutPref > timeoutValues.count) {
            return 0
        }
        
        return timeoutValues[timeoutPref]
    }
    
    @objc static func storeLastUsedTime() {
        var ts = timespec.init()
        clock_gettime(CLOCK_MONOTONIC_RAW, &ts)
        let nowTime = String.init(format: "%ld", ts.tv_sec)
        SPKeychain.setPassword(nowTime, forService: kSimplenotePasscodeServiceName, account: kShareExtensionAccountName)
    }
}
