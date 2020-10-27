import Foundation
import UIKit


// MARK: - InterlinkViewController
//
class InterlinkViewController: UIViewController {

    /// Layout Constraints
    ///
    private weak var topConstraint: NSLayoutConstraint?
    private weak var heightConstraint: NSLayoutConstraint?

    /// KVO
    ///
    private var kvoOffsetToken: NSKeyValueObservation?

    /// Closure to be executed whenever a Note is selected. The Interlink URL will be passed along.
    ///
    var onInsertInterlink: ((String) -> Void)?


    // MARK: - Overridden Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRootView()
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        guard let superview = parent?.view else {
            return
        }

        setupConstrints(superview: superview)
    }
}


// MARK: - Initialization
//
private extension InterlinkViewController {

    func setupRootView() {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
    }

    func setupConstrints(superview: UIView) {
        let topConstraint = view.topAnchor.constraint(equalTo: superview.topAnchor)
        let heightConstraint = view.heightAnchor.constraint(equalToConstant: Metrics.defaultHeight)

        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            topConstraint,
            heightConstraint
        ])

        self.topConstraint = topConstraint
        self.heightConstraint = heightConstraint
    }
}


// MARK: - Public API(s)
//
extension InterlinkViewController {

    func refreshInterlinks(for keyword: String, excluding excludedID: NSManagedObjectID?) -> Bool {
// TODO: Implement Me!
        return true
    }

    /// Relocates the receiver so that it shows up around a given Keyword in a TextView.
    /// - Important: We'll start listening for Content Offset changes, and the UI will be automatically repositioned
    ///
    func anchorView(around keywordRange: Range<String.Index>, in textView: UITextView) {
        refreshConstraints(keywordRange: keywordRange, in: textView)

        kvoOffsetToken = textView.observe(\UITextView.contentOffset) { [weak self] (textView, _) in
            self?.anchorView(around: keywordRange, in: textView)
        }
    }
}


// MARK: - Geometry
//
private extension InterlinkViewController {

    /// Updates the layout constraints so that the receiver shows up **around** the specified Keyword in a given TextView
    ///
    func refreshConstraints(keywordRange: Range<String.Index>, in textView: UITextView) {
        let textRect        = textView.locationInSuperviewForText(in: keywordRange)
        let editingRect     = textView.editingRect()
        let targetHeight    = calculateHeight()
        let targetPositionY = calculateOrigin(for: targetHeight, around: textRect, containerFrame: editingRect)

        topConstraint?.constant = targetPositionY
        heightConstraint?.constant = targetHeight
    }

    /// Returns the expected Origin.Y position for an Autocomplete View with the specified Height, to be displayed around a given
    /// anchor frame, within a given Container Frame.
    ///
    func calculateOrigin(for height: CGFloat, around anchor: CGRect, containerFrame: CGRect) -> CGFloat {
        if anchor.maxY + height < containerFrame.maxY {
            return anchor.maxY
        }

        return anchor.minY - height
    }

    /// Returns the required Height to fit the Autocomplete Suggestions
    ///
    func calculateHeight() -> CGFloat {
// TODO: Depends on the actual results onscreen
        Metrics.defaultHeight
    }
}


// MARK: - Metrics
//
private enum Metrics {
    static let defaultHeight = CGFloat(80)
}



// TODO: Proper BG
//
// TODO: TableView Padding
//        let paddingX        = textView.textContainer.lineFragmentPadding
//        let width           = textView.frame.size.width //- paddingX * 2

