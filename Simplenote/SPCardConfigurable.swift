import Foundation

// MARK: - SPCardConfigurable: configure card
//
protocol SPCardConfigurable {
    /// This method allows the adopter to control swipe-to-dismiss
    ///
    /// - Parameters:
    ///     - location: location in receiver's coordinate system.
    ///
    /// - Returns: Boolean value indicating if dismiss should begin
    ///
    func shouldBeginSwipeToDismiss(from location: CGPoint) -> Bool
}
