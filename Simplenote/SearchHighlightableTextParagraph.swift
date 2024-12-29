import Foundation

class SearchHighlightableTextParagraph: NSTextParagraph {

    init(attributedString: NSAttributedString, searchText: String?) {
        guard let searchText,
            attributedString.string.contains(searchText),
            let mutableString = attributedString.mutableCopy() as? NSMutableAttributedString else {
            super.init(attributedString: attributedString)
            return
        }

        let range = attributedString.string.nsString.range(of: searchText)
        mutableString.addAttributes([
            .backgroundColor: UIColor.simplenoteEditorSearchHighlightSelectedColor,
            .foregroundColor: UIColor.simplenoteEditorSearchHighlightTextColor
        ], range: range)


        super.init(attributedString: mutableString)
    }
}
