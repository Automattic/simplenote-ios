import Foundation


// MARK: - Dictionary Helpers
//
extension Dictionary where Key == String {

    /// Returns the String Value for the specified Key, as long as its length is non zero. Otherwise, this will return nil.
    ///
    func nonEmptyString(forKey key: String) -> String? {
        guard let output = self[key] as? String, output.count > 0 else {
            return nil
        }

        return output
    }
}
