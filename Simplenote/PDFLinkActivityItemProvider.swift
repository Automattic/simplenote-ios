import Foundation

public class PDFLinkActivityItemProvider : UIActivityItemProvider {
    public let targetURL: URL
    public let content: String
    private lazy var documentURL = shareToPDF()
    
    public init(content: String, filename: String) {
        self.targetURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        self.content = content
        
        super.init(placeholderItem: targetURL)
    }
    
    public override var item: Any {
        documentURL ?? content
    }
    
    private func shareToPDF() -> URL? {
        guard activityType?.rawValue == Consts.remoteOpenInAppActivityType else {
            return nil
        }
        let data = SimplenotePDFExporter.exportStringToPDFData(content)
        return FileManager.writeDataToDocuments(data: data, to: targetURL)
    }
}

private struct Consts {
    static let remoteOpenInAppActivityType = "com.apple.UIKit.activity.RemoteOpenInApplication-ByCopy"
}
