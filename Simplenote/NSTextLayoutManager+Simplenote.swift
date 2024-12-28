//
//  NSTextLayoutManager+Simplenote.swift
//  Simplenote
//
//  Created by Charlie Scheer on 12/20/24.
//  Copyright © 2024 Automattic. All rights reserved.
//

extension NSTextLayoutManager {
    @available(iOS 17.0, *)
    func characterIndex(for location: CGPoint) -> Int? {
        guard let lineFragment = textLayoutFragment(for: location) else {
            return nil
        }
        return lineFragment.characterIndex(for: location)
    }
}
