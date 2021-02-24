import UIKit

class SPSimpleTextPrintFormatter: UISimpleTextPrintFormatter {
    override init(text: String) {
        super.init(text: text)

        // Check for darkmode
        // If dark mode is enabled change the text color to black before printing
        if SPUserInterface.isDark {
            self.color = .black
        }
    }
}
