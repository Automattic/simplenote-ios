//
//  Playground.swift
//  SimplenoteUITests
//
//  Created by Sergiy Fedosov on 03.02.2021.
//  Copyright © 2021 Automattic. All rights reserved.
//

import XCTest

/*
 override func setUpWithError() throws {
     app.launchArguments = ["enable-testing"]
     continueAfterFailure = true

     app.launch()
     let _ = attemptLogOut()
     EmailLogin.open()
     EmailLogin.logIn(email: testDataExistingEmail, password: testDataExistingPassword)

     AllNotes.waitForLoad()
     AllNotes.clearAllNotes()
     Trash.empty()
     AllNotes.open()
 }
*/

/*
let switchesNum = app.descendants(matching: .switch).count
for index in 0...switchesNum - 1 {

    let box = app.descendants(matching: .switch).element(boundBy: index)

    print("========================================")
    print("ID:" + box.identifier)
    print("HITTABLE:" + String(box.isHittable))
    print("ENABLED:" + String(box.isEnabled))
    print("EXISTS:" + String(box.exists))
    print("TITLE:" + box.title)
    print("label:" + box.label)
    print("description:" + box.description)

    print(box.frame.height)
    print(box.frame.width)
    print(box.frame.minX)
    print(box.frame.minY)
}
*/

/*
let allElsCount = app.descendants(matching: .any).count

for index in 0...allElsCount - 1
{
    let el = app.descendants(matching: .any).element(boundBy: index)
    print(el.description)
    print(el.label)
}
*/
