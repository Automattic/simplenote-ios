import Foundation

struct SimplenotePDFExporter {
    static func exportStringToPDFData(_ string: String) -> Data {
        let currentText = NSAttributedString(string: string)
        let pdfData = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(pdfData, CGRect.zero, nil)
        
        let framesetter = CTFramesetterCreateWithAttributedString(currentText)
        
        var currentRange = CFRangeMake(0, 0);
        var currentPage = 0;
        var done = false;
        
        repeat {
            // Mark the beginning of a new page.
            UIGraphicsBeginPDFPageWithInfo(CGRect(x: 0, y: 0, width: 612, height: 792), nil);
            
            // Draw a page number at the bottom of each page.
            currentPage += 1;
            
            // Render the current page and update the current range to
            // point to the beginning of the next page.
            renderPagewithTextRange(currentRange: &currentRange, framesetter: framesetter)
            
            // If we're at the end of the text, exit the loop.
            if (currentRange.location == CFAttributedStringGetLength(currentText)){
                done = true;
            }
        } while (!done);
        
        // Close the PDF context and write the contents out.
        UIGraphicsEndPDFContext();
        
        let data = Data(pdfData)
        return data
    }
    
    static func renderPagewithTextRange (currentRange: inout CFRange,  framesetter: CTFramesetter) {
        // Get the graphics context.
        if let currentContext = UIGraphicsGetCurrentContext(){
            
            // Put the text matrix into a known state. This ensures
            // that no old scaling factors are left in place.
            currentContext.textMatrix = CGAffineTransform.identity;
            
            // Create a path object to enclose the text. Use 72 point
            // margins all around the text.
            let frameRect = CGRect(x: 72, y: 72, width: 468, height: 648);
            let framePath = CGMutablePath();
            framePath.addRect(frameRect)
            
            // Get the frame that will do the rendering.
            // The currentRange variable specifies only the starting point. The framesetter
            // lays out as much text as will fit into the frame.
            let frameRef = CTFramesetterCreateFrame(framesetter, currentRange, framePath, nil);
            
            // Core Text draws from the bottom-left corner up, so flip
            // the current transform prior to drawing.
            currentContext.translateBy(x: 0, y: 792);
            currentContext.scaleBy(x: 1.0, y: -1.0);
            
            // Draw the frame.
            CTFrameDraw(frameRef, currentContext);
            
            // Update the current range based on what was drawn.
            currentRange = CTFrameGetVisibleStringRange(frameRef);
            currentRange.location += currentRange.length;
            currentRange.length = 0;
        }
    }
}

private struct Constants {
    static let pageWidth = 8.5 * 72.0
    static let pageHeight = 11 * 72.0
    static let pageBounds = CGRect(x: 0, y: 0, width: Constants.pageWidth, height: Constants.pageHeight)
    static let textBounds = CGRect(x: 30, y: 30, width: Constants.pageWidth - 60, height: Constants.pageHeight - 60)
    static let pdfFontSize = CGFloat(16)
}
