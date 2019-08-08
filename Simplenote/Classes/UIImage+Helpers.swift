import Foundation


// MARK: - UIImage Helper Methods
//
extension UIImage {

    /// Initializes a UIImage instance with a solid color
    ///
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        color.setFill()

        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else {
            return nil
        }

        self.init(cgImage: cgImage)
    }
}
