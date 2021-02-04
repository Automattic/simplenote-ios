import Foundation

struct SimplenotePDFExporter {
    public static func exportStringToPDFData(_ string: String) -> Data {
        let format = UIGraphicsPDFRendererFormat()
        
        let renderer = UIGraphicsPDFRenderer(bounds: Constants.pageBounds, format: format)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .natural
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        let data = renderer.pdfData { (context) in
            context.beginPage()
            let attributes = [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: Constants.pdfFontSize)
            ]
            
            let attributedText = NSAttributedString(string: string, attributes: attributes)
            attributedText.draw(in: Constants.textBounds)
        }
        
        return data
    }
}

private struct Constants {
    static let pageWidth = 8.5 * 72.0
    static let pageHeight = 11 * 72.0
    static let pageBounds = CGRect(x: 0, y: 0, width: Constants.pageWidth, height: Constants.pageHeight)
    static let textBounds = CGRect(x: 30, y: 30, width: Constants.pageWidth - 60, height: Constants.pageHeight - 60)
    static let pdfFontSize = CGFloat(16)
}
