import Foundation


// MARK: - UIActivityItem With Special Treatment for WordPress iOS
//
class SimplenoteActivityItemSource: NSObject, UIActivityItemSource {

    /// The Note that's about to be exported
    ///
    private let content: String
    private let targetURL: URL

    /// Designated Initializer
    ///
    init(content: String, filename: String) {
        self.content = content
        self.targetURL = FileManager.documentsURL.appendingPathComponent(filename)
        super.init()
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return content
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        guard activityType?.isWordPressActivity == true else {
            return content
        }

        return FileManager.writeStringToDocuments(string: content, to: targetURL) ?? content
    }
}
