import Foundation

extension NSTextStorage {
    @objc(applyBackgroundColor:toRanges:)
    func applyBackgroundColor(_ color: UIColor?, toRanges wordRanges: [NSValue]?) {
        guard let color = color, let wordRanges = wordRanges else {
            return
        }

        beginEditing()

        let maxLength = (string as NSString).length

        for value in wordRanges {
            let range = value.rangeValue

            if NSMaxRange(range) > maxLength {
                continue
            }

            addAttribute(.backgroundColor, value: color, range: range)
        }

        endEditing()
    }
}
