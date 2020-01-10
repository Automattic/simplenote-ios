//
//  SimplenoteSimpleTextPrintFormatter.swift
//  Simplenote
//
//  Created by Charlie Scheer on 1/10/20.
//  Copyright © 2020 Automattic. All rights reserved.
//

import UIKit

class SimplenoteSimpleTextPrintFormatter: UISimpleTextPrintFormatter {
    override init(text: String) {
        super.init(text: text)
        
        if #available(iOS 12.0, *) {
            if UIScreen.main.traitCollection.userInterfaceStyle == .dark {
                self.color = UIColor.black
            }
        }
    }
}
