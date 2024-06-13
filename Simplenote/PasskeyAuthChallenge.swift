import Foundation

struct PasskeyAuthChallenge: Decodable {
    let relayingParty: String
    let challenge: String

    enum CodingKeys: String, CodingKey {
        case relayingParty = "rpId"
        case challenge
    }
}
