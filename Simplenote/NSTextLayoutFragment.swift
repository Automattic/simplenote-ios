//
//  NSTextLayoutFragment.swift
//  Simplenote
//
//  Created by Charlie Scheer on 12/20/24.
//  Copyright © 2024 Automattic. All rights reserved.
//

extension NSTextLayoutFragment {
    @available(iOS 17.0, *)
    func characterIndex(for location: CGPoint) -> Int? {
        guard let lineFragment = textLineFragment(forVerticalOffset: location.y, requiresExactMatch: true) else {
            return nil
        }
        return lineFragment.characterIndex(for: location)
    }
}
