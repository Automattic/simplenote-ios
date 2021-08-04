import Foundation

// MARK: - SignupRemote
//
class SignupRemote: Remote {
    func signup(with email: String, completion: @escaping (_ result: Result<Data?, RemoteError>) -> Void) {
        let urlRequest = request(with: email)!

        performDataTask(with: urlRequest, completion: completion)
    }

    private func request(with email: String) -> URLRequest? {
        guard let url = URL(string: SimplenoteConstants.signupURL) else {
            return nil
        }

        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: RemoteConstants.timeout)
        request.httpMethod = RemoteConstants.Method.POST
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["username": email.lowercased()])

        return request
    }
}
