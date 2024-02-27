import Foundation

// MARK: - Extractor
//
protocol Extractor {

    /// Accepted File Extension
    ///
    var acceptedType: String { get }

    /// Indicates if a given Extension Context can be handled by the Extractor
    ///
    func canHandle(context: NSExtensionContext) -> Bool

    /// Extracts a Note entity contained within a given Extension Context (If possible!)
    ///
    func extractNote(from context: NSExtensionContext, onCompletion: @escaping (Note?) -> Void)
}
