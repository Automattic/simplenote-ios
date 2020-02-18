import Foundation


// MARK: - NSWritingDirection
//
extension NSWritingDirection {

    /// Returns the *current* writing direction
    ///
    static var current: NSWritingDirection {
        guard UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft else {
            return .leftToRight
        }

        return .rightToLeft
    }
}
