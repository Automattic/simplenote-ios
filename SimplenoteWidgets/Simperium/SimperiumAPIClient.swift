import Foundation

class SimperiumAPIClient: NSObject {

        enum Endpoint {
            static let apiVersion = "1"
            static let authBase = "https://auth.simperium.com/\(apiVersion)/"
            static let base = "https://api.simperium.com/\(apiVersion)/"

//            case index(String)

            var stringValue: String {
                switch self {
//                case .index(let bucketName):
                    
            }
        }
    }
}
