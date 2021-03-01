import Foundation

// MARK: - AccountVerificationRemote
//
class AccountVerificationRemote {
    private let urlSession: URLSession

    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    /// Send verification request for specified email address
    ///
    func verify(email: String, completion: @escaping (_ success: Bool) -> Void) {
        guard let request = verificationURLRequest(with: email) else {
            completion(false)
            return
        }

        let dataTask = urlSession.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                // Check for 2xx status code
                guard let response = response as? HTTPURLResponse, response.statusCode / 100 == 2 else {
                    completion(false)
                    return
                }

                completion(true)
            }
        }

        dataTask.resume()
    }

    private func verificationURLRequest(with email: String) -> URLRequest? {
        guard let base64EncodedEmail = email.data(using: .utf8)?.base64EncodedString(),
              let verificationURL = URL(string: SimplenoteConstants.verificationURL) else {
            return nil
        }

        var request = URLRequest(url: verificationURL.appendingPathComponent(base64EncodedEmail),
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: RemoteConstants.timeout)
        request.httpMethod = RemoteConstants.Method.GET

        return request
    }
}
