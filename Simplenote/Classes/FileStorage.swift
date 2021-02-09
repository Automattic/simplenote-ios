import Foundation

// MARK: - FileStorage
//
class FileStorage<T: Codable> {
    private let fileURL: URL

    private lazy var decoder = JSONDecoder()
    private lazy var encoder = JSONEncoder()

    init(fileURL: URL) {
        self.fileURL = fileURL
    }

    /// Load an object
    ///
    func load() throws -> T? {
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode(T.self, from: data)
    }

    /// Save an object
    ///
    func save(object: T) throws {
        let data = try encoder.encode(object)
        try data.write(to: fileURL)
    }
}
