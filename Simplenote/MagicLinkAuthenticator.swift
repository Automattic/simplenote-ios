import Foundation

// MARK: - MagicLinkAuthenticator
//
struct MagicLinkAuthenticator {
    let authenticator: SPAuthenticator

    func handle(url: URL) {
        guard url.host == Constants.host else {
            return
        }

        guard let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems else {
            return
        }

        guard let email = queryItems.value(for: Constants.emailField),
              let token = queryItems.value(for: Constants.tokenField),
              !email.isEmpty, !token.isEmpty else {
            return
        }

        authenticator.authenticate(withUsername: email, token: token)
    }
}


// MARK: - [URLQueryItem] Helper
//
private extension Array where Element == URLQueryItem {
    func value(for name: String) -> String? {
        first(where: { $0.name == name })?.value
    }
}


// MARK: - Constants
//
private struct Constants {
    static let host = "login"
    static let emailField = "email"
    static let tokenField = "token"
}
