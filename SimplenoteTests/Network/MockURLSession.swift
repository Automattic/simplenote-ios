import Foundation

// MARK: - MockURLSession
//
class MockURLSession: URLSession {
    var data: (Data?, URLResponse?, Error?)?
    var lastRequest: URLRequest?

    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        lastRequest = request
        return MockURLSessionDataTask {
            completionHandler(self.data?.0, self.data?.1, self.data?.2)
        }
    }

    func decodedHtmlBodyInLastRequest<T: Decodable>(outputType: T.Type) throws -> T? {
        guard let lastRequest = lastRequest,
              let data = lastRequest.httpBody else {
            return nil
        }

        return try JSONDecoder().decode(outputType, from: data)
    }
}
