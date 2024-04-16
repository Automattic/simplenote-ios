import Foundation
import UIKit

// MARK: - Dynamic Images
//
extension UIImage {

    /// Returns the SearchBar Background Image
    ///
    class var searchBarBackgroundImage: UIImage {
        let tintColor = UIColor.simplenoteSearchBarBackgroundColor.withAlphaComponent(SearchBackgroundMetrics.alpha)
        let path = UIBezierPath(roundedRect: SearchBackgroundMetrics.rect, cornerRadius: SearchBackgroundMetrics.radius)
        return path.imageRepresentation(color: tintColor)
    }
}

// MARK: - Constants
//
private enum SearchBackgroundMetrics {
    static let alpha = CGFloat(0.3)
    static let radius = CGFloat(10)
    static let rect = CGRect(x: 0, y: 0, width: 16, height: 36)
}
