import Foundation

/// Encapsulates NSURLSessionConfiguration Helpers
///
extension URLSessionConfiguration {

    /// Returns a new Background Session Configuration, with a random identifier.
    ///
    class func backgroundSessionConfigurationWithRandomizedIdentifier() -> URLSessionConfiguration {
        let identifier = kShareExtensionGroupName + "." + UUID().uuidString
        let configuration = URLSessionConfiguration.background(withIdentifier: identifier)
        configuration.sharedContainerIdentifier = kShareExtensionGroupName

        return configuration
    }
}
