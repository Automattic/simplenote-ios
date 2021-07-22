import Foundation

class AccountDeletionController {
    var successHandler: (() -> Void)?
    var failureHandler: ((Int) -> Void)?

    func requestAccountDeletion(_ user: SPUser) {
        SPAppDelegate.shared().accountDeletionRequestDate = Date()

        AccountRemote().requestDelete(user) { (result) in
            switch result {
            case .success:
                self.successHandler?()
            case .failure(let status, let error):
                NSLog("Delete Account Request Failed with status: %i", status)
                NSLog("Error: ", error?.localizedDescription ?? "Generic Error")
                self.failureHandler?(status)
            }
        }
    }
}
