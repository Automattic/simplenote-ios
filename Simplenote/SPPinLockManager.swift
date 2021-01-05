import Foundation
import LocalAuthentication

// MARK: - SPPinLockManager
//
class SPPinLockManager: NSObject {

    /// Biometry
    ///
    enum Biometry {
        case touchID
        case faceID
    }

    /// Should we bypass pin lock due to timeout settings?
    ///
    @objc
    static func shouldBypassPinLock() -> Bool {
        guard let lastUsedSeconds = Int(KeychainManager.timestamp ?? "0"),
              lastUsedSeconds > 0 else {
            return false
        }

        let maxTimeoutSeconds = pinLockTimeoutSeconds
        // User has timeout set to 'Off' setting (0)
        if maxTimeoutSeconds == 0 {
            return false
        }
        
        var ts = timespec.init()
        clock_gettime(CLOCK_MONOTONIC_RAW, &ts)
        let nowSeconds = max(0, Int(ts.tv_sec)) // The running clock time of the device
        
        // User may have recently rebooted their device, so we'll enforce lock screen
        if lastUsedSeconds > nowSeconds {
            return false
        }
        
        let intervalSinceLastUsed = nowSeconds - lastUsedSeconds
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

    /// Store last time the app was used
    ///
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

    /// Is pin enabled
    ///
    @objc
    static var isEnabled: Bool {
        pin?.isEmpty == false
    }

    /// Set pin
    ///
    static func setPin(_ pin: String) {
        self.pin = pin
    }

    /// Remove pin
    ///
    @objc
    static func removePin() {
        pin = nil
        shouldUseBiometry = false
    }

    /// Check if provided pin is valid
    ///
    static func validatePin(_ pin: String) -> Bool {
        isEnabled && pin == self.pin
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
}

// MARK: - Biometry
//
extension SPPinLockManager {
    /// Should the app try to use biometry?
    ///
    @objc
    static var shouldUseBiometry: Bool {
        get {
            Options.shared.useBiometryInsteadOfPin
        }

        set {
            Options.shared.useBiometryInsteadOfPin = newValue
        }
    }

    /// Supported biometry option or nil if there is no support
    ///
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
}
