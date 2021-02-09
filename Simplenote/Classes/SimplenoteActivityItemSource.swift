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
    init(content: String, identifier: String) {
        self.content = content
        self.targetURL = FileManager.default.temporaryDirectory.appendingPathComponent(identifier + ".txt")
        super.init()
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return content
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        guard activityType?.isWordPressActivity == true else {
            return content
        }

        return writeStringToURL(string: content, to: targetURL) ?? content
    }

    /// Writes a given String to the documents folder
    ///
    private func writeStringToURL(string: String, to targetURL: URL) -> URL? {
        do {
            try string.write(to: targetURL, atomically: true, encoding: .utf8)
        } catch {
            NSLog("Note Exporter Failure: \(error)")
            return nil
        }

        return targetURL
    }
}
