//
//  SPTextView.swift
//  Simplenote
//
//  Created by Charlie Scheer on 12/19/24.
//  Copyright © 2024 Automattic. All rights reserved.
//

extension SPTextView {
    @objc
    func setupTextContainer(with textStorage: SPInteractiveTextStorage) -> NSTextContainer {
        let container = NSTextContainer(size: .zero)
        container.widthTracksTextView = true
        container.heightTracksTextView = true


        if #available(iOS 17.0, *) {
            let textLayoutManager = NSTextLayoutManager()
            let contentStorage = NSTextContentStorage()
            contentStorage.delegate = self
            contentStorage.addTextLayoutManager(textLayoutManager)
            textLayoutManager.textContainer = container

        } else {
            layoutManager.addTextContainer(container)
            textStorage.addLayoutManager(layoutManager)
        }

        return container
    }
}

// MARK: NSTextContentStorageDelegate
//
extension SPTextView: NSTextContentStorageDelegate {
    public func textContentStorage(_ textContentStorage: NSTextContentStorage, textParagraphWith range: NSRange) -> NSTextParagraph? {
        guard let originalText = textContentStorage.textStorage?.attributedSubstring(from: range) as? NSMutableAttributedString else {
            return nil
        }

        let style = textInRangeIsHeader(range) ? headlineStyle : defaultStyle
        originalText.addAttributes(style, range: originalText.fullRange)

        return NSTextParagraph(attributedString: originalText)
    }

    func textInRangeIsHeader(_ range: NSRange) -> Bool {
        range.location == .zero
    }

    // MARK: Styles
    //
    var headlineFont: UIFont {
        UIFont.preferredFont(for: .title1, weight: .bold)
    }

    var defaultFont: UIFont {
        UIFont.preferredFont(forTextStyle: .body)
    }

    var defaultTextColor: UIColor {
        UIColor.simplenoteNoteHeadlineColor
    }

    var lineSpacing: CGFloat {
        defaultFont.lineHeight * Metrics.lineSpacingMultipler
    }

    var defaultStyle: [NSAttributedString.Key: Any] {
        [
            .font: defaultFont,
            .foregroundColor: defaultTextColor,
            .paragraphStyle: NSMutableParagraphStyle(lineSpacing: lineSpacing)
        ]
    }

    var headlineStyle: [NSAttributedString.Key: Any] {
        [
            .font: headlineFont,
            .foregroundColor: defaultTextColor,
        ]
    }
}

// MARK: - Metrics
//
private enum Metrics {
    static let lineSpacingMultiplerPad: CGFloat = 0.40
    static let lineSpacingMultiplerPhone: CGFloat = 0.20

    static var lineSpacingMultipler: CGFloat {
        UIDevice.isPad ? lineSpacingMultiplerPad : lineSpacingMultiplerPhone
    }
}
