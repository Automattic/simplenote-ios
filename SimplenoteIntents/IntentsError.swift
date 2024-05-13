//
//  IntentsError.swift
//  SimplenoteIntents
//
//  Created by Charlie Scheer on 5/3/24.
//  Copyright © 2024 Automattic. All rights reserved.
//

import Foundation

enum IntentsError: Error {
    case couldNotFetchNotes
    case couldNotFetchTags

    var title: String {
        switch self {
        case .couldNotFetchNotes:
            return NSLocalizedString("Could not fetch Notes", comment: "Note fetch error title")
        case .couldNotFetchTags:
            return NSLocalizedString("Could not fetch Tags", comment: "Tag fetch error title")
        }
    }

    var message: String {
        switch self {
        case .couldNotFetchNotes:
            return NSLocalizedString("Attempt to fetch notes failed.  Please try again later.", comment: "Data Fetch error message")
        case .couldNotFetchTags:
            return NSLocalizedString("Attempt to fetch tags failed.  Please try again later.", comment: "Data Fetch error message")
        }
    }
}
