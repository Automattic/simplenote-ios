import Foundation
import UniformTypeIdentifiers
import CoreData

public class RecoveryUnarchiver {
    private let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    var simperium: Simperium {
        SPAppDelegate.shared().simperium
    }

    private func createRecoveryDirIfNeeded() {
        guard !fileManager.directoryExistsAtURL(fileManager.recoveryDirectoryURL) else {
            return
        }

        try? fileManager.createDirectory(at: fileManager.recoveryDirectoryURL, withIntermediateDirectories: true)
    }

    // MARK: Restore
    //
    public func prepareRecoveredNoteContentIfNeeded() {
        createRecoveryDirIfNeeded()
        guard let recoveryFiles = try? fileManager.contentsOfDirectory(at: fileManager.recoveryDirectoryURL, includingPropertiesForKeys: nil),
        !recoveryFiles.isEmpty else {
            return
        }

        recoveryFiles.forEach { url in
            insertNote(from: url)
            try? fileManager.removeItem(at: url)
        }
    }

    private func insertNote(from url: URL) {
        guard let data = fileManager.contents(atPath: url.path),
              let recoveredContent = String(data: data, encoding: .utf8),
              let note = simperium.notesBucket.insertNewObject() as? Note else {
            return
        }

        var content = Constants.recoveredContentHeader
        content += "\n\n"
        content += recoveredContent
        note.content = content

        note.modificationDate = Date()
        note.creationDate = Date()
        note.markdown = UserDefaults.standard.bool(forKey: .markdown)

        simperium.save()
    }
 }

private struct Constants {
    static let recoveredContentHeader = NSLocalizedString("Recovered Note Cotent - ", comment: "Header to put on any files that need to be recovered")
}
