//
//  DiffMatchPatchDawnTests.swift
//  SimplenoteTests
//
//  Created by Jorge Leandro Perez on 01/09/2023.
//  Copyright © 2023 Automattic. All rights reserved.
//

import XCTest
@testable import Simplenote

final class DiffMatchPatchDawnTests: XCTestCase {

    func testRebaseMechanism() throws {
        let revision0 = "Hello"
        let revision1 = "HERE Hello Murph! This is a long text"
        let revision2 = "Hello YOLO!"

        do {
            let dmp = DiffMatchPatch()
            let rebased = try dmp.rebase(currentValue: revision2, otherValue: revision1, oldValue: revision0)
            NSLog("# Output: \(rebased)")
        } catch {
            NSLog("# Error: \(error)")
        }
    }
}
