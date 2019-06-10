import Foundation
import MobileCoreServices


// MARK: - URLExtractor
//
struct URLExtractor: Extractor {

    ///
    ///
    let acceptedType = kUTTypeURL as String

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
                guard let url = payload as? URL else {
                    onCompletion(nil)
                    return
                }

                let output = self.handleURL(url: url)
                onCompletion(output)
            }
        }
    }
}


// MARK: - Private
//
private extension URLExtractor {

    func handleURL(url: URL) -> String {
        guard url.isFileURL else {
            return handleExternalLink(url: url)
        }

        guard let `extension` = SupportedFileExtension(rawValue: url.pathExtension) else {
            // Unsupported
            return String()
        }

        switch `extension` {
        case .textbundle:
            return handleTextBundle(url: url)
        case .textpack:
            return handleTextPack(url: url)
        case .text, .txt:
            return handlePlainText(url: url)
        case .markdown, .md:
            return handleMarkdown(url: url)
        }
    }

    func handleTextBundle(url: URL) -> String {
// TODO
        return "TextBundle"
    }

    func handleTextPack(url: URL) -> String {
// TODO
        return "TextPack"
    }

    func handlePlainText(url: URL) -> String {
// TODO
        return "PlainText"
    }

    func handleMarkdown(url: URL) -> String {
// TODO
        return "Markdown"
    }

    func handleExternalLink(url: URL) -> String {
// TODO
        let contentText = ""
        return contentText + "\n\n[" + url.absoluteString + "]"
    }
}


// MARK: - URLExtension
//
private enum SupportedFileExtension: String {
    case textbundle
    case textpack
    case text
    case txt
    case markdown
    case md
}
