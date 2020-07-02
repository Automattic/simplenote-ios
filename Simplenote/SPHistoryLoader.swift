import Foundation

final class SPHistoryLoader {
    struct Item {
        let version: Int
        let data: [String: Any]
    }

    private let bucket: SPBucket
    private let simperiumKey: String
    private let amountOfVersionsToLoad: Int

    private var completion: (([Item]) -> Void)?
    private var data: [Int: [String: Any]] = [:]
    private var sortedItems: [Item] {
        self.data
            .map({ Item(version: $0, data: $1) })
            .sorted(by: { $0.version < $1.version })
    }

    init(bucket: SPBucket, simperiumKey: String, currentVersion: Int) {
        self.bucket = bucket
        self.simperiumKey = simperiumKey
        self.amountOfVersionsToLoad = min(currentVersion, Constants.maxNumberOfVersions)
    }

    func load(completion: @escaping ([Item]) -> Void) {
        if self.completion != nil {
            return
        }

        data = [:]
        self.completion = completion

        bucket.requestVersions(Int32(amountOfVersionsToLoad), key: simperiumKey)
    }
}

extension SPHistoryLoader {
    func process(data: [String: Any], forVersion version: Int) {
        self.data[version] = data
        checkIfFinished()
    }

    private func checkIfFinished() {
        guard data.count == amountOfVersionsToLoad else {
            return
        }

        guard let completion = self.completion else {
            return
        }
        self.completion = nil
        completion(sortedItems)
    }
}

extension SPHistoryLoader {
    convenience init(note: Note) {
        let bucket = SPAppDelegate.shared().simperium.bucket(forName: "Note")!
        let version = Int(note.version() ?? "1") ?? 1

        self.init(bucket: bucket,
                  simperiumKey: note.simperiumKey,
                  currentVersion: version)
    }
}

private extension SPHistoryLoader {
    struct Constants {
        static let maxNumberOfVersions = 30
    }
}
