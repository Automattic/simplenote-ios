import Foundation

// MARK: - NSMutableParagraphStyle
//
extension NSMutableParagraphStyle {

    convenience init(lineSpacing: CGFloat) {
        self.init()
        self.lineSpacing = lineSpacing
    }
}
