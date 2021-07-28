import Foundation
@testable import Simplenote

extension AccountVerificationController {
    func randomResult() -> Result<Int, RemoteError> {
        let random = arc4random_uniform(1)
        if random == 0 {
            return .failure(RemoteError(statusCode: 0))
        } else {
            return .success(1)
        }
    }
}
