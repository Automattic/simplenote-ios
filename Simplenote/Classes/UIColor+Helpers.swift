import Foundation
import UIKit


// MARK: - UIColor Simplenote's Helpers
//
extension UIColor {

    /// Returns an UIImage representation of the receiver, with the specified size, and Dark Mode support.
    ///
    func dynamicImageRepresentation(size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        guard #available(iOS 13.0, *) else {
            return imageRepresentation(size: size)
        }

        let darkImage = resolvedColor(with: .purelyDarkTraits).imageRepresentation(size: size)
        let lightImage = resolvedColor(with: .purelyLightTraits).imageRepresentation(size: size)

        lightImage.imageAsset?.register(darkImage, with: .purelyDarkTraits)

        return lightImage
    }

    /// Returns a rastrerized image of the specified size, representing the receiver instance.
    ///
    private func imageRepresentation(size: CGSize) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)

        return UIGraphicsImageRenderer(size: size).image { context in
            self.setFill()
            context.fill(rect)
        }
    }
}
