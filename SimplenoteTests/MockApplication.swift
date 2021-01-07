import Foundation
@testable import Simplenote

// MARK: - MockApplication
//
class MockApplication: ApplicationStateProvider {
    var applicationState: UIApplication.State = .active
}
