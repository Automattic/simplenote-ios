import Foundation
import MobileCoreServices


// MARK: - Note's Content Extractor
//
struct NoteExtractor {

    ///
    ///
    let extensionContext: NSExtensionContext

    ///
    ///
    private let supportedExtractors: [Extractor] = [
        URLExtractor(),
        PlainTextExtractor()
    ]


    ///
    ///
    func extractContent(onCompletion: @escaping (String?) -> Void) {
        guard let extractor = supportedExtractors.first(where: { $0.canHandle(context: extensionContext) }) else {
            onCompletion(nil)
            return
        }

        extractor.extract(context: extensionContext) { output in
            DispatchQueue.main.async {
                onCompletion(output)
            }
        }
    }
}
