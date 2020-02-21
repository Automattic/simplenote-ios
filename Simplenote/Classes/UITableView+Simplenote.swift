import Foundation


// MARK: - UITableView Simplenote Methods
//
extension UITableView {

    /// Applies Simplenote's Style for Grouped TableVIews
    ///
    @objc
    func applySimplenoteGroupedStyle() {
        backgroundColor = .simplenoteTableViewBackgroundColor
        separatorColor = .simplenoteDividerColor
    }

    /// Applies Simplenote's Style for Plain TableVIews
    ///
    @objc
    func applySimplenotePlainStyle() {
        backgroundColor = .simplenoteBackgroundColor
        separatorColor = .simplenoteDividerColor
    }

    /// Scrolls to the top of the TableView
    ///
    @objc(scrollToTopWithAnimation:)
    func scrollToTop(animated: Bool) {
        var newOffset = contentOffset
        newOffset.y = adjustedContentInset.top * -1
        setContentOffset(newOffset, animated: animated)
    }

    /// Returns a cell of a given kind, to be displayed at the specified IndexPath
    ///
    func dequeueReusableCell<T: UITableViewCell>(ofType type: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError()
        }

        return cell
    }

    /// Returns a Header instance of the specified kind
    ///
    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(ofType type: T.Type) -> T? {
        return dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as? T
    }
}
