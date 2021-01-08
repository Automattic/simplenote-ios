import Foundation

// MARK: - ApplicationStateProvider
//
protocol ApplicationStateProvider {
    var applicationState: UIApplication.State { get }
}
