import UIKit

extension UIView {
    struct EdgeConstraints {
        let leading: NSLayoutConstraint
        let trailing: NSLayoutConstraint
        let top: NSLayoutConstraint
        let bottom: NSLayoutConstraint

        func update(with edgeInsets: UIEdgeInsets) {
            leading.constant = edgeInsets.left
            trailing.constant = -edgeInsets.right
            top.constant = edgeInsets.top
            bottom.constant = -edgeInsets.bottom
        }

        func activate() {
            NSLayoutConstraint.activate([leading, trailing, top, bottom])
        }
    }

    enum AnchorTarget {
        case bounds
        case safeArea
        case layoutMargins
    }

    @discardableResult
    func addFillingSubview(_ view: UIView,
                           edgeInsets: UIEdgeInsets = .zero,
                           target: AnchorTarget = .bounds) -> EdgeConstraints {

        addSubview(view)
        return pinSubviewToAllEdges(view, edgeInsets: edgeInsets, target: target)
    }

    @discardableResult
    func addFillingSubview(_ view: UIView,
                           atPosition position: Int,
                           edgeInsets: UIEdgeInsets = .zero,
                           target: AnchorTarget = .bounds) -> EdgeConstraints {

        insertSubview(view, at: position)
        return pinSubviewToAllEdges(view, edgeInsets: edgeInsets, target: target)
    }

    @discardableResult
    func pinSubviewToAllEdges(_ view: UIView, edgeInsets: UIEdgeInsets = .zero, target: AnchorTarget = .bounds) -> EdgeConstraints {
        view.translatesAutoresizingMaskIntoConstraints = false

        let layoutGuide: UILayoutGuide?
        switch target {
        case .bounds:
            layoutGuide = nil
        case .layoutMargins:
            layoutGuide = layoutMarginsGuide
        case .safeArea:
            layoutGuide = safeAreaLayoutGuide
        }

        let constraints = EdgeConstraints(leading: view.leadingAnchor.constraint(equalTo: layoutGuide?.leadingAnchor ?? leadingAnchor),
                                          trailing: view.trailingAnchor.constraint(equalTo: layoutGuide?.trailingAnchor ?? trailingAnchor),
                                          top: view.topAnchor.constraint(equalTo: layoutGuide?.topAnchor ?? topAnchor),
                                          bottom: view.bottomAnchor.constraint(equalTo: layoutGuide?.bottomAnchor ?? bottomAnchor))
        constraints.update(with: edgeInsets)
        constraints.activate()

        return constraints
    }

    func pinSubviewToCenter(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false

        let constraints = [
            view.centerXAnchor.constraint(equalTo: centerXAnchor),
            view.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
