import Foundation

class AccountDeletionController {
    var successHandler: (() -> Void)?

    func requestAccountDeletion(_ user: SPUser) {
        SPTracker.trackDeleteAccountButttonTapped()
        AccountRemote().requestDelete(user) { (result) in
            switch result {
            case .success:
                self.successHandler?()
            case .failure(let status, let error):
                NSLog("Delete Account Request Failed with status: %i Error: %@", [status, error?.localizedDescription ?? "Unknown Error"])
            }
        }
    }
}
