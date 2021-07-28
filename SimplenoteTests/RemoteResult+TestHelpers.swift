import Foundation
@testable import Simplenote

extension Remote.Result {
    static func random() -> Remote.Result {
        let random = arc4random_uniform(1)
        if random == 0 {
            return .failure(0, nil)
        } else {
            return .success
        }
    }
}
