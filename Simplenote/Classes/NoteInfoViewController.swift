//
//  Created by Kevin LaCoste on 2020-05-15.
//  Copyright © 2020 Automattic. All rights reserved.
//

import UIKit

class NoteInfoViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tablewView: UITableView!
    
    @objc var dismissAction: (() -> Void)? = nil
    @objc var note: Note?
    
    var cells = [UITableViewCell]()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTitleLabel()
        setUpTableCells()
        
        tablewView.dataSource = self
    }
    
    // MARK: - Set Up
    
    func setUpTitleLabel() {
        
        titleLabel.text = NSLocalizedString("Information", comment: "Information Sheet label");
    }
    
    func setUpTableCells() {
        
        cells.removeAll()
        
        if let info = localizedNoteInfo() {
            for (label, detail) in info {
                let newCell = UITableViewCell.init(style: .value1, reuseIdentifier: nil)
                newCell.textLabel?.text = label
                newCell.detailTextLabel?.text = detail
                newCell.backgroundColor = .clear
                cells.append(newCell)
            }
        }
    }
    
    // MARK: - Helpers
    
    func localizedNoteInfo() -> [(label: String, detail: String)]? {
        
        guard let note = note else {
            print("No note set for sheet.")
            return nil
        }
        
        // Date Formatter
        let dateFormatter = localizedDateFormatter()
        
        // Created & modified dates
        let creationDate = dateFormatter.string(from: note.creationDate)
        let modifictionDate = dateFormatter.string(from: note.modificationDate)
        
        // Char & word counts
        let s = note.content as NSString
        let wordCount = String(s.wordCount)
        let charCount = String(s.charCount)
        
        let lables = localizedLabels()
        
        var array = [(label: String, detail: String)]()
        
        array.append((label: lables[0], detail: modifictionDate))
        array.append((label: lables[1], detail: creationDate))
        array.append((label: lables[2], detail: wordCount))
        array.append((label: lables[3], detail: charCount))
        
        return array
    }
    
    func localizedLabels() -> [String] {
        
        var array = [String]()
        
        array.append(NSLocalizedString("Modified", comment: "Date Modified label"))
        array.append(NSLocalizedString("Created", comment: "Date Created label"))
        array.append(NSLocalizedString("Words", comment: "Word Countlabel"))
        array.append(NSLocalizedString("Characters", comment: "Character Count label"))
        
        return array
    }
    
    func localizedDateFormatter() -> DateFormatter {
        
        // Localized format string respecting device settings.
        // Could make relative date formatting a Defaults option.
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale.current
        dateFormatter.doesRelativeDateFormatting = true
        
        return dateFormatter
    }
    
    func specDateFormatter() -> DateFormatter {
        
        // Hard-coded format string to match design spec.
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy, HH:mm"
        
        return dateFormatter
    }
    
    // MARK: - Actions
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        
        if dismissAction != nil {
            dismissAction!()
        } else {
            print("No action defined for dismiss button.")
        }
    }
    
    // MARK: - UITableViewDataSource methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return cells.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return cells[indexPath.row]
    }
}
