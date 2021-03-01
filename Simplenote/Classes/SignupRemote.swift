import Foundation

// MARK: - SignupRemote
//
class SignupRemote {
    private let urlSession: URLSession

    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    /// Send signup request for specified email address
    ///
    func signup(with email: String, completion: @escaping (_ success: Bool) -> Void) {
        guard let request = request(with: email) else {
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

    private func request(with email: String) -> URLRequest? {
        guard let url = URL(string: SimplenoteConstants.signupURL) else {
            return nil
        }

        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: Constants.timeoutInterval)
        request.httpMethod = Constants.httpMethod
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["username": email])

        return request
    }
}

// MARK: - Constants
//
private struct Constants {
    static let httpMethod = "POST"
    static let timeoutInterval: TimeInterval = 30
}
