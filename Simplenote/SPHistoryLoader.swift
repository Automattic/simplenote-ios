import Foundation

// MARK: - SPHistoryLoader: Request and aggregate versions of Simperium object
//
@objc
final class SPHistoryLoader: NSObject {
    private let bucket: SPBucket
    private let simperiumKey: String
    private var callback: ((SPHistoryVersion) -> Void)?
    
    /// Range of versions available to load
    /// Contains at least the current version of an object
    ///
    let versionRange: ClosedRange<Int>

    /// Designated Initializer
    ///
    /// - Parameters:
    ///     - bucket: Simperium bucket
    ///     - simperiumKey: Key of Object for which to load history
    ///     - currentVersion: Current version of Object. Used to calculate the amount of available versions to load
    ///
    init(bucket: SPBucket, simperiumKey: String, currentVersion: Int) {
        self.bucket = bucket
        self.simperiumKey = simperiumKey

        let upperBound = max(currentVersion, Constants.minVersion)
        let lowerBound = max(upperBound - Constants.maxNumberOfVersions + 1, Constants.minVersion)
        versionRange = lowerBound...upperBound
    }

    /// Load verions
    ///
    /// - Parameters:
    ///     - callback: Invoked for every received version
    ///
    func load(callback: @escaping (SPHistoryVersion) -> Void) {
        self.callback = callback
        bucket.requestVersions(Int32(versionRange.count), key: simperiumKey)
    }
}

// MARK: - Data processing
//
extension SPHistoryLoader {
    /// Process and store a version
    ///
    /// As Simperium supports only one delegate and AppDelegate is set as a delegate, so some other
    /// class will pass data to SPHistoryLoader.
    ///
    /// - Parameters:
    ///     - data: data of this version
    ///     - version: version of an object
    ///
    @objc(processData:forVersion:)
    func process(data: [String: Any], forVersion version: Int) {
        let item = SPHistoryVersion(version: version, data: data)
        callback?(item)
    }
}

// MARK: - Convenience init
//
extension SPHistoryLoader {
    /// Convenience init
    ///
    /// - Parameters:
    ///     - note: a note
    ///
    convenience init(note: Note) {
        self.init(bucket: note.bucket,
                  simperiumKey: note.simperiumKey,
                  currentVersion: note.versionInt)
    }
}

// MARK: - Constants
//
private extension SPHistoryLoader {
    struct Constants {
        static let minVersion = 1
        static let maxNumberOfVersions = 30
    }
}
