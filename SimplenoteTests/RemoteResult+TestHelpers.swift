import Foundation
@testable import Simplenote

extension Remote {
    static func randomResult() -> Result<Data?, RemoteError> {
        if Bool.random() {
            return .success(nil)
        }

        return .failure(RemoteError.requestError(0, nil))
    }
}
