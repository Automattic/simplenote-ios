import Foundation


// MARK: - SPManagedObject extension
//
extension SPManagedObject {

    /// Version as an Int
    ///
    @objc
    var versionInt: Int {
        guard let versionStr = version(), let version = Int(versionStr) else {
            return 1
        }

        return version
    }
}
