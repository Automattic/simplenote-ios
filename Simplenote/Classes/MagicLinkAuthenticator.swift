import Foundation

// MARK: - MagicLinkAuthenticator
//
struct MagicLinkAuthenticator {
    let authenticator: SPAuthenticator

    func handle(url: URL) -> Bool {
        guard AllowedHosts.all.contains(url.host) else {
            return false
        }

        guard let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems else {
            return false
        }

        guard let email = queryItems.base64DecodedValue(for: Constants.emailField),
              let token = queryItems.value(for: Constants.tokenField),
              !email.isEmpty, !token.isEmpty else {
            return false
        }

        authenticator.authenticate(withUsername: email, token: token)
        return true
    }
}

// MARK: - [URLQueryItem] Helper
//
private extension Array where Element == URLQueryItem {
    func value(for name: String) -> String? {
        first(where: { $0.name == name })?.value
    }

    func base64DecodedValue(for name: String) -> String? {
        guard let base64String = value(for: name),
              let data = Data(base64Encoded: base64String) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }
}

// MARK: - Constants
//
private struct AllowedHosts {
    static let hostForSimplenoteSchema = "login"
    static let hostForUniversalLinks = URL(string: SPCredentials.defaultEngineURL)!.host
    static let all = [hostForSimplenoteSchema, hostForUniversalLinks]
}

private struct Constants {
    static let emailField = "email"
    static let tokenField = "token"
}
