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
        let source = SimplenoteActivityItemSource(content: content, identifier: note.simperiumKey)

        self.init(activityItems: [print, source], applicationActivities: nil)

        // Share to ibooks feature that is added by the SimpleTextPrintFormatter requires a locally generated PDF or the share fails silently
        // After much discussion the decision was to not implement a PDF generator into SN at this time, removing share to books as an option.
        excludedActivityTypes = [
            UIActivity.ActivityType.openInIBooks
        ]
    }
}
