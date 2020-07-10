import Foundation

// MARK: - SPHistoryLoader: Request and aggregate versions of Simperium object
//
@objc
final class SPHistoryLoader: NSObject {
    private let bucket: SPBucket
    private let simperiumKey: String
    private let amountOfVersionsToLoad: Int

    private var completion: (([SPHistoryVersion]) -> Void)?
    private var versions: Set<SPHistoryVersion> = []

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
        amountOfVersionsToLoad = min(currentVersion, Constants.maxNumberOfVersions)
    }

    /// Load verions
    ///
    /// - Parameters:
    ///     - completion: Invoked after all requested versions have arrived
    ///
    func load(completion: @escaping ([SPHistoryVersion]) -> Void) {
        if self.completion != nil {
            return
        }

        versions = []
        self.completion = completion

        bucket.requestVersions(Int32(amountOfVersionsToLoad), key: simperiumKey)
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
        versions.insert(item)
        checkIfFinished()
    }

    private func checkIfFinished() {
        guard versions.count == amountOfVersionsToLoad else {
            return
        }

        guard let completion = self.completion else {
            return
        }
        self.completion = nil
        completion(versions.sorted(by: { $0.version < $1.version }))
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
        static let maxNumberOfVersions = 30
    }
}

// MARK: - SPHistoryVersion: init with raw data
//
private extension SPHistoryVersion {
    init(version: Int, data: [String: Any]) {
        self.version = version

        let timeInterval = data["modificationDate"] as? TimeInterval
        modificationDate = Date(timeIntervalSince1970: timeInterval ?? 0)
        content = (data["content"] as? String) ?? ""
    }
}
