import Foundation

enum RemoteError: Error {
    case network
    case requestError(Int, Error?)
}

extension RemoteError: Equatable {
    static func == (lhs: RemoteError, rhs: RemoteError) -> Bool {
        lhs.localizedDescription == rhs.localizedDescription
    }

    init(statusCode: Int, dataTaskError: Error? = nil) {
        switch statusCode {
        case 0:
            self = .network
        default:
            self = .requestError(statusCode, dataTaskError)
        }
    }
}
