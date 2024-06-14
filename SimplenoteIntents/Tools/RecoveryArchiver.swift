import Foundation
import UniformTypeIdentifiers

public class RecoveryArchiver {
    private let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    // MARK: Archive
    //
    public func archiveContent(_ content: String) {
        guard let fileURL = url(for: UUID().uuidString) else {
            return
        }

        guard let data = content.data(using: .utf8) else {
            return
        }
        try? data.write(to: fileURL)
    }

    private func url(for identifier: String) -> URL? {
        guard let recoveryDirURL = fileManager.recoveryDirectoryURL() else {
            return nil
        }
        let formattedID = identifier.replacingOccurrences(of: "/", with: "-")
        let fileName = "\(Constants.recoveredContent)-\(formattedID)"
        return recoveryDirURL.appendingPathComponent(fileName, conformingTo: UTType.json)
    }
}

private struct Constants {
    static let recoveredContent = "recoveredContent"
}
