import Foundation
import UIKit


// MARK: - SPTableViewHeaderFooterView
//
@objc
class SPTableViewHeaderFooterView: UITableViewHeaderFooterView {

    /// Label: Text
    ///
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .footnote)
        return label
    }()

    /// Border: Bottom
    ///
    private lazy var bottomBorderView: UIView = {
        return UIView()
    }()

    /// Border: Bottom Height
    ///
    private var bottomBorderHeightConstraint: NSLayoutConstraint!

    /// Bottom Border's Color
    ///
    var bottomBorderColor: UIColor? {
        get {
            return bottomBorderView.backgroundColor
        }
        set {
            bottomBorderView.backgroundColor = newValue
        }
    }

    /// Bottom Border Height
    ///
    var bottomBorderIsThick: Bool = false {
        didSet {
            refreshBottomBorderHeight()
        }
    }

    /// String to be displayed onscreen
    ///
    var title: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }

    /// Title Color
    ///
    var titleColor: UIColor? {
        get {
            return titleLabel.textColor
        }
        set {
            titleLabel.textColor = newValue
        }
    }

    /// Title Visibility
    ///
    var titleIsHiden: Bool {
        get {
            return titleLabel.isHidden
        }
        set {
            titleLabel.isHidden = newValue
        }
    }

    /// Designated Initializer
    ///
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupSubviews()
        setupLayout()
    }

    /// Requiredd Initializer
    ///
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
        setupLayout()
    }
}


// MARK: - Private methods
//
private extension SPTableViewHeaderFooterView {

    func setupSubviews() {
        contentView.addSubview(bottomBorderView)
        contentView.addSubview(titleLabel)
    }

    func setupLayout() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.titleInsets.top),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: Constants.titleInsets.bottom * -1)
        ])

        bottomBorderView.translatesAutoresizingMaskIntoConstraints = false
        bottomBorderHeightConstraint = bottomBorderView.heightAnchor.constraint(equalToConstant: Constants.borderHeightThin)
        NSLayoutConstraint.activate([
            bottomBorderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomBorderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomBorderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomBorderHeightConstraint,
        ])
    }

    func refreshBottomBorderHeight() {
        bottomBorderHeightConstraint.constant = bottomBorderIsThick ? Constants.borderHeightThick : Constants.borderHeightThin
    }
}


// MARK: - Private Constants
//
private struct Constants {
    static let borderHeightThin = CGFloat(1) / UIScreen.main.scale
    static let borderHeightThick = CGFloat(4)
    static let titleInsets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
}
