import Foundation

// MARK: - Simplenote's Upgrade handling flows
//
class MigrationsHandler: NSObject {

    /// Returns the Runtime version
    ///
    private let runtimeVersion = Bundle.main.shortVersionString

    /// Stores the last known version.
    ///
    private var lastKnownVersion: String {
        get {
            UserDefaults.standard.string(forKey: .lastKnownVersion) ?? String()
        }
        set {
            UserDefaults.standard.set(newValue, forKey: .lastKnownVersion)
        }
    }

    /// Processes any routines required to (safely) handle App Version Upgrades.
    ///
    @objc
    func ensureUpdateIsHandled() {
        guard runtimeVersion != lastKnownVersion else {
            return
        }

        processMigrations(from: lastKnownVersion, to: runtimeVersion)
        lastKnownVersion = runtimeVersion
    }
}

// MARK: - Private Methods
//
private extension MigrationsHandler {

    /// Handles a migration *from* a given version, *towards* a given version
    ///
    func processMigrations(from: String, to: String) {
        // NO-OP: Keeping this around for future proof!
    }
}
