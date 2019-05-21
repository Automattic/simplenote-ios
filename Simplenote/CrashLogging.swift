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
        get {
            return CrashLogging.userHasOptedOut
        }
        set {
            CrashLogging.userHasOptedOut = newValue
        }
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
        guard let analyticsEnabled = simperium.preferencesObject()?.analytics_enabled?.boolValue else {
            return true
        }

        return !analyticsEnabled
    }

    var buildType: String {
        return BuildConfiguration.current.description
    }

    var currentUser: TracksUser? {
        guard let user = self.simperium.user, let email = user.email else {
            return nil
        }

        return TracksUser(userID: email, email: email, username: email)
    }
}
