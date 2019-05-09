import Foundation
import Sentry

fileprivate let UserOptedOutKey = "crashlytics_opt_out"

protocol WPCrashLoggingDataProvider {
    var sentryDSN: String { get }
    var userHasOptedOut: Bool { get }
    var buildType: String { get }
    var releaseName: String { get }
    var currentUser: WPCrashLoggingUser? { get }
    var additionalUserData: [String : Any] { get }
}

/// Default implementations of common protocol properties
extension WPCrashLoggingDataProvider {

    var releaseName: String {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    }

    var additionalUserData: [String : Any] {
        return [ : ]
    }
}

struct WPCrashLoggingUser {
    let userID: String?
    let email: String?
    let username: String?
    let isLoggedIn: Bool = false
}

class WPCrashLogging: NSObject {

    fileprivate static let sharedInstance = WPCrashLogging()

    fileprivate var dataProvider: WPCrashLoggingDataProvider! {
        didSet{
            applyUserTrackingPreferences()
        }
    }

    static func start(withDataProvider dataProvider: WPCrashLoggingDataProvider) {
        // Create a Sentry client and start crash handler
        do {
            Client.shared = try Client(dsn: dataProvider.sentryDSN)

            // Store lots of breadcrumbs to trace errors
            Client.shared?.breadcrumbs.maxBreadcrumbs = 500

            // Automatically track screen transitions
            Client.shared?.enableAutomaticBreadcrumbTracking()

            // Automatically track low-memory events
            Client.shared?.trackMemoryPressureAsEvent()

            try Client.shared?.startCrashHandler()

            // Override event serialization to append the logs, if needed
            Client.shared?.beforeSerializeEvent = sharedInstance.beforeSerializeEvent
            Client.shared?.shouldSendEvent = sharedInstance.shouldSendEvent

            // Apply Sentry Tags
            Client.shared?.releaseName = dataProvider.releaseName
            Client.shared?.environment = dataProvider.buildType

            // Store the data provider for future use
            sharedInstance.dataProvider = dataProvider

        } catch let error {
            print("\(error)")
        }
    }

    func beforeSerializeEvent(_ event: Event) {
        event.tags?["locale"] = NSLocale.current.languageCode
    }

    func shouldSendEvent(_ event: Event?) -> Bool {
        #if DEBUG
        return false
        #else
        return !WPCrashLogging.userHasOptedOut
        #endif
    }

    static var userHasOptedOut: Bool {
        get {
            /// If we can't say for sure, assume the user has opted out
            guard sharedInstance.dataProvider != nil else { return true }
            return sharedInstance.dataProvider.userHasOptedOut
        }
        set {
            sharedInstance.applyUserTrackingPreferences()
        }
    }

    static func crash() {
        Client.shared?.crash()
    }
}

// Manual Error Logging
extension WPCrashLogging {
    static func logError(_ error: Error) {
        let event = Event(level: .error)
        event.message = error.localizedDescription

        Client.shared?.appendStacktrace(to: event)
        Client.shared?.send(event: event)
    }
}

// User Tracking
extension WPCrashLogging {

    func applyUserTrackingPreferences() {

        if !WPCrashLogging.userHasOptedOut {
            enableUserTracking()
        }
        else {
            disableUserTracking()
        }
    }

    func enableUserTracking() {
        /// Don't continue unless `start` has been called on the crash logger
        guard self.dataProvider != nil else { return }

        Client.shared?.user = Sentry.User(user: dataProvider.currentUser, additionalUserData: dataProvider.additionalUserData)
    }

    func disableUserTracking() {
        Client.shared?.clearContext()
    }
}

extension Sentry.User {

    convenience init(user: WPCrashLoggingUser?, additionalUserData: [String : Any]) {

        let userID = user?.userID ?? "0"
        let username = user?.username ?? "anonymous"

        self.init(userId: username)
        email = user?.email
        extra = additionalUserData.merging([
            "user_id": userID,
        ]) { (application_value, library_value) in application_value }
    }
}
