import Foundation

@objc(CrashLogging)
class CrashLoggingShim: NSObject {
    @objc static func start(withSimperium simperium: Simperium) {
        let dataProvider = CrashLoggingDataProvider(withSimperium: simperium)
        WPCrashLogging.start(withDataProvider: dataProvider)
    }

    @objc static var userHasOptedOut: Bool {
        get {
            return WPCrashLogging.userHasOptedOut
        }
        set {
            WPCrashLogging.userHasOptedOut = newValue
        }
    }
}

class CrashLoggingDataProvider: WPCrashLoggingDataProvider {

    let simperium: Simperium

    init(withSimperium simperium: Simperium) {
        self.simperium = simperium
    }

    var sentryDSN: String {
        return "https://f1f0b9c022994f7a9b2ca1c96fce1227@sentry.io/1455556"
    }

    var userHasOptedOut: Bool {
        return simperium.preferencesObject()?.analytics_enabled?.boolValue ?? true
    }

    var buildType: String {

        #if APPSTORE_DISTRIBUTION
            return  "app-store"
        #endif

        #if INTERNAL_DISTRIBUTION
            return "internal"
        #endif

        #if RELEASE
            return "public"
        #endif

        return "unknown"
    }

    var currentUser: WPCrashLoggingUser? {
        guard let user = self.simperium.user, let email = user.email else {
            return nil
        }

        return WPCrashLoggingUser(userID: email, email: email, username: email)
    }
}
