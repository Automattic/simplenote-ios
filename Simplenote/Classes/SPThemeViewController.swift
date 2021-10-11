import Foundation
import UIKit


// MARK: - Settings: Theme
//
class SPThemeViewController: UITableViewController {

    private var themes: [Theme] {
        return Theme.allThemes
    }

    /// Selected SortMode
    ///
    @objc
    var selectedTheme: Theme = .light {
        didSet {
            updateSelectedCell(oldSortMode: oldValue, newSortMode: selectedTheme)
            onChange?(selectedTheme)

            // TODO: Nuke this once iOS <13 support has been dropped
            refreshInterfaceStyle()
        }
    }

    /// Closure to be executed whenever a new Sort Mode is selected
    ///
    @objc
    var onChange: ((Theme) -> Void)?

    /// Indicates if an Action button should be attached to the navigationBar
    ///
    var displaysDismissButton = false


    /// Designated Initializer
    ///
    init() {
        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        refreshInterfaceStyle()
    }
}


// MARK: - UITableViewDelegate Conformance
//
extension SPThemeViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Constants.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return themes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SPDefaultTableViewCell.reusableIdentifier) ?? SPDefaultTableViewCell()
        let mode = themes[indexPath.row]

        setupCell(cell, with: mode)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTheme = themes[indexPath.row]

        tableView.deselectRow(at: indexPath, animated: true)
    }
}


// MARK: - Private
//
private extension SPThemeViewController {

    func setupNavigationItem() {
        title = NSLocalizedString("Themes", comment: "Simplenote Themes")

        if displaysDismissButton {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                                target: self,
                                                                action: #selector(dismissWasPressed))
        }
    }

    func setupCell(_ cell: UITableViewCell, with mode: Theme) {
        let selected = mode == selectedTheme

        cell.textLabel?.text = mode.description
        cell.textLabel?.textColor = .simplenoteTextColor
        cell.accessoryType = selected ? .checkmark : .none
        cell.backgroundColor = .simplenoteTableViewCellBackgroundColor
    }

    func refreshInterfaceStyle() {
        tableView.applySimplenoteGroupedStyle()
        tableView.reloadData()
    }

    func updateSelectedCell(oldSortMode: Theme, newSortMode: Theme) {
        let oldIndexPath = indexPath(for: oldSortMode)
        let newIndexPath = indexPath(for: newSortMode)

        let oldSelectedCell = tableView.cellForRow(at: oldIndexPath)
        let newSelectedCell = tableView.cellForRow(at: newIndexPath)

        oldSelectedCell?.accessoryType = .none
        newSelectedCell?.accessoryType = .checkmark
    }

    func indexPath(for mode: Theme) -> IndexPath {
        guard let selectedIndex = themes.firstIndex(of: mode) else {
            fatalError()
        }

        return IndexPath(row: selectedIndex, section: Constants.firstSectionIndex)
    }
}


extension SPThemeViewController {

    @objc
    func dismissWasPressed() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Constants
//
private enum Constants {
    static let numberOfSections = 1
    static let firstSectionIndex = 0
}
