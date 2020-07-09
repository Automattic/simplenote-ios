import Foundation
import Simperium

// MARK: - SPManagedObject extension
//
extension SPManagedObject {

    /// Version as an Int
    ///
    @objc
    var versionInt: Int {
        return Int(version() ?? "1") ?? 1
    }
}
