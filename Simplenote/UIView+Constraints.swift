import UIKit

extension UIView {
    func addFillingSubview(_ view: UIView,
                           edgeInsets: UIEdgeInsets = .zero,
                           useSafeArea: Bool = false) {

        view.translatesAutoresizingMaskIntoConstraints = false

        addSubview(view)
        view.frame = bounds.inset(by: edgeInsets)

        let constraints = [
            view.leadingAnchor.constraint(equalTo: useSafeArea ? safeAreaLayoutGuide.leadingAnchor : leadingAnchor, constant: edgeInsets.left),
            view.trailingAnchor.constraint(equalTo: useSafeArea ? safeAreaLayoutGuide.trailingAnchor : trailingAnchor, constant: -edgeInsets.right),
            view.topAnchor.constraint(equalTo: useSafeArea ? safeAreaLayoutGuide.topAnchor : topAnchor, constant: edgeInsets.top),
            view.bottomAnchor.constraint(equalTo: useSafeArea ? safeAreaLayoutGuide.bottomAnchor : bottomAnchor, constant: -edgeInsets.bottom)
        ]

        NSLayoutConstraint.activate(constraints)
    }
}
