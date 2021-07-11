import Foundation

class DeleteAccountRemote: Remote {
    func requestDelete(_ user: SPUser, completion: @escaping (_ result: Result) -> Void) {
        guard let request = request(with: user) else {
            completion(.failure(0, nil))
            return
        }

        task(with: request, completion: completion)
    }

    private func request(with user: SPUser) -> URLRequest? {
        guard let url = URL(string: SimplenoteConstants.accountDeletion) else {
            return nil
        }

        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: RemoteConstants.timeout)
        request.httpMethod = RemoteConstants.Method.POST
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = [
            "username": user.email.lowercased(),
            "token": user.authToken
        ]
        request.httpBody = try? JSONEncoder().encode(body)

        return request
    }
}
