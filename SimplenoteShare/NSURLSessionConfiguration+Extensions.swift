import Foundation


/// Encapsulates NSURLSessionConfiguration Helpers
///
extension NSURLSessionConfiguration
{
    /// Returns a new Background Session Configuration, with a random identifier.
    ///
    class func backgroundSessionConfigurationWithRandomizedIdentifier() -> NSURLSessionConfiguration {
        let identifier = kShareExtensionGroupName + "." + NSUUID().UUIDString
        let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(identifier)
        configuration.sharedContainerIdentifier = kShareExtensionGroupName

        return configuration
    }
}
