import Foundation

// MARK: - SPHistoryLoader: Request and aggregate versions of Simperium object
//
final class SPHistoryLoader {

    // MARK: - Item: Represents a version object
    //
    struct Item {
        let version: Int
        let modificationDate: Date
        let content: String
    }

    private let bucket: SPBucket
    private let simperiumKey: String
    private let amountOfVersionsToLoad: Int

    private var completion: (([Item]) -> Void)?
    private var items: Set<Item> = []

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
    func load(completion: @escaping ([Item]) -> Void) {
        if self.completion != nil {
            return
        }

        items = []
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
    /// class will pass data to SPHistoryLoader. (In case of note version, it's note editor)
    ///
    /// - Parameters:
    ///     - data: data of this version
    ///     - version: version of an object
    ///
    func process(data: [String: Any], forVersion version: Int) {
        let item = Item(version: version, data: data)
        items.insert(item)
        checkIfFinished()
    }

    private func checkIfFinished() {
        guard items.count == amountOfVersionsToLoad else {
            return
        }

        guard let completion = self.completion else {
            return
        }
        self.completion = nil
        completion(items.sorted(by: { $0.version < $1.version }))
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
        let bucket = SPAppDelegate.shared().simperium.bucket(forName: Note.classNameWithoutNamespaces)!
        let version = Int(note.version() ?? "1") ?? 1

        self.init(bucket: bucket,
                  simperiumKey: note.simperiumKey,
                  currentVersion: version)
    }
}

// MARK: - Constants
//
private extension SPHistoryLoader {
    struct Constants {
        static let maxNumberOfVersions = 30
    }
}

// MARK: - SPHistoryLoader.Item Constructor
//
private extension SPHistoryLoader.Item {
    init(version: Int, data: [String: Any]) {
        self.version = version

        let timeInterval = data["modificationDate"] as? TimeInterval
        modificationDate = Date(timeIntervalSince1970: timeInterval ?? 0)
        content = (data["content"] as? String) ?? ""
    }
}

// MARK: - SPHistoryLoader.Item Hashable
//
extension SPHistoryLoader.Item: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(version)
    }
}
