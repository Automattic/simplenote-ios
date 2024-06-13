import Foundation

struct PasskeyVerifyResponse: Decodable {
    let username: String
    let accessToken: String
    let verify: String

    enum CodingKeys: String, CodingKey {
        case username
        case accessToken = "access_token"
        case verify
    }
}
