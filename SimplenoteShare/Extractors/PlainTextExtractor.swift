import Foundation
import MobileCoreServices
import UniformTypeIdentifiers

// MARK: - PlainTextExtractor
//
struct PlainTextExtractor: Extractor {

    /// Accepted File Extension
    ///
    let acceptedType = UTType.plainText.identifier

    /// Indicates if a given Extension Context can be handled by the Extractor
    ///
    func canHandle(context: NSExtensionContext) -> Bool {
        return context.itemProviders(ofType: acceptedType).isEmpty == false
    }

    /// Extracts a Note entity contained within a given Extension Context (If possible!)
    ///
    func extractNote(from context: NSExtensionContext, onCompletion: @escaping (Note?) -> Void) {
        guard let provider = context.itemProviders(ofType: acceptedType).first else {
            onCompletion(nil)
            return
        }

        provider.loadItem(forTypeIdentifier: acceptedType, options: nil) { (payload, _) in
            guard let content = payload as? String else {
                onCompletion(nil)
                return
            }

            let note = Note(content: content)
            onCompletion(note)
        }
    }
}
