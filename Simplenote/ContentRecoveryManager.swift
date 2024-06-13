import Foundation
import UniformTypeIdentifiers
import CoreData

public class ContentRecoveryManager {
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

    // MARK: Restore
    //
    public func prepareRecoveredNoteContentIfNeeded(in context: NSManagedObjectContext) async -> [String] {
        createRecoveryDirIfNeeded()

        guard let recoveryFiles = try? fileManager.contentsOfDirectory(at: fileManager.recoveryDirectoryURL, includingPropertiesForKeys: nil),
        !recoveryFiles.isEmpty else {
            return []
        }

        return recoveryFiles.compactMap { url in
            guard let content =  prepareNoteContent(at: url, in: context) else {
                return nil
            }

            try? fileManager.removeItem(at: url)
            return content
        }
    }

    private func prepareNoteContent(at url: URL, in context: NSManagedObjectContext) -> String? {
        guard let data = fileManager.contents(atPath: url.path),
              let content = String(data: data, encoding: .utf8) else {
            return nil
        }
        return content
    }

    private func identifier(from url: URL) -> String? {
        let fileName = url.deletingPathExtension().lastPathComponent
        let components = fileName.components(separatedBy: "-")
        return components.last
    }
 }

private struct Constants {
    static let recoveredContent = "recoveredContent"
    static let richTextKey = "richText"
}
