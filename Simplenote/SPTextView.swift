//
//  SPTextView.swift
//  Simplenote
//
//  Created by Charlie Scheer on 12/19/24.
//  Copyright © 2024 Automattic. All rights reserved.
//

extension SPTextView {
    /*
     SPInteractiveTextStorage *textStorage = [[SPInteractiveTextStorage alloc] init];
     NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];

     NSTextContainer *container = [[NSTextContainer alloc] initWithSize:CGSizeMake(0, CGFLOAT_MAX)];
     container.widthTracksTextView = YES;
     container.heightTracksTextView = YES;
     [layoutManager addTextContainer:container];
     [textStorage addLayoutManager:layoutManager];
     */

    @objc
    func setupTextContainer(with textStorage: SPInteractiveTextStorage) -> NSTextContainer {
        let container = NSTextContainer(size: .zero)
        container.widthTracksTextView = true
        container.heightTracksTextView = true


        if #available(iOS 16.0, *) {
            let textLayoutManager = NSTextLayoutManager()
            let contentStorage = NSTextContentStorage()
            contentStorage.addTextLayoutManager(textLayoutManager)
            textLayoutManager.textContainer = container

        } else {
            layoutManager.addTextContainer(container)
            textStorage.addLayoutManager(layoutManager)
        }

        return container
    }
}
