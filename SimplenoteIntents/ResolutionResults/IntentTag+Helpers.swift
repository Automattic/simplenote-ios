//
//  IntentTag+Helpers.swift
//  SimplenoteIntents
//
//  Created by Charlie Scheer on 5/9/24.
//  Copyright © 2024 Automattic. All rights reserved.
//

import Intents

extension IntentTag {
    static func allTags(in coreDataWrapper: ExtensionCoreDataWrapper) throws -> [IntentTag] {
        guard let tags = coreDataWrapper.resultsController()?.tags() else {
            throw IntentsError.couldNotFetchTags
        }

        return tags.map({ IntentTag(identifier: $0.simperiumKey, display: $0.name ?? String()) })
    }
}
