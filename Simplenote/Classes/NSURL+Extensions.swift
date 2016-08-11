import Foundation


/// This extension contains several helper-additions to Cocoa NSURL class.
///
extension NSURL
{
    /// Returns *true* if the current URL is HTTP or HTTPS
    ///
    public func containsHttpScheme() -> Bool {
        return scheme == "http" || scheme == "https"
    }
}
