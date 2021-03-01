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
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])

        stackView.layer.cornerRadius = 25
        stackView.clipsToBounds = true
        stackView.backgroundColor = .lightGray

        noticeButton.isHidden = true

        let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(viewWasTapped(_:)))
        view.addGestureRecognizer(tapGesture)
    }

    // MARK: Action
    //
    @IBAction func noticeButtonWasTapped(_ sender: Any) {
        action?()
    }
}

extension NoticeView {
    @objc private func viewWasTapped(_ gesture: UIGestureRecognizer) {
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
        delegate?.noticeTouchBegan()
    }

    private func tapEnded() {
        delegate?.noticeTouchEnded()
    }
}
