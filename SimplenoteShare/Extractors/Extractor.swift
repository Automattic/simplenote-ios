import Foundation


// MARK: - Extractor
//
protocol Extractor {

    ///
    ///
    var acceptedType: String { get }

    ///
    ///
    func canHandle(context: NSExtensionContext) -> Bool

    ///
    ///
    func extract(context: NSExtensionContext, onCompletion: @escaping (String?) -> Void)
}
