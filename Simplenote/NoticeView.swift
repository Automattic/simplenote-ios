import UIKit

protocol NoticePresentingDelegate {
    func noticeTouchBegan()
    func noticeTouchEnded()
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
        let nib = UINib(nibName: "NoticeView", bundle: nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            fatalError("Could not load notice from nib")
        }
        setupViewConstraints(view)
        setupLongPress()
        view.backgroundColor = .clear

        setupViewStyles()

        view.layoutIfNeeded()
    }

    private func setupViewConstraints(_ view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            view.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            view.leadingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor),
            view.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor)
        ])
    }

    private func setupLongPress() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(viewWasLongPressed(_:)))
        addGestureRecognizer(longPressGesture)
    }

    private func setupViewStyles() {
        stackView.layer.cornerRadius = 25
        stackView.clipsToBounds = true
        stackView.backgroundColor = .lightGray

        noticeButton.isHidden = true
    }

    // MARK: Action
    //
    @IBAction func noticeButtonWasTapped(_ sender: Any) {
        action?()
    }
}

// NOTE: tap recognizing has not been connected to anything yet
// Currently just prints taps.
extension NoticeView {

    // MARK: Tap Gesture Recognizer
    //
    @objc private func viewWasLongPressed(_ gesture: UIGestureRecognizer) {
        switch gesture.state {
        case .began:
            tapBegan()
        case .ended:
            tapEnded()
        default:
            return
        }
    }

    private func tapBegan() {
        print("long press began")
        delegate?.noticeTouchBegan()
    }

    private func tapEnded() {
        print("long press finished")
        delegate?.noticeTouchEnded()
    }
}
