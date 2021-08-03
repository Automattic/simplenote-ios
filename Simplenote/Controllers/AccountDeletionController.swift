import Foundation

@objc
class AccountDeletionController: NSObject {
    private let accountDeletionRequestDate = Date()

    var deletionTokenHasExpired: Bool {
        guard let expirationDate = accountDeletionRequestDate.increased(byDays: 1) else {
            return true
        }

        return Date() > expirationDate
    }

    func requestAccountDeletion(_ user: SPUser, completion: @escaping (_ result: Result<Data?, RemoteError>) -> Void) {

        AccountRemote().requestDelete(user, completion: completion)
    }
}
