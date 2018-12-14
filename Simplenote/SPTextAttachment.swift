//
//  SPTextAttachment.swift
//  Simplenote
//  Used in the note editor to distinguish if a checklist item is ticked or not.
//

import UIKit

@objcMembers class SPTextAttachment: NSTextAttachment {
    var checked = false
    var attachmentColor: UIColor?
    
    @objc public convenience init(color: UIColor) {
        self.init()
        
        attachmentColor = color
    }
    
    var isChecked: Bool {
        get {
            return checked
        }
        set(isChecked) {
            checked = isChecked
            image = UIImage(named: checked ? "icon_task_checked" : "icon_task_unchecked")?.withOverlayColor(attachmentColor)
        }
    }
}
