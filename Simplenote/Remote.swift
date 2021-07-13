import Foundation

class Remote {
    enum Result: Equatable {
        static func == (lhs: Remote.Result, rhs: Remote.Result) -> Bool {
            switch (lhs, rhs) {
            case (.success, .success):
                return true
            case (.failure(let code1, _), .failure(let code2, _)):
                return code1 == code2
            default:
                return false
            }

        }

        case success
        case failure(_ statusCode: Int, _ error: Error?)

        static func random() -> Result {
            let random = arc4random_uniform(1)
            if random == 0 {
                return .failure(0, nil)
            } else {
                return .success
            }
        }
    }

    private let urlSession: URLSession

    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    /// Send  task for remote
    /// Sublcassing Notes: To be able to send a task it is required to first setup the URL request for the task to use
    ///
    func performDataTask(with request: URLRequest, completion: @escaping (_ result: Result) -> Void) {
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
}
