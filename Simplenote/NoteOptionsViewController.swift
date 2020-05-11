import UIKit

class NoteOptionsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        print("Note Options dismissed via Done button.")
        
        dismiss(animated: true) {
            print("Note Options is gone.")
            // Inform delegate if necessary.
        }
    }
}
