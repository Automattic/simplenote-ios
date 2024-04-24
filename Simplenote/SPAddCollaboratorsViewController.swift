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
        primaryTableView.translatesAutoresizingMaskIntoConstraints = false
        entryFieldBackground.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            bannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bannerView.topAnchor.constraint(equalTo: view.topAnchor),
            bannerView.bottomAnchor.constraint(equalTo: entryFieldBackground.topAnchor)
        ])

        NSLayoutConstraint.activate([
            entryFieldBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            entryFieldBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            entryFieldBackground.heightAnchor.constraint(equalToConstant: 44)
        ])

        NSLayoutConstraint.activate([
            primaryTableView.topAnchor.constraint(equalTo: entryFieldBackground.bottomAnchor),
            primaryTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            primaryTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            primaryTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        bannerView.refreshInterface(with: .collaborationRetirement)

    }
}
