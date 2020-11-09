//
//  Snackbar.swift
//  Simplenote
//
//  Created by Kevin LaCoste on 2020-11-09.
//  Copyright © 2020 Automattic. All rights reserved.
//

import Foundation

class Snackbar {
	
	var message: String
	
	static var presenter = SnackbarPresenter()
	
	init(message: String = "Test message") {
		self.message = message
	}
	
	deinit {
		print("Snackbar deinit")
	}
	
	func show() {
		print("Displaying snackbar")
		Snackbar.presenter.present(self)
	}
}

class SnackbarPresenter {
	
	var snackbar: Snackbar?
	
	deinit {
		print("SnackbarPresenter deinit")
		// Should never happen
	}
	
	func present(_ sender: Snackbar) {
		guard snackbar == nil else {
			print("Already presenting. Please wait.")
			return
		}
		
		snackbar = sender
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
			print("Hiding snackbar")
			self.snackbar = nil
		}
	}
}
