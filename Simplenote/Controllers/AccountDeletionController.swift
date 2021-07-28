import Foundation

class AccountDeletionController {
    func requestAccountDeletion(_ user: SPUser, completion: @escaping (_ result: Result<Data, RemoteError>) -> Void) {
        SPAppDelegate.shared().accountDeletionRequestDate = Date()
        AccountRemote().requestDelete(user, completion: completion)
    }
}
