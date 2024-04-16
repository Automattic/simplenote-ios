import Foundation

// MARK: - Extractors: Convenience Struct that manages access to all of the known Extractors.
//
struct Extractors {

    /// All of the known Extractors
    ///
    private static let extractors: [Extractor] = [
        URLExtractor(),
        PlainTextExtractor()
    ]

    /// Returns the Extractor that can handle a given Extension Context (if any)
    ///
    static func extractor(for extensionContext: NSExtensionContext) -> Extractor? {
        return extractors.first {
            $0.canHandle(context: extensionContext)
        }
    }
}
