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
    
    /// User's Temporary Directory
    ///
    class var temporaryDirectoryURL: URL {
        return FileManager.default.temporaryDirectory
    }
    
    /// Writes a given String to the documents folder
    ///
    class func writeStringToURL(string: String, to targetURL: URL) -> URL? {
        do {
            try string.write(to: targetURL, atomically: true, encoding: .utf8)
        } catch {
            NSLog("Note Exporter Failure: \(error)")
            return nil
        }

        return targetURL
    }
}
