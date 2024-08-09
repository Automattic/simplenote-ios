import Foundation

// MARK: - SPPinLockManager
//
class SPPinLockManager: NSObject {

    @objc
    static let shared = SPPinLockManager()

    private let biometricAuthentication: BiometricAuthentication

    init(biometricAuthentication: BiometricAuthentication = BiometricAuthentication()) {
        self.biometricAuthentication = biometricAuthentication
    }

    /// Should we bypass pin lock due to timeout settings?
    ///
    var shouldBypassPinLock: Bool {
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
        return intervalSinceLastUsed < maxTimeoutSeconds
    }

    private var pinLockTimeoutSeconds: Int {
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
    func storeLastUsedTime() {
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
    var isEnabled: Bool {
        pin?.isEmpty == false
    }

    /// Set pin
    ///
    func setPin(_ pin: String) {
        self.pin = pin
    }

    /// Remove pin
    ///
    @objc
    func removePin() {
        pin = nil
        shouldUseBiometry = false
    }

    /// Check if provided pin is valid
    ///
    func validatePin(_ pin: String) -> Bool {
        isEnabled && pin == self.pin
    }

    @objc
    private var pin: String? {
        get {
            KeychainManager.pinlock
        }

        set {
            KeychainManager.pinlock = newValue
            UserDefaults.standard.set(isEnabled, forKey: .pinLockIsEnabled)
            ShortcutsHandler.shared.updateHomeScreenQuickActions(with: nil)
        }
    }

    // MARK: - Biometry

    /// Should the app try to use biometry?
    ///
    @objc
    var shouldUseBiometry: Bool {
        get {
            Options.shared.useBiometryInsteadOfPin
        }

        set {
            Options.shared.useBiometryInsteadOfPin = newValue
        }
    }

    var availableBiometry: BiometricAuthentication.Biometry? {
        biometricAuthentication.availableBiometry
    }

    func evaluateBiometry(completion: @escaping (_ success: Bool) -> Void) {
        guard shouldUseBiometry else {
            completion(false)
            return
        }

        biometricAuthentication.evaluate(completion: completion)
    }
}
