import UIKit

// MARK: - TagListViewCellDeletionSource - source from where the tag is deleted
//
enum TagListViewCellDeletionSource {
    case menu
    case accessory
}

// MARK: - TagListViewCellDelegate
//
protocol TagListViewCellDelegate: AnyObject {
    func tagListViewCellShouldDeleteTag(_ cell: TagListViewCell, source: TagListViewCellDeletionSource)
    func tagListViewCellShouldRenameTag(_ cell: TagListViewCell)
}

// MARK: - TagListViewCell
//
class TagListViewCell: UITableViewCell {
    @IBOutlet private(set) weak var textField: UITextField!

    @IBOutlet private weak var stackView: UIStackView!

    @IBOutlet private weak var trashButton: UIButton!
    @IBOutlet private weak var trashButtonContainer: UIView!

    /// Delegate
    ///
    weak var delegate: TagListViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        refreshStyle()

        // Don't use textField as an accessibility element.
        // Instead use textField value as a cell accessibility label.
        textField.isAccessibilityElement = false
    }

    override var accessibilityLabel: String? {
        get {
            return textField.text
        }
        set {
            //
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        refreshStyle()
        reset()
    }

    override func willTransition(to state: UITableViewCell.StateMask) {
        super.willTransition(to: state)
        if state.isEmpty {
            textField.resignFirstResponder()
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        let changesBlock = {
            let isHidden = !editing
            guard self.trashButtonContainer.isHidden != isHidden else {
                return
            }
            self.trashButtonContainer.isHidden = isHidden
            self.trashButtonContainer.alpha = isHidden ? UIKitConstants.alpha0_0 : UIKitConstants.alpha1_0
        }

        if animated {
            UIView.animate(withDuration: UIKitConstants.animationShortDuration) {
                changesBlock()
                self.stackView.layoutIfNeeded()
            }
        } else {
            changesBlock()
        }
    }
}

// MARK: - Private
//
private extension TagListViewCell {
    func reset() {
        accessoryType = .none
        textField.delegate = nil
        textField.isEnabled = false
        delegate = nil
    }

    func refreshStyle() {
        refreshCellStyle()
        refreshSelectionStyle()
        refreshComponentsStyle()
    }

    func refreshCellStyle() {
        backgroundColor = .simplenoteBackgroundColor
    }

    func refreshSelectionStyle() {
        let selectedView = UIView()
        selectedView.backgroundColor = .simplenoteLightBlueColor
        selectedBackgroundView = selectedView
    }

    func refreshComponentsStyle() {
        textField.textColor = .simplenoteTextColor
        trashButton.tintColor = .simplenoteTintColor
    }
}

// MARK: - Actions
//
extension TagListViewCell {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return (action == #selector(rename(_:)) || action == #selector(delete(_:))) && !textField.isEditing
    }

    @objc
    override func delete(_ sender: Any?) {
        delegate?.tagListViewCellShouldDeleteTag(self, source: .menu)
    }

    @objc
    private func rename(_ sender: Any?) {
        delegate?.tagListViewCellShouldRenameTag(self)
    }

    @IBAction private func handleTapOnTrashButton() {
        delegate?.tagListViewCellShouldDeleteTag(self, source: .accessory)
    }
}
