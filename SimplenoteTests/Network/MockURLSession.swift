import Foundation

// MARK: - MockURLSession
//
class MockURLSession: URLSession {
    var data: (Data?, URLResponse?, Error?)?

    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return MockURLSessionDataTask {
            completionHandler(self.data?.0, self.data?.1, self.data?.2)
        }
    }
}
