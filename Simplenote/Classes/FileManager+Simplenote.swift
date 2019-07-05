import Foundation


// MARK: - Paths
//
extension FileManager {

    /// User's Document Directory
    ///
    class var documentsURL: URL {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Cannot Access User Documents Directory")
        }

        return url
    }

    /// Writes a given Note to the Documents folder
    ///
    class func writeToDocuments(note: Note) -> URL? {
        guard let payload = note.content else {
            return nil
        }

        let filename = String(format: "%@.txt", note.simperiumKey)
        let targetURL = FileManager.documentsURL.appendingPathComponent(filename)

        do {
            try payload.write(to: targetURL, atomically: true, encoding: .utf8)
        } catch {
            NSLog("Note Exporter Failure: \(error)")
            return nil
        }

        return targetURL
    }
}
