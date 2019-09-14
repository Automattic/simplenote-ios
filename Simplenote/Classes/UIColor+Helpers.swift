import Foundation
import UIKit


// MARK: - UIColor Simplenote's Helpers
//
extension UIColor {

    /// Returns an UIImage representation of the receiver, with the specified size.
    ///
    func imageRepresentation(size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)

        return UIGraphicsImageRenderer(size: size).image { context in
            self.setFill()
            context.fill(rect)
        }
    }
}
