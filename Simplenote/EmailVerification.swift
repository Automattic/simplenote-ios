import Foundation


// MARK: - EmailVerification
//
struct EmailVerification {
    let token: String?
    let status: EmailVerificationStatus
}

enum EmailVerificationStatus: Equatable {
    case sent(email: String?)
    case verified
}


// MARK: - Public API(s)
//
extension EmailVerification {

    /// Initializes an EmailVerification entity from a dictionary
    ///
    init?(payload: [AnyHashable: Any]) {
        guard let rawStatus = payload[EmailVerificationKeys.status.rawValue] as? String,
            let parsedStatus = EmailVerificationStatus(rawValue: rawStatus)
        else {
            return nil
        }

        self.token = payload[EmailVerificationKeys.token.rawValue] as? String
        self.status = parsedStatus
    }

    var tokenEmail: String? {
        guard let email = token?.split(separator: ":", maxSplits: 1).first else {
            return nil
        }
        return String(email)
    }
}


// MARK: - EmailVerificationStatus Parsing
//
extension EmailVerificationStatus {

    init?(rawValue: String) {
        let tokens = rawValue.lowercased().split(separator: ":", maxSplits: 2).map {
            String($0)
        }

        switch tokens.first {
        case EmailStatusKeys.verified.rawValue:
            self = .verified

        case EmailStatusKeys.sent.rawValue:
            let value = tokens.last != tokens.first ? tokens.last : nil
            self = .sent(email: value)

        default:
            return nil
        }
    }
}


// MARK: - CodingKeys
//
private enum EmailVerificationKeys: String {
    case token
    case status
}

private enum EmailStatusKeys: String {
    case verified
    case sent
}
