//
//  SimplenoteSimpleTextPrintFormatter.swift
//  Simplenote
//
//  Created by Charlie Scheer on 1/10/20.
//  Copyright © 2020 Automattic. All rights reserved.
//

import UIKit

class SPSimpleTextPrintFormatter: UISimpleTextPrintFormatter {
    override init(text: String) {
        super.init(text: text)
        
        if #available(iOS 12.0, *) {
            if SPUserInterface.isDark {
                self.color = UIColor.black
            }
        }
    }
}
