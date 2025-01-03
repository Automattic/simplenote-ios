import Foundation

class SearchHighlightableTextParagraph: NSTextParagraph {

    init(attributedString: NSAttributedString, searchText: String?, isSelected: Bool) {
        let plainText = attributedString.string.lowercased()
        guard let searchText = searchText?.lowercased(),
              plainText.contains(searchText),
            let mutableString = attributedString.mutableCopy() as? NSMutableAttributedString else {
            super.init(attributedString: attributedString)
            return
        }

        let range = plainText.nsString.range(of: searchText)
        mutableString.addAttributes([
            .backgroundColor: isSelected ?
                UIColor.simplenoteEditorSearchHighlightSelectedColor:
                UIColor.simplenoteEditorSearchHighlightColor,
            .foregroundColor: UIColor.simplenoteEditorSearchHighlightTextColor
        ], range: range)

        super.init(attributedString: mutableString)
    }
}
