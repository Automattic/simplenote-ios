//
//  ListWidgetIntentHandler.swift
//  Simplenote
//
//  Created by Charlie Scheer on 5/2/24.
//  Copyright © 2024 Automattic. All rights reserved.
//

import Intents

class ListWidgetIntentHandler: NSObject, ListWidgetIntentHandling {
    let coreDataWrapper = WidgetCoreDataWrapper()

    func provideTagOptionsCollection(for intent: ListWidgetIntent, with completion: @escaping (INObjectCollection<WidgetTag>?, Error?) -> Void) {
        guard WidgetDefaults.shared.loggedIn else {
            completion(nil, WidgetError.appConfigurationError)
            return
        }

        guard let tags = coreDataWrapper.resultsController()?.tags() else {
            completion(nil, WidgetError.fetchError)
            return
        }

        // Return collection to intents
        let collection = tagNoteInObjectCollection(from: tags)
        completion(collection, nil)
    }

    private func tagNoteInObjectCollection(from tags: [Tag]) -> INObjectCollection<WidgetTag> {
        var items = [WidgetTag(kind: .allNotes)]

        tags.forEach { tag in
            let tag = WidgetTag(kind: .tag, name: tag.name)
            tag.kind = .tag
            items.append(tag)
        }

        return INObjectCollection(items: items)
    }

    func defaultTag(for intent: ListWidgetIntent) -> WidgetTag? {
        WidgetTag(kind: .allNotes)
    }
}
