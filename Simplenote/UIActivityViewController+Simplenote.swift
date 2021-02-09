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
        let shareFilename = note.exportFilename()

        let print = SPSimpleTextPrintFormatter(text: content)
        let source = SimplenoteActivityItemSource(content: content, filename: String(format: "%@.txt", shareFilename))

        self.init(activityItems: [print, source], applicationActivities: nil)
    }
}
