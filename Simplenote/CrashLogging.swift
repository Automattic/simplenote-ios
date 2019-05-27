import Foundation
import AutomatticTracks

/// This exists to bridge CrashLogging with Objective-C. Once the App Delegate is moved over to Swift,
/// this shim can be deleted.
@objc(CrashLogging)
class CrashLoggingShim: NSObject {
    @objc static func start(withSimperium simperium: Simperium) {
        let dataProvider = SNCrashLoggingDataProvider(withSimperium: simperium)
        CrashLogging.start(withDataProvider: dataProvider)
    }

    @objc static var userHasOptedOut: Bool {
        return CrashLogging.userHasOptedOut
    }

    @objc static func cacheUser(_ user: SPUser) {
        CrashLoggingCache.emailAddress = user.email
        CrashLogging.setCurrentUser(TracksUser(email: user.email))
    }

    @objc static func cacheOptOutSetting(_ didOptOut: Bool) {
        CrashLoggingCache.didOptOut = didOptOut
    }
}

class SNCrashLoggingDataProvider: CrashLoggingDataProvider {

    let simperium: Simperium

    init(withSimperium simperium: Simperium) {
        self.simperium = simperium
    }

    var sentryDSN: String {
        return SPCredentials.simplenoteSentryDSN()
    }

    var userHasOptedOut: Bool {

        if let analyticsEnabledSetting = simperium.preferencesObject()?.analytics_enabled {
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
struct CrashLoggingCache {

    struct User: Codable {
        var emailAddress: String?
        var didOptOut: Bool = true

        static var empty = User(emailAddress: nil, didOptOut: true)
    }

    static var emailAddress: String? {
        get {
            return cachedUser?.emailAddress
        }
        set {
            var updatedUser = cachedUser ?? User.empty
            updatedUser.emailAddress = newValue
            cachedUser = updatedUser
        }
    }

    static var didOptOut: Bool {
        get {
            return cachedUser?.didOptOut ?? true
        }
        set {
            var updatedUser = cachedUser ?? User.empty
            updatedUser.didOptOut = newValue
            cachedUser = updatedUser
        }
    }

    fileprivate static var cachedUser: User? {
        get {
            guard let data = UserDefaults.standard.object(forKey: key) as? Data else { return nil }
            return try? PropertyListDecoder().decode(User.self, from: data)
        }
        set {
            guard let data = try? PropertyListEncoder().encode(newValue) else { return }
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private static let key = "crash-logging-cache-key"
}
