class SPFallbackTextContainer: NSTextContainer {
    weak var textView: SPTextView?

    override var layoutManager: NSLayoutManager? {
        didSet {
            // This gets called when falling back to TextKit 1
            guard let layoutManager,
                  let newManagerStorage = layoutManager.textStorage,
                  let textView,
                  textView.interactiveTextStorage.layoutManagers.isEmpty else {
                return
            }

            textView.interactiveTextStorage.addLayoutManager(layoutManager)
            textView.interactiveTextStorage.setAttributedString(newManagerStorage)
            textView.text = newManagerStorage.string
        }
    }
}
