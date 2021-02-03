import Foundation

public class PDFLinkActivityItemProvider : UIActivityItemProvider {
    public let targetURL: URL
    public let content: String
    private lazy var documentURL = shareToPDF()
    
    public init(content: String, filename: String) {
        self.targetURL = FileManager.documentsURL.appendingPathComponent(filename)
        self.content = content
        
        super.init(placeholderItem: targetURL)
    }
    
    public override var item: Any {
        documentURL ?? content
    }
    
    private func shareToPDF() -> URL? {
        let data = SimplenotePDFExporter.exportStringToPDFData(content)
        return FileManager.writeDataToDocuments(data: data, to: targetURL)
    }
}
