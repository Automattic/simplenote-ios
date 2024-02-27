import Foundation
import UIKit

// MARK: - UIView: Image Representation Helpers
//
extension UIView {

    /// Returns a UIImage containing a rastrerized version of the receiver.
    ///
    @objc
    func imageRepresentation() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { [unowned self] rendererContext in
            self.layer.render(in: rendererContext.cgContext)
        }
    }

    /// Returns the Image Representation of the receiver, contained within an UIImageView Instance.
    ///
    @objc
    func imageRepresentationWithinImageView() -> UIImageView {
        let output = UIImageView(image: imageRepresentation())
        output.sizeToFit()
        return output
    }
}
