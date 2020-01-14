import Foundation
import UIKit


// MARK: - ActivityViewController Simplenote Methods
//
extension UIActivityViewController {

    /// Initializes a UIActivityViewController instance that will be able to export a given Note
    ///
    @objc
    convenience init?(note: Note) {
        guard let content = note.content else {
            return nil
        }

        let print = SPSimpleTextPrintFormatter(text: content)
        let source = SimplenoteActivityItemSource(note: note)

        self.init(activityItems: [print, source], applicationActivities: nil)
    }
}
