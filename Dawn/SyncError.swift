//
//  SyncError.swift
//  Simplenote
//
//  Created by Jorge Leandro Perez on 30/08/2023.
//  Copyright © 2023 Automattic. All rights reserved.
//

import Foundation


enum SyncError: Error {
    case undefinedSyncError
    case parsingFailure
    case encodingFailure
}
