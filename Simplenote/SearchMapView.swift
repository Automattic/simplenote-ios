import UIKit

// MARK: - Search map view
//
@objc
final class SearchMapView: UIView {

    /// Callback to be invoked on selection change
    ///
    var onSelectionChange: ((Int) -> Void)?

    private var barViews: [UIView] = []

    private lazy var feedbackGenerator = UISelectionFeedbackGenerator()

    private var lastSelectedIndex: Int? {
        didSet {
            guard oldValue != lastSelectedIndex, let index = lastSelectedIndex else {
                return
            }

            feedbackGenerator.selectionChanged()
            onSelectionChange?(index)
        }
    }

    /// Constructor
    ///
    override init(frame: CGRect) {
        super.init(frame: frame)

        isAccessibilityElement = false
        translatesAutoresizingMaskIntoConstraints = false

        prepareFeedbackGenerator()
        setupGestureRecognizers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Update with positions of bars. Position is from 0.0 to 1.0
    ///
    func update(with positions: [CGFloat]) {
        for barView in barViews {
            barView.removeFromSuperview()
        }
        barViews = []
        for position in positions {
            createBarView(with: position)
        }
    }

    private func createBarView(with position: CGFloat) {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.simplenoteBlue50Color

        addSubview(view)

        let verticalCenterConstraint = NSLayoutConstraint(item: view,
                                                          attribute: .centerY,
                                                          relatedBy: .equal,
                                                          toItem: self,
                                                          attribute: .centerY,
                                                          multiplier: position * 2,
                                                          constant: 0.0)
        verticalCenterConstraint.priority = .defaultHigh

        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: Metrics.barHeight),
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            view.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            verticalCenterConstraint
        ])

        barViews.append(view)
    }
}

// MARK: - Configuration
//
private extension SearchMapView {
    func prepareFeedbackGenerator() {
        feedbackGenerator.prepare()
    }

    func setupGestureRecognizers() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        addGestureRecognizer(panGestureRecognizer)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        addGestureRecognizer(tapGestureRecognizer)
    }
}

// MARK: - Handling Gestures
//
private extension SearchMapView {
    @objc
    func handleGesture(_ gestureRecognizer: UIGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began, .changed, .ended:
            let location = gestureRecognizer.location(in: self)
            guard let selectedView = barView(with: location) else {
                lastSelectedIndex = nil
                return
            }

            lastSelectedIndex = barViews.firstIndex(of: selectedView)

            // reset after a tap
            if gestureRecognizer.state == .ended {
                lastSelectedIndex = nil
            }
        default:
            lastSelectedIndex = nil
        }
    }
}

// MARK: - Hit testing
//
extension SearchMapView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return barView(with: point)
    }

    private func barView(with point: CGPoint) -> UIView? {
        return barViews.filter {
            $0.frame.insetBy(dx: -Metrics.extraHorizontalTouchMargin, dy: -Metrics.extraVerticalTouchMargin).contains(point)
        }.sorted {
            let distance1 = abs($0.frame.midY - point.y)
            let distance2 = abs($1.frame.midY - point.y)
            return distance1 < distance2
        }.first
    }
}

private enum Metrics {
    static let barHeight: CGFloat = 4.0

    static let extraHorizontalTouchMargin: CGFloat = 10
    static let extraVerticalTouchMargin: CGFloat = 10
}
