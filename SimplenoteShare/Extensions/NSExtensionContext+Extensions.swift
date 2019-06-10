import Foundation


// MARK: - NSExtensionContext's Simplenote Methods
//
extension NSExtensionContext {

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
}
