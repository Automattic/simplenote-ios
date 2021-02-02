import Foundation

public class PDFLinkActivityItemProvider : UIActivityItemProvider {
    public let targetURL: URL
    public let filename: String
    public let note: Note
    
    public init(note: Note) {
        self.note = note
        self.filename = String(format: "%@.pdf", "Thisisastring")
        self.targetURL = FileManager.documentsURL.appendingPathComponent(filename)
        
        super.init(placeholderItem: targetURL)
    }
    
    public override var item: Any {
        guard activityType?.rawValue != "com.apple.UIKit.activity.RemoteOpenInApplication",
        let url = SimplenotePDFExporter().exportNoteToFiles(note: note, filename: filename) else {
            return note.content as Any
        }
        
        return url
    }
}
