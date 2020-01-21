import Foundation
import UIKit


// MARK: - Simplenote Methods
//
extension UITableViewRowAction {

    /// Initializes a TableView RowAction with the specified Style + Title + bgColor
    ///
    convenience init(style: UITableViewRowAction.Style,
                     title: String?,
                     backgroundColor: UIColor,
                     handler: @escaping (UITableViewRowAction, IndexPath) -> Void) {

        self.init(style: style, title: title, handler: handler)
        self.backgroundColor = backgroundColor
    }
}
