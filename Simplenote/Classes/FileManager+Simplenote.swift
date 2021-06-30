import Foundation

// MARK: - FileManager
//
extension FileManager {

     /// User's Document Directory
     ///
     var documentsURL: URL {
         guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
             fatalError("Cannot Access User Documents Directory")
         }

         return url
     }

    /// URL for Simplenote's shared app group directory
    ///
    var sharedContainerURL: URL {
        containerURL(forSecurityApplicationGroupIdentifier: Constants.sharedDirectoryDomain + Constants.groupIdentifier)!
    }
}

private struct Constants {
    static let defaultBundleIdentifier = "com.codality.NotationalFlow"
    static let groupIdentifier = rootBundleIdentifier() ?? Constants.defaultBundleIdentifier
    static let sharedDirectoryDomain = "group."

    static func rootBundleIdentifier() -> String? {
        if Bundle.main.bundleURL.pathExtension != "appex" {
            return Bundle.main.bundleIdentifier
        }

        let url = Bundle.main.bundleURL.deletingLastPathComponent().deletingLastPathComponent()

        guard let bundle = Bundle(url: url) else {
            return nil
        }
        return bundle.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String
    }
}
