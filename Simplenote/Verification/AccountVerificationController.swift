import Foundation

// MARK: - AccountVerificationController
//
@objc
class AccountVerificationController: NSObject {

    /// Possible verification states
    ///
    enum State {
        case unknown
        case unverified
        case verificationInProgress
        case verified
    }

    /// Current verification state
    ///
    private(set) var state: State = .unknown {
        didSet {
            guard oldValue != state else {
                return
            }

            onStateChange?(oldValue, state)
        }
    }

    /// User's email
    ///
    let email: String

    /// Callback is invoked when state changes
    ///
    var onStateChange: ((_ oldState: State, _ state: State) -> Void)?

    /// Initialize with user's email
    ///
    init(email: String) {
        self.email = email
        super.init()
    }

    /// Update verification state with data from `email-verification` entity
    ///
    @objc
    func update(with rawData: Any?) {
        guard !email.isEmpty else {
            return
        }

        guard let rawData = rawData as? [AnyHashable: Any],
              let emailVerification = EmailVerification(payload: rawData) else {
            state = .unverified
            return
        }

        if emailVerification.tokenEmail == email {
            state = .verified
        } else if emailVerification.status == .sent {
            state = .verificationInProgress
        } else {
            state = .unverified
        }
    }

    /// Send verification request
    ///
    func verify(completion: @escaping (_ success: Bool) -> Void) {
        guard let request = verificationURLRequest else {
            completion(false)
            return
        }

        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                guard let response = response as? HTTPURLResponse, response.statusCode / 100 == 2 else {
                    completion(false)
                    return
                }

                completion(true)
            }
        }

        dataTask.resume()
    }

    private var verificationURLRequest: URLRequest? {
        guard let base64EncodedEmail = email.data(using: .utf8)?.base64EncodedString() else {
            return nil
        }

        let verificationURL = Constants.verificationURL.appendingPathComponent(base64EncodedEmail)

        var request = URLRequest(url: verificationURL,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: Constants.timeoutInterval)
        request.httpMethod = "GET"

        return request
    }
}

// MARK: - Constants
//
private struct Constants {
    static let timeoutInterval: TimeInterval = 30
    static let verificationURL = URL(string: "https://app.simplenote.com/account/verify-email/")!
}
