import UIKit

@objc
final class SearchMapView: UIView {
    private var barViews: [UIView] = []

    var onSelectionChange: ((Int) -> Void)?
    private var lastSelectedIndex: Int? {
        didSet {
            guard oldValue != lastSelectedIndex, let index = lastSelectedIndex else {
                return
            }
            onSelectionChange?(index)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        addGestureRecognizer(panGestureRecognizer)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        addGestureRecognizer(tapGestureRecognizer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with positions: [CGFloat]) {
        for barView in barViews {
            barView.removeFromSuperview()
        }
        barViews = []

        for position in positions {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = UIColor.simplenoteBlue50Color

            addSubview(view)

            let verticalCenterConstraint = NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: position * 2, constant: 0.0)
            verticalCenterConstraint.priority = .defaultHigh

            NSLayoutConstraint.activate([
                view.heightAnchor.constraint(equalToConstant: 4),
                view.leadingAnchor.constraint(equalTo: leadingAnchor),
                view.trailingAnchor.constraint(equalTo: trailingAnchor),
                view.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
                view.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
                verticalCenterConstraint
            ])

            barViews.append(view)
        }
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        barViewIndex(withPoint: point) == nil ? nil : self
    }

    private func barViewIndex(withPoint point: CGPoint) -> Int? {
        return barViews.firstIndex {
            $0.frame.insetBy(dx: -5, dy: -5).contains(point)
        }
    }

    @objc
    private func handleGesture(_ gestureRecognizer: UIGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began, .changed, .ended:
            let location = gestureRecognizer.location(in: self)
            lastSelectedIndex = barViewIndex(withPoint: location)

            if gestureRecognizer.state == .ended {
                lastSelectedIndex = nil
            }
        default:
            lastSelectedIndex = nil
        }
    }
}
