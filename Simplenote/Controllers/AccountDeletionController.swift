import Foundation

@objc
class AccountDeletionController: NSObject {
    private var accountDeletionRequestDate: Date?

    var hasValidDeletionRequest: Bool {
        guard let expirationDate = accountDeletionRequestDate?.increased(byDays: 1) else {
            return false
        }

        return Date() < expirationDate
    }

    func requestAccountDeletion(_ user: SPUser, completion: @escaping (_ result: Result<Data?, RemoteError>) -> Void) {
        AccountRemote().requestDelete(user) { [weak self] (result) in
            if case .success = result {
                self?.accountDeletionRequestDate = Date()
            }
            completion(result)
        }
    }

    @objc
    func clearRequestToken() {
        accountDeletionRequestDate = nil
    }
}
