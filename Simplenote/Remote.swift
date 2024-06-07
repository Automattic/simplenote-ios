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

    /// Performs a URLSession Data Task
    ///
    func performDataTask(with request: URLRequest) async throws -> Data {
        let (data, response) = try await urlSession.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? .zero
        
        // Check for 2xx status code
        guard statusCode / 100 == 2 else {
            throw RemoteError.requestError(statusCode, nil)
        }
        
        return data
    }
    
    /// Performs a URLSession Data Task, and decodes a given Type
    ///
    func performDataTask<T: Decodable>(with request: URLRequest, type: T.Type) async throws -> T {
        let data = try await performDataTask(with: request)

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(type, from: data)

        } catch {
            throw RemoteError.responseUnableToDecode
        }
    }
    
    /// Builds a URLRequest for the specified URL / Method / params
    ///
    func requestForURL(_ url: URL, method: String, httpBody: [String: String]?) -> URLRequest {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: RemoteConstants.timeout)

        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let httpBody {
            request.httpBody = try? JSONEncoder().encode(httpBody)
        }

        return request
    }
}
