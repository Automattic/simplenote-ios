//
//  SwiftUIView.swift
//  Simplenote
//
//  Created by Charlie Scheer on 5/26/21.
//  Copyright © 2021 Automattic. All rights reserved.
//

import SwiftUI
import WidgetKit

@available(iOS 14.0, *)
struct NewNoteWidgetView: View {
    let entry: NewNoteWidgetEntry

    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                HStack {
                    Image("icon_new_note")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .foregroundColor(.white)
                        .frame(width: 48, height: 48, alignment: .center)
                    Spacer()
                }
                Spacer()
                Text("New Note")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            .padding(16)
        }
        .background(Color(red: 0.2, green: 0.38, blue: 0.8))
        .widgetURL(URL(string: "simplenote://new"))
    }
}

@available(iOS 14.0, *)
struct NewNoteWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "NewNoteWidget", provider: NewNoteTimelineProvider()) { entry in
            NewNoteWidgetView(entry: entry)
        }
        .configurationDisplayName("New Note Widges")
        .description("description")
        .supportedFamilies([.systemSmall])

    }
}

@available(iOS 14.0, *)
struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        NewNoteWidgetView(entry: NewNoteWidgetEntry(date: Date(), title: "Title"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
