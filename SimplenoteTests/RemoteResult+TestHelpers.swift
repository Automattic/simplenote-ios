import Foundation
@testable import Simplenote

extension Remote {
    static func randomResult() -> Result<Data?, RemoteError> {
        let random = arc4random_uniform(1)
        if random == 0 {
            return .failure(RemoteError(statusCode: 0))
        } else {
            return .success(nil)
        }
    }
}
