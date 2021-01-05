//
//  SPPinLockManager.swift
//  Simplenote
//
//  Helper functions for accessing the apps pin lock settings
//

import Foundation
import LocalAuthentication

class SPPinLockManager: NSObject {

    enum Biometry {
        case touchID
        case faceID
    }

    @objc
    static func shouldBypassPinLock() -> Bool {
        guard let lastUsedString = KeychainManager.timestamp else {
            return false
        }
        
        let lastUsedSeconds = Int(lastUsedString);
        if lastUsedSeconds == 0 {
            return false
        }
        
        let maxTimeoutSeconds = pinLockTimeoutSeconds
        // User has timeout set to 'Off' setting (0)
        if (maxTimeoutSeconds == 0) {
            return false
        }
        
        var ts = timespec.init()
        clock_gettime(CLOCK_MONOTONIC_RAW, &ts)
        let nowSeconds = max(0, Int(ts.tv_sec)) // The running clock time of the device
        
        // User may have recently rebooted their device, so we'll enforce lock screen
        if (lastUsedSeconds! > nowSeconds) {
            return false
        }
        
        let intervalSinceLastUsed = nowSeconds - lastUsedSeconds!
        return intervalSinceLastUsed < maxTimeoutSeconds;
    }
    
    private static var pinLockTimeoutSeconds: Int {
        let timeoutPref = UserDefaults.standard.integer(forKey: kPinTimeoutPreferencesKey)
        let timeoutValues = [0, 15, 30, 60, 120, 180, 240, 300]
        
        if timeoutPref > timeoutValues.count {
            return 0
        }
        
        return timeoutValues[timeoutPref]
    }
    
    @objc
    static func storeLastUsedTime() {
        guard isEnabled else {
            return
        }

        var ts = timespec()
        clock_gettime(CLOCK_MONOTONIC_RAW, &ts)

        let nowTime = String(format: "%ld", ts.tv_sec)
        KeychainManager.timestamp = nowTime
    }

    @objc
    static var isEnabled: Bool {
        pin?.isEmpty == false
    }

    @objc
    static var shouldUseBiometry: Bool {
        get {
            Options.shared.useBiometryInsteadOfPin
        }

        set {
            Options.shared.useBiometryInsteadOfPin = newValue
        }
    }

    static var supportedBiometry: Biometry? {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return nil
        }

        switch context.biometryType {
        case .none:
            return nil
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        @unknown default:
            return nil
        }
    }

    @objc
    static var pin: String? {
        get {
            KeychainManager.pinlock
        }

        set {
            KeychainManager.pinlock = newValue
        }
    }

    @objc
    static func removePin() {
        pin = nil
        shouldUseBiometry = false
    }
}
