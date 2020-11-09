//
//  SnackbarViewController.swift
//  Simplenote
//
//  Created by Kevin LaCoste on 2020-11-09.
//  Copyright © 2020 Automattic. All rights reserved.
//

import UIKit

class SnackbarViewController: UIViewController {
	
	deinit {
		print("VC deinit.")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.layer.cornerRadius = 12
		view.backgroundColor = .yellow
	}
}
