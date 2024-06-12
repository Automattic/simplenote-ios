import Foundation

class Remote {
    private let urlSession: URLSession

    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    /// Send  task for remote
    /// Sublcassing Notes: To be able to send a task it is required to first setup the URL request for the task to use
    ///
    func performDataTask(with request: URLRequest, completion: @escaping (_ result: Result<Data?, RemoteError>) -> Void) {
        let dataTask = urlSession.dataTask(with: request) { (data, response, dataTaskError) in
            DispatchQueue.main.async {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0

                // Check for 2xx status code
                print("# statusCode: \(statusCode)")
                guard statusCode / 100 == 2 else {
                    let error = statusCode > 0 ?
                        RemoteError.requestError(statusCode, dataTaskError):
                        RemoteError.network
                    completion(.failure(error))
                    return
                }

                completion(.success(data))
            }
        }

        dataTask.resume()
    }

    func performDataTask(with request: URLRequest) async throws -> Data? {
        try await withCheckedThrowingContinuation { continuation in
            performDataTask(with: request) { result in
                switch result {
                case .success(let data):
                    continuation.resume(returning: data)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
