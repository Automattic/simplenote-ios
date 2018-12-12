//
//  SPTextAttachment.swift
//  Simplenote
//  Used in the note editor to distinguish if a checklist item is ticked or not.
//

import UIKit

@objc class SPTextAttachment: NSTextAttachment {
    
    var checked = false
    
    @objc var isChecked: Bool {
        get {
            return checked
        }
        set(isChecked) {
            checked = isChecked
        }
    }

}
