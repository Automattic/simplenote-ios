import Foundation

struct PasskeyRegistrationChallenge: Decodable {
    private struct User: Decodable {
        let name: String
        let userID: String

        enum CodingKeys: String, CodingKey {
            case name
            case userID = "id"
        }
    }

    private struct RelayingParty: Decodable {
        let id: String
    }

    private let relayingParty: PasskeyRegistrationChallenge.RelayingParty
    private let user: PasskeyRegistrationChallenge.User
    private let challenge: String

    enum CodingKeys: String, CodingKey {
        case relayingParty = "rp"
        case user
        case challenge
    }

    var relayingPartyIdentifier: String {
        relayingParty.id
    }

    var challengeData: Data? {
        challenge.data(using: .utf8)
    }

    var displayName: String {
        user.name
    }

    var userID: Data? {
        user.userID.data(using: .utf8)
    }
}
