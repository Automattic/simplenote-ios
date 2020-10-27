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
// TODO: Placeholder: Wire a proper bgColor
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
        let targetHeight = calculateHeight()
        let targetLocation = calculateLocation(keywordRange: keywordRange, textView: textView)

        topConstraint?.constant = targetLocation
        heightConstraint?.constant = targetHeight
    }

    /// Returns the target Origin.Y
    ///
    func calculateLocation(keywordRange: Range<String.Index>, textView: UITextView) -> CGFloat {
        textView.locationInSuperviewForText(in: keywordRange).maxY
    }

    /// Returns the target Height
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
