import Foundation

struct SimplenotePDFExporter {
    public static func exportStringToPDFData(_ string: String) -> Data {
        let format = UIGraphicsPDFRendererFormat()
        
        let renderer = UIGraphicsPDFRenderer(bounds: Constants.pageBounds, format: format)
        
        let data = renderer.pdfData { (context) in
            context.beginPage()
            let attributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)
            ]
            string.draw(at: .zero, withAttributes: attributes)
        }
        
        return data
    }
}

private struct Constants {
    static let pageWidth = 8.5 * 72.0
    static let pageHeight = 8.5 * 72.0
    static let pageBounds = CGRect(x: 0, y: 0, width: Constants.pageWidth, height: Constants.pageHeight)
}
