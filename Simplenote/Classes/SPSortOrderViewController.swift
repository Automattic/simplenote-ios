//
//  SPSortOrderViewController.swift
//  Simplenote
//
//  Copyright © 2019 Automattic. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Settings: Sort Order
//
class SPSortOrderViewController: UITableViewController {

    /// Selected SortMode
    ///
    @objc
    var selectedMode: SortMode = .alphabeticallyAscending {
        didSet {
            updateSelectedCell(oldSortMode: oldValue, newSortMode: selectedMode)
            onChange?(selectedMode)
        }
    }

    /// Closure to be executed whenever a new Sort Mode is selected
    ///
    @objc
    var onChange: ((SortMode) -> Void)?

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
        setupTableView()
    }
}

// MARK: - UITableViewDelegate Conformance
//
extension SPSortOrderViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Constants.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SortMode.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SPDefaultTableViewCell.reusableIdentifier) ?? SPDefaultTableViewCell()
        let mode = SortMode.allCases[indexPath.row]

        setupCell(cell, with: mode)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedMode = SortMode.allCases[indexPath.row]

        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Private
//
private extension SPSortOrderViewController {

    func setupNavigationItem() {
        title = NSLocalizedString("Sort Order", comment: "Sort Order for the Notes List")

        if displaysDismissButton {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                                target: self,
                                                                action: #selector(dismissWasPressed))
        }
    }

    func setupTableView() {
        tableView.applySimplenoteGroupedStyle()
    }

    func setupCell(_ cell: UITableViewCell, with mode: SortMode) {
        let selected = mode == selectedMode

        cell.textLabel?.text = mode.description
        cell.accessoryType = selected ? .checkmark : .none
    }

    func updateSelectedCell(oldSortMode: SortMode, newSortMode: SortMode) {
        let oldIndexPath = indexPath(for: oldSortMode)
        let newIndexPath = indexPath(for: newSortMode)

        let oldSelectedCell = tableView.cellForRow(at: oldIndexPath)
        let newSelectedCell = tableView.cellForRow(at: newIndexPath)

        oldSelectedCell?.accessoryType = .none
        newSelectedCell?.accessoryType = .checkmark
    }

    func indexPath(for mode: SortMode) -> IndexPath {
        guard let selectedIndex = SortMode.allCases.firstIndex(of: mode) else {
            fatalError()
        }

        return IndexPath(row: selectedIndex, section: Constants.firstSectionIndex)
    }
}

extension SPSortOrderViewController {

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
