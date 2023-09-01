//
//  DiffMatchPatch+Dawn.swift
//  Simplenote
//
//  Created by Jorge Leandro Perez on 01/09/2023.
//  Copyright © 2023 Automattic. All rights reserved.
//

import Foundation


extension DiffMatchPatch {

    func rebase(currentValue: String, otherValue: String, oldValue: String) throws -> String {
        do {
            let thisDiffs       = diff_main(ofOldString: oldValue, andNewString: currentValue)
            let otherDiffs      = diff_main(ofOldString: oldValue, andNewString: otherValue)

            let thisPatches     = patch_make(fromOldString: oldValue, andDiffs: thisDiffs) as? [Any]
            let otherPatches    = patch_make(fromOldString: oldValue, andDiffs: otherDiffs) as? [Any]

            let intermediate    = try sp_patch_apply(otherPatches, to: oldValue)
            let rebased         = try sp_patch_apply(thisPatches, to: intermediate)

            return rebased

        } catch {
            // If the rebase fails, fallback to the Local State
            NSLog("# Rebase Failure!! \(error)")
            return currentValue
        }
    }
}
