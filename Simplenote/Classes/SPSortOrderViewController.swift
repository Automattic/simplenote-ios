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
        return Row.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SPDefaultTableViewCell.reusableIdentifier) ?? SPDefaultTableViewCell()
        let row = Row.allCases[indexPath.row]

        setupCell(cell, with: row)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


// MARK: - Private
//
private extension SPSortOrderViewController {

    func setupNavigationItem() {
        title = NSLocalizedString("Sort Order", comment: "Sort Order for the Notes List")
    }

    func setupTableView() {
        tableView.applyDefaultGroupedStyling()
    }
    
    func setupCell(_ cell: UITableViewCell, with row: Row) {
        cell.textLabel?.text = row.description
    }
}


// MARK: - Constants
//
private enum Constants {
    static let numberOfSections = 1
}


// MARK: - SortOrder Rows
//
private enum Row: CaseIterable {
    case modifiedNewest
    case modifiedOldest
    case createdNewest
    case createdOldest
    case alphabeticallyAscending
    case alphabeticallyDescending

    var description: String {
        switch self {
        case .modifiedNewest:
            return NSLocalizedString("Newest modified date", comment: "")
        case .modifiedOldest:
            return NSLocalizedString("Oldest modified date", comment: "")
        case .createdNewest:
            return NSLocalizedString("Newest created date", comment: "")
        case .createdOldest:
            return NSLocalizedString("Oldest created date", comment: "")
        case .alphabeticallyAscending:
            return NSLocalizedString("Alphabetically, A-Z", comment: "")
        case .alphabeticallyDescending:
            return NSLocalizedString("Alphabetically, Z-A", comment: "")
        }
    }
}
