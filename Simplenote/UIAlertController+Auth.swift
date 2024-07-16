import Foundation


// MARK: - Rate Limiting Alert
//
extension UIAlertController {
    
    static func buildExcessiveLoginCodesRequestedAlert(onDisplayLogin: @escaping () -> Void) -> UIAlertController {
        let alertController = UIAlertController(title: RateLimitStrings.title, message: RateLimitStrings.message, preferredStyle: .alert)
        alertController.addCancelActionWithTitle(RateLimitStrings.cancel)
        alertController.addDefaultActionWithTitle(RateLimitStrings.login) { _ in
            onDisplayLogin()
        }

        return alertController
    }
}


// MARK: - Shared Strings
//
private enum RateLimitStrings {
    static let title = NSLocalizedString("Too Many Requests", comment: "Too Many Requests Alert Title")
    static let message = NSLocalizedString("Please proceed with password authentication", comment: "Too Many Requests Alert Message")
    static let cancel = NSLocalizedString("Cancel", comment: "Cancel Action")
    static let login  = NSLocalizedString("Accept", comment: "Log In Action")
}
