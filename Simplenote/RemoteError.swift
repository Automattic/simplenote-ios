import Foundation

enum RemoteError: Error {
    case network
    case responseUnableToDecode
    case requestError(Int, Error?)
}

extension RemoteError: Equatable {
    static func == (lhs: RemoteError, rhs: RemoteError) -> Bool {
        switch (lhs, rhs) {
        case (.network, .network):
            return true
        case (.requestError(let lhsStatus, let lhsError), .requestError(let rhsStatus, let rhsError)):
            return lhsStatus == rhsStatus && lhsError?.localizedDescription == rhsError?.localizedDescription
        default:
            return false
        }
    }
}
