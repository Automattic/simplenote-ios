import UIKit
import SimplenoteFoundation

// MARK: - NoteInformationViewController
//
class NoteInformationViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var screenTitleLabel: UILabel!
    @IBOutlet private weak var dismissButton: UIButton!

    private var transitioningManager: UIViewControllerTransitioningDelegate?

    private let note: Note
    private var rows: [Row] = []

    /// Designated initializer
    ///
    /// - Parameters:
    ///     - note: Note
    ///
    init(note: Note) {
        self.note = note
        super.init(nibName: nil, bundle: nil)
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

        reloadData()
    }
}

// MARK: - Data
private extension NoteInformationViewController {
    func reloadData() {
        rows = metricRows()
        tableView.reloadData()
    }

    func metricRows() -> [Row] {
        let metrics = NoteMetrics(note: note)
        return [
            .metric(title: Localization.modified,
                    value: DateFormatter.dateTimeFormatter.string(from: metrics.modifiedDate)),

            .metric(title: Localization.created,
                    value: DateFormatter.dateTimeFormatter.string(from: metrics.creationDate)),

            .metric(title: Localization.words,
                    value: NumberFormatter.decimalFormatter.string(for: metrics.numberOfWords)),

            .metric(title: Localization.characters,
                    value: NumberFormatter.decimalFormatter.string(for: metrics.numberOfChars))
        ]
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

private enum Row {
    case metric(title: String, value: String?)
}

private struct Localization {
    static let information = NSLocalizedString("Information", comment: "Card title showing information about the note (metrics, references)")
    static let modified = NSLocalizedString("Modified", comment: "Note Modification Date")
    static let created = NSLocalizedString("Created", comment: "Note Creation Date")
    static let words = NSLocalizedString("Words", comment: "Number of words in the note")
    static let characters = NSLocalizedString("Characters", comment: "Number of characters in the note")

    static let dismissAccessibilityLabel = NSLocalizedString("Dismiss Information", comment: "Accessibility label describing a button used to dismiss an information view of the note")
}
