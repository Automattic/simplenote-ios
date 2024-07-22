import Foundation


// MARK: - RemoteError
//
struct RemoteError: Error {
    let statusCode: Int
    let response: String?
    let networkError: Error?
}


// MARK: - RemoteError
//
extension RemoteError {
    
    init?(statusCode: Int?, responseData: Data? = nil, networkError: Error? = nil) {
        if let statusCode, statusCode / 100 == 2 {
            return nil
        }

        let response = ReponseErrorContainer(body: responseData)
        
        self.statusCode = statusCode ?? .zero
        self.response = response?.error
        self.networkError = networkError
    }
}


extension RemoteError: Equatable {
    static func == (lhs: RemoteError, rhs: RemoteError) -> Bool {
        lhs.statusCode == rhs.statusCode && lhs.response == rhs.response && lhs.networkError?.localizedDescription == rhs.networkError?.localizedDescription
    }
}


// MARK: - ReponseErrorContainer
//
private struct ReponseErrorContainer: Decodable, Equatable {
    let error: String

    init?(body: Data?) {
        guard let body, let decoded = try? JSONDecoder().decode(ReponseErrorContainer.self, from: body) else {
            return nil
        }
        
        self = decoded
    }
}
