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

    /// Remote service
    ///
    private let remote: AccountRemote

    /// Initialize with user's email
    ///
    init(email: String, remote: AccountRemote = .init()) {
        self.email = email
        self.remote = remote
        super.init()
    }

    /// Update verification state with data from `email-verification` entity
    ///
    @objc
    func update(with rawData: Any?) {
        guard !email.isEmpty else {
            return
        }

        guard let rawData = rawData as? [AnyHashable: Any] else {
            state = .unverified
            return
        }

        let emailVerification = EmailVerification(payload: rawData)

        if emailVerification.token?.username.lowercased() == email.lowercased() {
            state = .verified
        } else if emailVerification.sentTo != nil {
            state = .verificationInProgress
        } else {
            state = .unverified
        }
    }

    /// Send verification request
    ///
    func verify(completion: @escaping (_ result: Result<Data, RemoteError>) -> Void) {
        remote.verify(email: email, completion: completion)
    }
}
