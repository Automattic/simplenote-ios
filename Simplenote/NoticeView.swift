import UIKit

protocol NoticePresentingDelegate {
    func noticePressBegan()
    func noticePressEnded()
}

class NoticeView: UIView {

    // MARK: Properties
    //
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var noticeLabel: UILabel!
    @IBOutlet weak var noticeButton: UIButton!

    var delegate: NoticePresentingDelegate?
    var action: (() -> Void)? {
        didSet {
            noticeButton.isHidden = action == nil
        }
    }

    // MARK: Initialization
    //
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: View Layout
    //
    private func setupView() {
        let nib = NoticeView.loadNib()
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            fatalError("Could not load notice from nib")
        }
        setupViewConstraints(for: view)
        setupViewStyles(with: view)
        setupLongPress()

        view.layoutIfNeeded()
    }

    private func setupViewConstraints(for view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            view.centerXAnchor.constraint(equalTo: centerXAnchor),
            view.centerYAnchor.constraint(equalTo: centerYAnchor),
            view.leadingAnchor.constraint(lessThanOrEqualTo: leadingAnchor),
            view.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
        ])
    }

    private func setupLongPress() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(viewWasLongPressed(_:)))
        addGestureRecognizer(longPressGesture)
    }

    private func setupViewStyles(with view: UIView) {
        view.backgroundColor = .clear

        stackView.backgroundColor = UIColor(lightColor: .spGray3, darkColor: .darkGray2)
        stackView.layer.cornerRadius = Constants.cornerRadius
        stackView.clipsToBounds = true

        noticeLabel.textColor = UIColor(lightColor: .gray100, darkColor: .white)
        noticeButton.titleLabel?.textColor = UIColor(lightColor: .spBlue50, darkColor: .spBlue30)
        noticeButton.isHidden = true
    }

    // MARK: Action
    //
    @IBAction func noticeButtonWasTapped(_ sender: Any) {
        action?()
    }
}

// NOTE: long press recognizing has not been connected to anything yet
// Currently just prints to log that a press event happened.
extension NoticeView {

    // MARK: Long Press Gesture Recognizer
    //
    @objc private func viewWasLongPressed(_ gesture: UIGestureRecognizer) {
        switch gesture.state {
        case .began:
            longPressBegan()
        case .ended:
            longPressEnded()
        default:
            return
        }
    }

    private func longPressBegan() {
        print("long press began")
        delegate?.noticePressBegan()
    }

    private func longPressEnded() {
        print("long press finished")
        delegate?.noticePressEnded()
    }
}

private struct Constants {
    static let cornerRadius = CGFloat(25)
    static let nibName = "NoticeView"
}
