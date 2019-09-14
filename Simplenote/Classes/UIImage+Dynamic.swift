import Foundation
import UIKit


// MARK: - Dynamic Images
//
extension UIImage {

    /// Returns the NavigationBar Shadow Image
    ///
    @objc
    class var navigationBarShadowImage: UIImage? {
        return UIColor.color(name: .backgroundColor)?.imageRepresentation()
    }

    /// Returns the SearchBar Background Image
    ///
    class var searchBarBackgroundImage: UIImage? {
        guard let color = UIColor.color(name: .simplenoteGray10) else {
            return nil
        }

        let tintColor = color.withAlphaComponent(SearchBackgroundMetrics.alpha)
        let path = UIBezierPath(roundedRect: SearchBackgroundMetrics.rect, cornerRadius: SearchBackgroundMetrics.radius)
        return path.imageRepresentation(color: tintColor)
    }
}


// MARK: - Constants
//
private enum SearchBackgroundMetrics {
    static let alpha = CGFloat(0.2)
    static let radius = CGFloat(10)
    static let rect = CGRect(x: 0, y: 0, width: 16, height: 36)
}
