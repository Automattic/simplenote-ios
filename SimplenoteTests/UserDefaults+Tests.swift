import Foundation

// MARK: - UserDefaults Extension Methods
//
extension UserDefaults {

    /// Resets all of the receiver's values
    ///
    func reset() {
        for (key, _) in dictionaryRepresentation() {
            removeObject(forKey: key)
        }

        synchronize()
    }
}
