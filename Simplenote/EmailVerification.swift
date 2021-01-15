import Foundation


// MARK: - EmailVerification
//
struct EmailVerification {
    let token: String
    let status: String
}


// MARK: - Public API(s)
//
extension EmailVerification {

    /// Initializes an EmailVerification entity from a dictionary
    ///
    init?(payload: [AnyHashable: Any]) {
        guard let token = payload[CodingKeys.token.rawValue] as? String,
              let status = payload[CodingKeys.status.rawValue] as? String
        else {
            return nil
        }

        self.token = token
        self.status = status
    }
}

// MARK: - CodingKeys
//
private enum CodingKeys: String {
    case token
    case status
}
