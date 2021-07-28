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
            case .failure(let error):
                NSLog("Delete Account Request Failed with status: %i", error.statusCode)
                NSLog("Error: ", error.localizedDescription)
                self.failureHandler?(error.statusCode)
            }
        }
    }
}
