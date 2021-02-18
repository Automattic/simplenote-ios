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

    var maxNumberOfVisibleRows: CGFloat? {
        didSet {
            updateMaxHeightConstraint()
        }
    }

    override var frame: CGRect {
        didSet {
            updateScrollState()
        }
    }

    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
            updateMaxHeightConstraint()
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

    private func updateMaxHeightConstraint() {
        if let numberOfRows = maxNumberOfVisibleRows {
            maxHeightConstraint.constant = height(of: numberOfRows)
        }
    }

    private func height(of numberOfRows: CGFloat) -> CGFloat {
        let totalRows = dataSource?.tableView(self, numberOfRowsInSection: 0) ?? 0
        let lastRow = min(Int(ceil(numberOfRows)), totalRows) - 1

        guard lastRow >= 0 else {
            return 0.0
        }

        let rect = rectForRow(at: IndexPath(row: lastRow, section: 0))

        let fractionalPart = min(numberOfRows, CGFloat(totalRows)).truncatingRemainder(dividingBy: 1)
        if fractionalPart > .leastNormalMagnitude {
            return rect.minY + rect.height * fractionalPart
        }

        return rect.maxY
    }
}
