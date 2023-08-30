import Foundation


// MARK: - VersionsController
//
class VersionsController: NSObject {
    private let bucket: SPBucket

    /// Map of event listeners.
    ///
    private let callbackMap = NSMapTable<NSString, ListenerWrapper>(keyOptions: .copyIn, valueOptions: .weakMemory)


    /// Designated Initializer
    ///
    /// - Parameters:
    ///     - bucket: Simperium bucket
    ///
    init(bucket: SPBucket) {
        self.bucket = bucket
        super.init()
    }


    /// Requests the specified number of versions of Notes for a given SimperiumKey.
    ///
    /// - Parameters:
    ///     - simperiumKey: Identifier of the entity
    ///     - currentVersion: Current version of Object. Used to calculate the amount of available versions to load
    ///     - onResponse: Closure to be executed whenever a new version is received. This closure might be invoked `N` times.
    ///
    /// - Returns: An opaque entity, which should be retained by the callback handler.
    ///
    /// - Note: Whenever the returned entity is released, no further events will be relayed to the `onResponse` closure.
    /// - Warning: By design, there can be only *one* listener for changes associated to a SimperiumKey.
    ///
    func requestVersions(for simperiumKey: String, currentVersion: Int, onResponse: @escaping (SPHistoryVersion) -> Void) -> Any {

        // Keep a reference to the closure
        let wrapper = ListenerWrapper(block: onResponse)
        callbackMap.setObject(wrapper, forKey: simperiumKey as NSString)

        let versionRange = VersionsController.range(forCurrentVersion: currentVersion)
        bucket.requestVersions(versionRange.count, key: simperiumKey)

        // We'll return the wrapper as receipt
        return wrapper
    }
}


// MARK: - Simperium
//
extension VersionsController {

    /// Notifies all of the subscribers a new Version has been retrieved from Simperium.
    /// - Note: This API should be (manually) invoked everytime SPBucket's delegate receives a new Version (!)
    ///
    @objc(didReceiveObjectForSimperiumKey:version:data:)
    func didReceiveObject(for simperiumKey: String, version: Int, data: NSDictionary) {
        guard let wrapper = callbackMap.object(forKey: simperiumKey as NSString) else {
            return
        }

        guard let payload = data as? [AnyHashable: Any], let item = SPHistoryVersion(version: version, payload: payload) else {
            return
        }

        wrapper.block(item)
    }
}

// MARK: - Helpers
//
extension VersionsController {

    /// Returns an range of versions which can be requested
    ///
    /// - Parameters:
    ///     - version: Current version of the entity
    ///
    /// - Returns: Range of versions
    ///
    static func range(forCurrentVersion version: Int) -> ClosedRange<Int> {
        let upperBound = max(version, Constants.minVersion)
        let lowerBound = max(upperBound - Constants.maxNumberOfVersions + 1, Constants.minVersion)
        return lowerBound...upperBound
    }
}

// MARK: - ListenerWrapper
//
private class ListenerWrapper: NSObject {
    let block: (SPHistoryVersion) -> Void

    init(block: @escaping (SPHistoryVersion) -> Void) {
        self.block = block
    }
}

// MARK: - Constants
//
private struct Constants {
    static let minVersion = 1
    static let maxNumberOfVersions = 30
}
