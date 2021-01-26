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

// MARK: - Navigation
//
extension UITableView {

    /// Returns first index path from the first non-empty section
    ///
    var firstIndexPath: IndexPath? {
        let indexPath = IndexPath(row: 0, section: 0)
        if numberOfRows(inSection: 0) == 0 {
            return nextIndexPath(after: indexPath)
        }

        return indexPath
    }

    /// Returns index path after currently selected index path
    ///
    var nextIndexPath: IndexPath? {
        guard let indexPath = indexPathForSelectedRow else {
            return nil
        }

        return nextIndexPath(after: indexPath)
    }

    /// Returns index path before currently selected index path
    ///
    var prevIndexPath: IndexPath? {
        guard let indexPath = indexPathForSelectedRow else {
            return nil
        }

        var row = indexPath.row
        var section = indexPath.section

        while true {
            if row == 0 {
                if section == 0 {
                    return nil
                }

                section -= 1
                row = numberOfRows(inSection: section)
            } else {
                return IndexPath(row: row - 1, section: section)
            }
        }
    }

    /// Selects row after currently selected row or first row if no row is currently selected
    ///
    func selectNextRow() {
        guard let indexPath = (indexPathForSelectedRow != nil ? nextIndexPath : firstIndexPath) else {
            return
        }
        deselectSelectedRow()
        selectRow(at: indexPath, animated: false, scrollPosition: .none)
        scrollRectToVisible(rectForRow(at: indexPath), animated: false)
    }

    /// Selects row before currently selected row or first row if no row is currently selected
    ///
    func selectPrevRow() {
        guard let indexPath = prevIndexPath ?? firstIndexPath else {
            return
        }
        deselectSelectedRow()
        selectRow(at: indexPath, animated: false, scrollPosition: .none)
        scrollRectToVisible(rectForRow(at: indexPath), animated: false)
    }

    /// Calls `didSelectRow` for a currently selected row
    ///
    func executeSelection() {
        guard let indexPath = indexPathForSelectedRow else {
            return
        }

        delegate?.tableView?(self, didSelectRowAt: indexPath)
    }

    /// Deselects selected row if any
    ///
    @objc(deselectSelectedRowAnimated:)
    func deselectSelectedRow(animated: Bool = false) {
        guard let indexPath = indexPathForSelectedRow else {
            return
        }

        deselectRow(at: indexPath, animated: animated)
    }
}

// MARK: - Navigation (Private)
//
private extension UITableView {
    func nextIndexPath(after prevIndexPath: IndexPath) -> IndexPath? {
        var row = prevIndexPath.row
        var section = prevIndexPath.section

        while true {
            row += 1

            if row >= numberOfRows(inSection: section) {
                section += 1

                if section >= numberOfSections {
                    return nil
                }

                row = -1
            } else {
                return IndexPath(row: row, section: section)
            }
        }
    }
}
