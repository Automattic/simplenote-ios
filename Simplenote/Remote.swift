import Foundation

class Remote {
    private let urlSession: URLSession

    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    /// Send  task for remote
    /// Sublcassing Notes: To be able to send a task it is required to first setup the URL request for the task to use
    ///
    func performDataTask(with request: URLRequest, completion: @escaping (_ result: Result<Int, RemoteError>) -> Void) {
        let dataTask = urlSession.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                NSLog("Status code from data task: \(statusCode)")
                // Check for 2xx status code
                guard statusCode / 100 == 2 else {
                    completion(.failure(RemoteError(statusCode: statusCode)))
                    return
                }

                completion(.success(statusCode))
            }
        }

        dataTask.resume()
    }
}

struct RemoteError: Error, Equatable {
    static func == (lhs: RemoteError, rhs: RemoteError) -> Bool {
        lhs.statusCode == rhs.statusCode
    }

    let statusCode: Int
}
