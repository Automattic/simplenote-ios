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

        if attemptLoginWithToken(queryItems: queryItems) {
            return
        }

        attemptLoginWithAuthCode(queryItems: queryItems)
    }
}

// MARK: - Private API(s)
//
private extension MagicLinkAuthenticator {

    @discardableResult
    func attemptLoginWithToken(queryItems: [URLQueryItem]) -> Bool {
        guard let email = queryItems.base64DecodedValue(for: Constants.emailField),
              let token = queryItems.value(for: Constants.tokenField),
              !email.isEmpty, !token.isEmpty else {
            return false
        }

        authenticator.authenticate(withUsername: email, token: token)
        return true
    }

    @discardableResult
    func attemptLoginWithAuthCode(queryItems: [URLQueryItem]) -> Bool {
        guard let authKey = queryItems.value(for: Constants.authKeyField),
              let authCode = queryItems.value(for: Constants.authCodeField),
              !authKey.isEmpty, !authCode.isEmpty
        else {
            return false
        }

        NSLog("[MagicLinkAuthenticator] Requesting SyncToken for \(authKey) and \(authCode)")
        
        Task {
            do {
                let remote = LoginRemote()
                let confirmation = try await remote.requestLoginConfirmation(authKey: authKey, authCode: authCode)
                
                Task { @MainActor in
                    NSLog("[MagicLinkAuthenticator] Should auth with token \(confirmation.syncToken)")
                    authenticator.authenticate(withUsername: confirmation.username, token: confirmation.syncToken)
                    SPTracker.trackUserConfirmedLoginLink()
                }

            } catch {
                NSLog("[MagicLinkAuthenticator] Magic Link TokenExchange Error: \(error)")
            }
        }

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
private struct Constants {
    static let host = "login"
    static let emailField = "email"
    static let tokenField = "token"
    static let authKeyField = "auth_key"
    static let authCodeField = "auth_code"
}
