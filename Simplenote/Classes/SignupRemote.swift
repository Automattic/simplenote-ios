import Foundation

// MARK: - SignupRemote
//
class SignupRemote {
    enum Result {
        case success
        case failure(_ statusCode: Int, _ error: Error?)
    }

    private let urlSession: URLSession

    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    /// Send signup request for specified email address
    ///
    func signup(with email: String, completion: @escaping (_ result: Result) -> Void) {
        guard let request = request(with: email) else {
            completion(.failure(0, nil))
            return
        }

        let dataTask = urlSession.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0

                // Check for 2xx status code
                guard statusCode / 100 == 2 else {
                    completion(.failure(statusCode, error))
                    return
                }

                completion(.success)
            }
        }

        dataTask.resume()
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
        request.httpBody = try? JSONEncoder().encode(["username": email])

        return request
    }
}
