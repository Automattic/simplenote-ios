//
//  SimplenoteWidgets.swift
//  Simplenote
//
//  Created by Charlie Scheer on 5/26/21.
//  Copyright © 2021 Automattic. All rights reserved.
//

import SwiftUI
import WidgetKit


@available(iOS 14.0, *)
@main
struct SimplenoteWidgets: WidgetBundle {
    var body: some Widget {
        NewNoteWidget()
    }
}
