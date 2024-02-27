import Foundation

// MARK: - NSExtensionContext's Simplenote Methods
//
extension NSExtensionContext {

    /// Returns the AttributedContentText stored in the (first) ExtensionItem
    ///
    var attributedContentText: NSAttributedString? {
        guard let item = inputItems.first as? NSExtensionItem else {
            return nil
        }

        return item.attributedContentText
    }

    /// Returns the Item Providers of the specified Type
    ///
    func itemProviders(ofType type: String) -> [NSItemProvider] {
        guard let item = inputItems.first as? NSExtensionItem, let providers = item.attachments else {
            return []
        }

        return providers.filter { provider in
            return provider.hasItemConformingToTypeIdentifier(type)
        }
    }

    /// Extracts the Note from the current Extension Context
    ///
    func extractNote(from extensionContext: NSExtensionContext, onCompletion: @escaping (Note?) -> Void) {
        guard let extractor = Extractors.extractor(for: extensionContext) else {
            onCompletion(nil)
            return
        }

        extractor.extractNote(from: extensionContext) { note in
            DispatchQueue.main.async {
                onCompletion(note)
            }
        }
    }
}
