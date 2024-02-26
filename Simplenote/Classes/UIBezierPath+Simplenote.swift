import Foundation
import UIKit

// MARK: - UIBezierPath Methods
//
extension UIBezierPath {

    /// Returns an UIImage representation of the receiver.
    ///
    func imageRepresentation(color: UIColor) -> UIImage {
        return UIGraphicsImageRenderer(size: bounds.size).image { [unowned self] context in
            self.addClip()
            color.setFill()
            context.fill(bounds)
        }
    }
}
