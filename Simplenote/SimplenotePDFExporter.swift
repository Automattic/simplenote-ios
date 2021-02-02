import Foundation

class SimplenotePDFExporter {
    func exportNoteToFiles(note: Note, filename: String) -> URL? {
        let data = createPDFDataFromNote(note: note)
        return writeNoteToDocuments(data: data, filename: filename)
    }
    
    private func writeNoteToDocuments(data: Data, filename: String) -> URL? {
        let targetURL = FileManager.documentsURL.appendingPathComponent(filename)
        do {
            try data.write(to: targetURL)
        } catch {
            NSLog("Note Exporter Failure: \(error)")
            return nil
        }
        return targetURL
    }
    
    private func createPDFDataFromNote(note: Note) -> Data {
        let format = UIGraphicsPDFRendererFormat()
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { (context) in
          context.beginPage()
          let attributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)
          ]
            if let text = note.content {
                text.draw(at: CGPoint(x: 0, y: 0), withAttributes: attributes)
            }
        }
        return data
    }
}
