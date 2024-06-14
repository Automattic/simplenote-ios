import Foundation
import UniformTypeIdentifiers

public class RecoveryArchiver {
    private let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    private func createRecoveryDirIfNeeded() {
        guard !fileManager.directoryExistsAtURL(fileManager.recoveryDirectoryURL) else {
            return
        }

        try? fileManager.createDirectory(at: fileManager.recoveryDirectoryURL, withIntermediateDirectories: true)
    }

    // MARK: Archive
    //
    public func archiveContent(_ content: String) {
        createRecoveryDirIfNeeded()

        guard let data = content.data(using: .utf8) else {
            return
        }
        try? data.write(to: url(for: UUID().uuidString))
    }

    private func url(for identifier: String) -> URL {
        let formattedID = identifier.replacingOccurrences(of: "/", with: "-")
        let fileName = "\(Constants.recoveredContent)-\(formattedID)"
        return fileManager.recoveryDirectoryURL.appendingPathComponent(fileName, conformingTo: UTType.json)
    }
}

private struct Constants {
    static let recoveredContent = "recoveredContent"
}
