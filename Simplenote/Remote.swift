import Foundation

class Remote {
    private let urlSession: URLSession

    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    /// Send  task for remote
    /// Sublcassing Notes: To be able to send a task it is required to first setup the URL request for the task to use
    ///
    func performDataTask(with request: URLRequest, completion: @escaping (_ result: Result<Data, RemoteError>) -> Void) {
        let dataTask = urlSession.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0

                // Check for 2xx status code
                guard statusCode / 100 == 2,
                      let data = data else {
                    let error = RemoteError(statusCode: statusCode,dataTaskError: error)
                    completion(.failure(error))
                    return
                }

                completion(.success(data))
            }
        }

        dataTask.resume()
    }
}


struct RemoteError: Error {
    let statusCode: Int
    let dataTaskError: Error?

    init(statusCode: Int, dataTaskError: Error? = nil) {
        self.statusCode = statusCode
        self.dataTaskError = dataTaskError
    }
}
