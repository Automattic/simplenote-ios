import Foundation
import UIKit

// MARK: - Simplenote Methods
//
extension UIContextualAction {

    /// Initializes a Contextual Action with the specified parameters
    ///
    convenience init(style: UIContextualAction.Style,
                     title: String? = nil,
                     image: UIImage? = nil,
                     backgroundColor: UIColor,
                     handler: @escaping UIContextualAction.Handler) {

        self.init(style: style, title: title, handler: handler)
        self.image = image
        self.backgroundColor = backgroundColor
    }
}
