import UIKit
import SimplenoteFoundation

// MARK: - NoteInformationViewController
//
final class NoteInformationViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var screenTitleLabel: UILabel!
    @IBOutlet private weak var dismissButton: UIButton!

    private var transitioningManager: UIViewControllerTransitioningDelegate?

    private var rows: [NoteInformationController.Row] = []
    private let controller: NoteInformationController

    /// Designated initializer
    ///
    /// - Parameters:
    ///     - controller: NoteInformationController
    ///
    init(controller: NoteInformationController) {
        self.controller = controller
        super.init(nibName: nil, bundle: nil)
    }

    /// Convenience initializer
    ///
    /// - Parameters:
    ///     - note: Note
    ///
    convenience init(note: Note) {
        self.init(controller: NoteInformationController(note: note))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        stopListeningToNotifications()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViews()
        configureAccessibility()

        startListeningToNotifications()
        startListeningForControllerChanges()
    }
}

// MARK: - Controller
private extension NoteInformationViewController {
    func startListeningForControllerChanges() {
        controller.observer = { [weak self] rows in
            self?.update(with: rows)
        }
    }

    func update(with rows: [NoteInformationController.Row]) {
        self.rows = rows
        tableView.reloadData()
    }
}

// MARK: - Configuration
//
private extension NoteInformationViewController {
    func configureViews() {
        configureTableView()
        screenTitleLabel.text = Localization.information

        refreshStyle()
    }

    func configureTableView() {
        tableView.register(Value1TableViewCell.self, forCellReuseIdentifier: Value1TableViewCell.reuseIdentifier)
        tableView.tableFooterView = UIView()
    }

    func configureAccessibility() {
        dismissButton.accessibilityLabel = Localization.dismissAccessibilityLabel
    }
}

// MARK: - Styling
//
private extension NoteInformationViewController {
    func refreshStyle() {
        styleScreenTitleLabel()
        styleDismissButton()
        styleTableView()
    }

    func styleScreenTitleLabel() {
        screenTitleLabel.textColor = .simplenoteNoteHeadlineColor
    }

    func styleDismissButton() {
        dismissButton.layer.masksToBounds = true

        dismissButton.setImage(UIImage.image(name: .cross)?.withRenderingMode(.alwaysTemplate), for: .normal)

        dismissButton.setBackgroundImage(UIColor.simplenoteCardDismissButtonBackgroundColor.dynamicImageRepresentation(), for: .normal)
        dismissButton.setBackgroundImage(UIColor.simplenoteCardDismissButtonHighlightedBackgroundColor.dynamicImageRepresentation(), for: .highlighted)

        dismissButton.tintColor = .simplenoteCardDismissButtonTintColor
    }

    func styleTableView() {
        tableView.separatorColor = .simplenoteDividerColor
    }
}

// MARK: - Handling button events
//
private extension NoteInformationViewController {
    @IBAction func handleTapOnDismissButton() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate
//
extension NoteInformationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


// MARK: - UITableViewDataSource
//
extension NoteInformationViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rows[indexPath.row]

        switch row {
        case .metric(let title, let value):
            let cell = tableView.dequeueReusableCell(ofType: Value1TableViewCell.self, for: indexPath)
            configure(cell: cell, withTitle: title, value: value)
            return cell
        }
    }

    private func configure(cell: Value1TableViewCell, withTitle title: String, value: String?) {
        cell.selectionStyle = .none
        cell.hasClearBackground = true
        cell.title = title
        cell.detailTextLabel?.text = value
    }
}

// MARK: - Notifications
//
private extension NoteInformationViewController {
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

// MARK: - Presentation
//
extension NoteInformationViewController {

    /// Configure view controller to be presented as a card
    ///
    func configureToPresentAsCard() {
        let transitioningManager = SPCardTransitioningManager()
        self.transitioningManager = transitioningManager

        transitioningDelegate = transitioningManager
        modalPresentationStyle = .custom
    }
}

private struct Localization {
    static let information = NSLocalizedString("Information", comment: "Card title showing information about the note (metrics, references)")
    static let dismissAccessibilityLabel = NSLocalizedString("Dismiss Information", comment: "Accessibility label describing a button used to dismiss an information view of the note")
}
