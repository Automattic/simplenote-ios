import Foundation


// MARK: - SF Symbols
//
enum SFSymbol: String {
    case link = "link"
    case squareAndArrowUp = "square.and.arrow.up"
    case trash = "trash"
}


// MARK: - UIImage + SF Symbols
//
@available(iOS 13.0, *)
extension UIImage {

    /// Initializes a UIImage with the specified SF Symbol
    ///
    convenience init?(sfSymbol: SFSymbol) {
        self.init(systemName: sfSymbol.rawValue)
    }
}
