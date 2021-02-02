import UIKit

extension UIView {
    enum AnchorTarget {
        case bounds
        case safeArea
        case layoutMargins
    }

    func addFillingSubview(_ view: UIView,
                           edgeInsets: UIEdgeInsets = .zero,
                           target: AnchorTarget = .bounds) {
        addSubview(view)
        pinSubviewToAllEdges(view, edgeInsets: edgeInsets, target: target)
    }


    func pinSubviewToAllEdges(_ view: UIView, edgeInsets: UIEdgeInsets = .zero, target: AnchorTarget = .bounds) {
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

        let constraints = [
            view.leadingAnchor.constraint(equalTo: layoutGuide?.leadingAnchor ?? leadingAnchor, constant: edgeInsets.left),
            view.trailingAnchor.constraint(equalTo: layoutGuide?.trailingAnchor ?? trailingAnchor, constant: -edgeInsets.right),
            view.topAnchor.constraint(equalTo: layoutGuide?.topAnchor ?? topAnchor, constant: edgeInsets.top),
            view.bottomAnchor.constraint(equalTo: layoutGuide?.bottomAnchor ?? bottomAnchor, constant: -edgeInsets.bottom)
        ]

        NSLayoutConstraint.activate(constraints)
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
