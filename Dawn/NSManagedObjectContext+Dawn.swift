//
//  NSManagedObjectContext+Dawn.swift
//  Simplenote
//
//  Created by Jorge Leandro Perez on 01/09/2023.
//  Copyright © 2023 Automattic. All rights reserved.
//

import Foundation


extension NSManagedObjectContext {

    func saveIfPossible() {
        perform {
            do {
                try self.save()
            } catch {
                NSLog("# FATAL: \(error)")
            }
        }
    }
}
