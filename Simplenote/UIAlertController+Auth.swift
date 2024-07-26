import Foundation


// MARK: - UIAlertController Helpers
//
extension UIAlertController {
    
    /// Builds an alert indicating that the Login Code has Expired
    ///
    static func buildLoginCodeNotFoundAlert(onRequestCode: @escaping () -> Void) -> UIAlertController {
        let title = NSLocalizedString("Sorry!", comment: "Email TextField Placeholder")
        let message = NSLocalizedString("The authentication code you've requested has expired. Please request a new one", comment: "Email TextField Placeholder")
        let acceptText = NSLocalizedString("Accept", comment: "Accept Message")

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addDefaultActionWithTitle(acceptText) { _ in
            onRequestCode()
        }
        
        return alertController
    }
}
