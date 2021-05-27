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


// MARK: - HTML Colors
//
extension UIColor {

    /// Initializes a new UIColor instance with the specified HexString Code.
    ///
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)

        let characters = CharacterSet.init(charactersIn: "#")
        scanner.charactersToBeSkipped = .some(characters)

        var color: UInt64 = 0
        scanner.scanHexInt64(&color)

        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask

        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
}
