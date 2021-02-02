import Foundation
import UIKit


// MARK: - ActivityViewController Simplenote Methods
//
extension UIActivityViewController {

    /// Initializes a UIActivityViewController instance that will be able to export a given Note
    ///
    @objc
    convenience init?(note: Note) {
        guard let content = note.content else {
            return nil
        }

        let print = SPSimpleTextPrintFormatter(text: content)
        let source = SimplenoteActivityItemSource(note: note)

        let link = BookLinkActivityItemProvider(note: note)

        self.init(activityItems: [print, source, link], applicationActivities: nil)
    }
}

public class BookLinkActivityItemProvider : UIActivityItemProvider {
    public let targetURL: URL
    public let filename: String
    public let note: Note
    
    public init(note: Note) {
        self.note = note
        self.filename = String(format: "%@.pdf", "newURLString2")
        self.targetURL = FileManager.documentsURL.appendingPathComponent(filename)
        
        super.init(placeholderItem: targetURL)
    }
    
    public override var item: Any {
        if activityType?.rawValue == "com.apple.UIKit.activity.RemoteOpenInApplication-ByCopy" {
            let data = SimplenotePdfExporter().exportSampleData()
            
            do {
                try data?.write(to: targetURL)
            } catch {
                NSLog("Note Exporter Failure: \(error)")
                return note.content as Any
            }
            
            return targetURL
        } else {
            return note.content as Any
        }
    }
}

class SimplenotePdfExporter {
    func exportSampleDataURL() -> URL? {
        let data = createFlyer()
        return writeToDocuments(data: data)
    }
    
    func exportSampleData() -> Data? {
        return createFlyer()
    }
    
    private func writeToDocuments(data: Data) -> URL? {
        let filename = String(format: "%@.pdf", "1234")
        let targetURL = FileManager.documentsURL.appendingPathComponent(filename)
        do {
            try data.write(to: targetURL)
        } catch {
            NSLog("Note Exporter Failure: \(error)")
            return nil
        }
        return targetURL
    }
    private func createFlyer() -> Data {
      // 1
      let pdfMetaData = [
        kCGPDFContextCreator: "Flyer Builder",
        kCGPDFContextAuthor: "raywenderlich.com"
      ]
      let format = UIGraphicsPDFRendererFormat()
      format.documentInfo = pdfMetaData as [String: Any]
      // 2
      let pageWidth = 8.5 * 72.0
      let pageHeight = 11 * 72.0
      let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
      // 3
      let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
      // 4
      let data = renderer.pdfData { (context) in
        // 5
        context.beginPage()
        // 6
        let attributes = [
          NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 72)
        ]
        let text = "five time"
    
        text.draw(at: CGPoint(x: 0, y: 0), withAttributes: attributes)
      }
      return data
    }
}
