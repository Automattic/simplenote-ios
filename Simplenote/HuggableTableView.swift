import UIKit

// MARK: - HuggableTableView
// Table View that wraps it's own content (tries to set it's own height to match the content)
//
class HuggableTableView: UITableView {

    lazy var maxHeightConstraint: NSLayoutConstraint = {
        let constraint = heightAnchor.constraint(lessThanOrEqualToConstant: CGFloat.greatestFiniteMagnitude)
        constraint.priority = UILayoutPriority(rawValue: 999)
        constraint.isActive = true
        return constraint
    }()

    lazy var minHeightConstraint: NSLayoutConstraint = {
        let constraint = heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
        constraint.priority = UILayoutPriority(rawValue: 999)
        constraint.isActive = true
        return constraint
    }()

    override var frame: CGRect {
        didSet {
            updateScrollState()
        }
    }

    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        invalidateIntrinsicContentSize()
    }

    override func invalidateIntrinsicContentSize() {
        super.invalidateIntrinsicContentSize()
        updateScrollState()
    }

    override var intrinsicContentSize: CGSize {
        var size = contentSize
        size.height += safeAreaInsets.top + safeAreaInsets.bottom
        return size
    }

    private func updateScrollState() {
        isScrollEnabled = frame.size.height < intrinsicContentSize.height
    }
}
