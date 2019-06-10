import Foundation
import MobileCoreServices


// MARK: - PlainTextExtractor
//
struct PlainTextExtractor: Extractor {

    ///
    ///
    let acceptedType = kUTTypePlainText as String

    ///
    ///
    func canHandle(context: NSExtensionContext) -> Bool {
        return context.itemProviders(ofType: acceptedType).isEmpty == false
    }

    ///
    ///
    func extract(context: NSExtensionContext, onCompletion: @escaping (String?) -> Void) {
        let providers = context.itemProviders(ofType: acceptedType)

        for provider in providers {
            provider.loadItem(forTypeIdentifier: acceptedType, options: nil) { (payload, _) in
                let text = payload as? String
                onCompletion(text)
            }
        }
    }
}
