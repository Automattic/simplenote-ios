import Foundation


// MARK: - UIAlertController Helpers
//
extension UIAlertController {
    
    /// Builds an alert indicating that the Login Code has Expired
    ///
    static func buildLoginCodeNotFoundAlert(onRequestCode: @escaping () -> Void) -> UIAlertController {
        let title = NSLocalizedString("Login Failed", comment: "Title for the expired login code alert")
        let message = NSLocalizedString("The authentication code you've requested has expired. Please request a new one", comment: "Message for the expired login code alert")
        let dismissText = NSLocalizedString("OK", comment: "Dismisses the expired login code alert")

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addDefaultActionWithTitle(dismissText) { _ in
            onRequestCode()
        }
        
        return alertController
    }
}
