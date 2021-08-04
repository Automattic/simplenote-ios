import Foundation

@objc
class AccountDeletionController: NSObject {
    private var accountDeletionRequestDate: Date?

    var deletionTokenHasExpired: Bool {
        guard let requestDate = accountDeletionRequestDate,
              let expirationDate = requestDate.increased(byDays: 1) else {
            return true
        }

        return Date() > expirationDate
    }

    func requestAccountDeletion(_ user: SPUser, completion: @escaping (_ result: Result<Data?, RemoteError>) -> Void) {
        accountDeletionRequestDate = Date()
        AccountRemote().requestDelete(user) { [weak self] (result) in
            if case .success = result {
                self?.accountDeletionRequestDate = Date()
            }
            completion(result)
        }
    }
}
