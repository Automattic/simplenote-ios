//
//  CreateNewNoteWithContentIntentHandler.swift
//  SimplenoteIntents
//
//  Created by Charlie Scheer on 5/8/24.
//  Copyright © 2024 Automattic. All rights reserved.
//

import Intents

class CreateNewNoteWithContentIntentHandler: NSObject, CreateNewNoteIntentHandling {

    func handle(intent: CreateNewNoteIntent) async -> CreateNewNoteIntentResponse {
        CreateNewNoteIntentResponse(code: .failure, userActivity: nil)
    }
}
