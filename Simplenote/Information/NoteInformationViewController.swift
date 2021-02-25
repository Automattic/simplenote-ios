import UIKit
import SimplenoteFoundation

// MARK: - NoteInformationViewController
//
final class NoteInformationViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var dragBar: SPDragBar!

    private var transitioningManager: UIViewControllerTransitioningDelegate?

    private var sections: [NoteInformationController.Section] = []
    private let controller: NoteInformationController

    private var onDismissCallback: (() -> Void)?

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
        configureNavigation()
        configureDragBar()

        refreshPreferredSize()

        startListeningToNotifications()
        startListeningForControllerChanges()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        refreshPreferredSize()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        additionalSafeAreaInsets = Consts.tableViewSafeAreaInsets
    }
    
    override func accessibilityPerformEscape() -> Bool {
        dismiss(animated: true, completion: nil)
        return true
    }
}

// MARK: - Controller
//
private extension NoteInformationViewController {
    func startListeningForControllerChanges() {
        controller.observer = { [weak self] sections in
            self?.update(with: sections)
        }
    }

    func update(with sections: [NoteInformationController.Section]) {
        self.sections = sections
        tableView.reloadData()

        refreshPreferredSize()
    }
}

// MARK: - Configuration
//
private extension NoteInformationViewController {
    func configureNavigation() {
        title = Localization.document
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: Localization.done,
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(handleTapOnDismissButton))
        
    }

    func configureViews() {
        configureTableView()
        styleTableView()
    }

    func configureTableView() {
        // Otherwise additional safe area insets don't work :/
        tableView.contentInsetAdjustmentBehavior = .always

        tableView.register(Value1TableViewCell.self, forCellReuseIdentifier: Value1TableViewCell.reuseIdentifier)
        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: SubtitleTableViewCell.reuseIdentifier)
        tableView.register(TableHeaderViewCell.self, forCellReuseIdentifier: TableHeaderViewCell.reuseIdentifier)

        // remove separator for last cell if we're in popover
        if popoverPresentationController != nil {
            tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        }
    }

    func refreshPreferredSize() {
        preferredContentSize = tableView.contentSize
    }
    
    private func configureDragBar() {
        dragBar.isHidden = navigationController != nil
        dragBar.accessibilityLabel = Localization.dismissAccessibilityLabel

        if UIAccessibility.isVoiceOverRunning == true {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(informationSheetToBeDismissed))
            dragBar.addGestureRecognizer(gestureRecognizer)
        }
    }
    
    @objc
    func informationSheetToBeDismissed() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Styling
//
private extension NoteInformationViewController {
    func styleTableView() {
        tableView.separatorColor = .simplenoteDividerColor
    }
}

// MARK: - Handling button events
//
private extension NoteInformationViewController {
    @IBAction func handleTapOnDismissButton() {
        dismiss(animated: true, completion: nil)
        onDismissCallback?()
    }
}

// MARK: - UITableViewDelegate
//
extension NoteInformationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let row = sections[indexPath.section].rows[indexPath.row]
        switch row {
        case .reference(let interLink, _, _):
            if let interLink = interLink, let url = URL(string: interLink) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        default:
            break
        }
    }
}


// MARK: - UITableViewDataSource
//
extension NoteInformationViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = sections[indexPath.section].rows[indexPath.row]

        switch row {
        case .metric(let title, let value):
            let cell = tableView.dequeueReusableCell(ofType: Value1TableViewCell.self, for: indexPath)
            configure(cell: cell, withTitle: title, value: value)
            return cell
        case .reference(_, let title, let reference):
            let cell = tableView.dequeueReusableCell(ofType: SubtitleTableViewCell.self, for: indexPath)
            configure(cell: cell, withTitle: title, reference: reference)
            return cell
        case .header(let title):
            let cell = tableView.dequeueReusableCell(ofType: TableHeaderViewCell.self, for: indexPath)
            configure(cell: cell, withTitle: title)
            return cell
        }
    }

    private func configure(cell: Value1TableViewCell, withTitle title: String, value: String?) {
        cell.selectionStyle = .none
        cell.hasClearBackground = true
        cell.title = title
        cell.detailTextLabel?.text = value
    }

    private func configure(cell: SubtitleTableViewCell, withTitle title: String, reference: String) {
        cell.title = title
        cell.value = reference
    }

    private func configure(cell: TableHeaderViewCell, withTitle title: String) {
        cell.title = title
    }

    private func updateSeparator(for cell: UITableViewCell, at indexPath: IndexPath) {
        let row = sections[indexPath.section].rows[indexPath.row]
        
        switch row {
        case .header(_):
            cell.adjustSeparatorWidth(width: .standard)
        default:
            if indexPath.row == sections[indexPath.section].rows.count - 1 {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            } else {
                cell.adjustSeparatorWidth(width: .standard)
            }
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        updateSeparator(for: cell, at: indexPath)
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
        styleTableView()
    }
}

// MARK: - Presentation
//
extension NoteInformationViewController {

    /// Configure view controller to be presented as a card
    ///
    func configureToPresentAsCard(onDismissCallback: (() -> Void)? = nil) {
        self.onDismissCallback = onDismissCallback

        let transitioningManager = SPCardTransitioningManager()
        self.transitioningManager = transitioningManager
        transitioningManager.presentationDelegate = self

        transitioningDelegate = transitioningManager
        modalPresentationStyle = .custom
    }
}

extension NoteInformationViewController: SPCardPresentationControllerDelegate {
    func cardDidDismiss(_ viewController: UIViewController, reason: SPCardDismissalReason) {
        onDismissCallback?()
    }
}

private struct Localization {
    static let done = NSLocalizedString("Done", comment: "Dismisses the Note Information UI")
    static let dismissAccessibilityLabel = NSLocalizedString("Dismiss Information", comment: "Accessibility label describing a button used to dismiss an information view of the note")
    static let document = NSLocalizedString("Document", comment: "Card title showing information about the note (metrics, references)")
}

private struct Consts {
    static let tableViewSafeAreaInsets = UIEdgeInsets(top: 26, left: 0, bottom: 0, right: 0)
}
