import Foundation
import AutomatticTracks


/// This exists to bridge CrashLogging with Objective-C. Once the App Delegate is moved over to Swift,
/// this shim can be removed, and the cache methods moved to a `CrashLogging` extension. At that time,
/// you, future developer, can just set up the Crash Logging system in the App Delegate using `SNCrashLoggingDataProvider`.
@objc(CrashLogging)
class CrashLoggingShim: NSObject {

    @objc
    static let shared = CrashLoggingShim()

    private var crashLogging: CrashLogging?

    @objc
    func start(withSimperium simperium: Simperium) {
        crashLogging = {
            let dataProvider = SNCrashLoggingDataProvider(withSimperium: simperium)
            let logger = CrashLogging(dataProvider: dataProvider)
            return try? logger.start()
        }()
    }

    @objc
    func cacheUser(_ user: SPUser) {
        CrashLoggingCache.emailAddress = user.email
        crashLogging?.setNeedsDataRefresh()
    }

    func crash() {
        crashLogging?.crash()
    }

    func logError(_ error: Error) {
        crashLogging?.logError(error)
    }

    @objc static func cacheOptOutSetting(_ didOptOut: Bool) {
        CrashLoggingCache.didOptOut = didOptOut
    }
}

private class SNCrashLoggingDataProvider: CrashLoggingDataProvider {

    private let simperium: Simperium

    init(withSimperium simperium: Simperium) {
        self.simperium = simperium
    }

    var sentryDSN: String {
        return SPCredentials.sentryDSN
    }

    var userHasOptedOut: Bool {

        if let analyticsEnabledSetting = simperium.preferencesObject().analytics_enabled {
            return !analyticsEnabledSetting.boolValue
        }

        return CrashLoggingCache.didOptOut
    }

    var buildType: String {
        return BuildConfiguration.current.description
    }

    var currentUser: TracksUser? {

        /// Prefer data from the up-to-date simperium user
        if let user = self.simperium.user, let email = user.email {
            return TracksUser(userID: email, email: email, username: email)
        }

        /// If that's not available, fall back to the cache instead
        if let user = CrashLoggingCache.cachedUser, let email = user.emailAddress {
            return TracksUser(userID: email, email: email, username: email)
        }

        return nil
    }
}

/*
 Provide a cache for user settings.

 Simperium works completely asynchronously, but we need to have the ability to recall user data at launch
 to send crash reports that are attributed to specific users. The flow for this looks something like this:

 - First Run : No user data – this cache doesn't help us
 - Post-login: User data is set and cached
 - User changes analytics opt-in settings: Updated user data is cached
 - App Crashes
 - First Run after Crash: User data is retrieved from the crash and used to identify the user (and their opt-in settings)

 SNCrashLoggingDataProvider will use this cache in `currentUser` to fetch data on the user.
 */
private struct CrashLoggingCache {

    struct User: Codable {
        var emailAddress: String?
        var didOptOut: Bool = true
    }

    static var emailAddress: String? {
        get {
            return cachedUser?.emailAddress
        }
        set {
            var updatedUser = cachedUser ?? User()
            updatedUser.emailAddress = newValue
            cachedUser = updatedUser
        }
    }

    static var didOptOut: Bool {
        get {
            return cachedUser?.didOptOut ?? true
        }
        set {
            var updatedUser = cachedUser ?? User()
            updatedUser.didOptOut = newValue
            cachedUser = updatedUser
        }
    }

    private(set)
    static var cachedUser: User? {
        get {
            guard let data = UserDefaults.standard.object(forKey: key) as? Data else {
                return nil
            }

            return try? PropertyListDecoder().decode(User.self, from: data)
        }
        set {
            guard let data = try? PropertyListEncoder().encode(newValue) else {
                return
            }

            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private static let key = "crash-logging-cache-key"
}
