import Foundation
import UIKit


extension UIAlertController {

    @discardableResult @objc
    func addCancelActionWithTitle(_ title: String?, handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return addActionWithTitle(title, style: .cancel, handler: handler)
    }

    @discardableResult @objc
    func addDestructiveActionWithTitle(_ title: String?, handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return addActionWithTitle(title, style: .destructive, handler: handler)
    }

    @discardableResult @objc
    func addDefaultActionWithTitle(_ title: String?, handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return addActionWithTitle(title, style: .default, handler: handler)
    }

    @discardableResult @objc
    func addActionWithTitle(_ title: String?, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        let action = UIAlertAction(title: title, style: style, handler: handler)
        addAction(action)

        return action
    }
}
