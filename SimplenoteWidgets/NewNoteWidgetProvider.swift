//
//  NewNoteWidgetProvider.swift
//  Simplenote
//
//  Created by Charlie Scheer on 5/26/21.
//  Copyright © 2021 Automattic. All rights reserved.
//

import WidgetKit

struct NewNoteWidgetEntry: TimelineEntry {
    var date: Date
    var title: String
}

struct NewNoteTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> NewNoteWidgetEntry {
        return NewNoteWidgetEntry(date: Date(), title: "Title")
    }

    func getSnapshot(in context: Context, completion: @escaping (NewNoteWidgetEntry) -> Void) {
        let entry = NewNoteWidgetEntry(date: Date(), title: "Title")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NewNoteWidgetEntry>) -> Void) {
        let timeline = Timeline(entries: [NewNoteWidgetEntry(date: Date(), title: "Title")], policy: .never)
        completion(timeline)
    }

    typealias Entry = NewNoteWidgetEntry


}
