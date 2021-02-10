import UIKit

// MARK: RoundedCrossButton
//
class RoundedCrossButton: RoundedButton {

    /// Style
    ///
    enum Style {
        case standard
        case blue
        case tagPill
    }

    var style: Style = .standard {
        didSet {
            refreshStyle()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    deinit {
        stopListeningToNotifications()
    }
}

// MARK: - Private
//
private extension RoundedCrossButton {
    func configure() {
        startListeningToNotifications()
        refreshStyle()
    }

    func refreshStyle() {
        setImage(UIImage.image(name: .cross)?.withRenderingMode(.alwaysTemplate), for: .normal)

        switch style {
        case .standard:
            setBackgroundImage(UIColor.simplenoteCardDismissButtonBackgroundColor.dynamicImageRepresentation(), for: .normal)
            setBackgroundImage(UIColor.simplenoteCardDismissButtonHighlightedBackgroundColor.dynamicImageRepresentation(), for: .highlighted)

            tintColor = .simplenoteCardDismissButtonTintColor

        case .blue:
            setBackgroundImage(UIColor.simplenoteBlue30Color.dynamicImageRepresentation(), for: .normal)
            setBackgroundImage(UIColor.simplenoteBlue60Color.dynamicImageRepresentation(), for: .highlighted)

            tintColor = .white

        case .tagPill:
            setBackgroundImage(UIColor.simplenoteTagPillDeleteBackgroundColor.dynamicImageRepresentation(), for: .normal)

            tintColor = .simplenoteTagPillBackgroundColor
        }
    }
}

// MARK: - Notifications
//
private extension RoundedCrossButton {
    func startListeningToNotifications() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(themeDidChange), name: .SPSimplenoteThemeChanged, object: nil)
    }

    func stopListeningToNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    private func themeDidChange() {
        refreshStyle()
    }
}
