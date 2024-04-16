import Foundation

// MARK: - EmailVerification
//
struct EmailVerification {
    let token: EmailVerificationToken?
    let sentTo: String?
}

// MARK: - EmailVerificationToken
//
struct EmailVerificationToken: Decodable {
    let username: String
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

        sentTo = payload[EmailVerificationKeys.sentTo.rawValue] as? String
    }
}

// MARK: - CodingKeys
//
private enum EmailVerificationKeys: String {
    case token
    case sentTo = "sent_to"
}
