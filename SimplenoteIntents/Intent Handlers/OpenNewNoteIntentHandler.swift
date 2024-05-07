//
//  OpenNewNoteIntentHandler.swift
//  Simplenote
//
//  Created by Charlie Scheer on 5/2/24.
//  Copyright © 2024 Automattic. All rights reserved.
//

import Intents

class OpenNewNoteIntentHandler: NSObject, OpenNewNoteIntentHandling {
    func handle(intent: OpenNewNoteIntent) async -> OpenNewNoteIntentResponse {
        OpenNewNoteIntentResponse(code: .continueInApp, userActivity: nil)
    }
}
