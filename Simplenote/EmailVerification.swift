import Foundation


// MARK: - EmailVerification
//
struct EmailVerification {
    let token: EmailVerificationToken?
    let pending: EmailVerificationPending?
}

// MARK: - EmailVerificationToken
//
struct EmailVerificationToken: Decodable {
    let username: String
}

// MARK: - EmailVerificationPending
//
struct EmailVerificationPending {
    let email: String
}

// MARK: - Init from payload
//
extension EmailVerification {

    /// Initializes an EmailVerification entity from a dictionary
    ///
    init(payload: [AnyHashable: Any]) {
        token = {
            guard let dataString = payload[EmailVerificationKeys.token.rawValue] as? String,
                  let data = dataString.data(using: .utf8) else {
                return nil
            }

            return try? JSONDecoder().decode(EmailVerificationToken.self, from: data)
        }()


        pending = {
            guard let payload = payload[EmailVerificationKeys.pending.rawValue] as? [AnyHashable: Any] else {
                return nil
            }

            return EmailVerificationPending(payload: payload)
        }()
    }
}

extension EmailVerificationPending {
    init?(payload: [AnyHashable: Any]) {
        guard let email = payload[EmailVerificationPendingKeys.email.rawValue] as? String else {
            return nil
        }

        self.email = email
    }
}

// MARK: - CodingKeys
//
private enum EmailVerificationKeys: String {
    case token
    case pending
}

private enum EmailVerificationPendingKeys: String {
    case email = "sent_to"
}
