import Foundation


// MARK: - EmailVerification
//
struct EmailVerification {
    let token: String?
    let status: EmailVerificationStatus
}

enum EmailVerificationStatus: String {
    case sent
    case verified
}


// MARK: - Public API(s)
//
extension EmailVerification {

    /// Initializes an EmailVerification entity from a dictionary
    ///
    init?(payload: [AnyHashable: Any]) {
        guard let rawStatus = payload[CodingKeys.status.rawValue] as? String,
              let parsedStatus = EmailVerificationStatus(rawValue: rawStatus)
        else {
            return nil
        }

        self.token = payload[CodingKeys.token.rawValue] as? String
        self.status = parsedStatus
    }
}

// MARK: - CodingKeys
//
private enum CodingKeys: String {
    case token
    case status
}
