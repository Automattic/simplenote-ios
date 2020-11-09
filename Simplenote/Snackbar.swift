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
		
		let snackView = prepareView()
		positionView(snackView)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
			print("Hiding snackbar")
			
			snackView.removeFromSuperview()
			self.snackbar = nil
		}
	}
	
	func prepareView() -> UIView {
		
		// Prep a test view for display.
		// Limit to 80% of the host window.
		
		let window = UIApplication.shared.keyWindow!
		let width: CGFloat = window.frame.size.width * 0.8
		let height: CGFloat = 60 // Should come from text size?
		
		let rect = CGRect(x: 0, y: 0, width: width, height: height)
		let view = UIView(frame: rect)
		view.backgroundColor = .lightGray
		view.layer.cornerRadius = rect.height / 2
		
		return view
	}
	
	func positionView(_ view: UIView) {
		
		// Determine where the view goes in the host window.
		
		let window = UIApplication.shared.keyWindow!
		
		window.addSubview(view)
		
		// View center should be window width / 2 and window height - offset - (view height / 2)
		
		let offset: CGFloat = 70 // Magic number alert!
		let viewHeight = view.frame.height
		view.center.x = window.frame.size.width / 2
		view.center.y = window.frame.size.height - offset - (viewHeight / 2.0)
		print(view.center)
		
		// Now push the view down offscreen.
//		view.center.y = view.center.y + offset + (viewHeight / 2.0)
	}
}
