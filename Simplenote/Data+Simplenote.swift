import Foundation

extension Data {
    static func decodeUrlSafeBase64(_ value: String) throws -> Data {
        var stringtoDecode: String = value.replacingOccurrences(of: "-", with: "+")
        stringtoDecode = stringtoDecode.replacingOccurrences(of: "_", with: "/")
        switch stringtoDecode.utf8.count % 4 {
            case 2:
                stringtoDecode += "=="
            case 3:
                stringtoDecode += "="
            default:
                break
        }
        guard let data = Data(base64Encoded: stringtoDecode, options: [.ignoreUnknownCharacters]) else {
            throw NSError(domain: "decodeUrlSafeBase64", code: 1,
                        userInfo: [NSLocalizedDescriptionKey: "Can't decode base64 string"])
        }
        return data
    }
}
