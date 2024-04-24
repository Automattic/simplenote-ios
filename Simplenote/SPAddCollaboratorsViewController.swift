//
//  SPAddCollaboratorsViewController.swift
//  Simplenote
//
//  Created by Charlie Scheer on 4/24/24.
//  Copyright © 2024 Automattic. All rights reserved.
//

import Foundation
import UIKit

extension SPAddCollaboratorsViewController {
    @objc
    func setupBannerView() {
        let bannerView: BannerView = BannerView.instantiateFromNib()

        bannerView.onPress = {
            print("# Click me")
        }

        view.addSubview(bannerView)

        bannerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bannerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        bannerView.refreshInterface(with: .collaborationRetirement)

    }
}
