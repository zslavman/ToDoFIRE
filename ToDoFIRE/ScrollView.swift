//
//  ScrollView.swift
//  ToDoFIRE
//
//  Created by Zinko Vyacheslav on 19.10.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit



// данный клас переопределяет стандартную вьюшку LoginView.swift
class ScrollView: UIScrollView {

	
	private var point:CGPoint!
	
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
			let position = touch.location(in: self)
			point = position
			print(position)
		}
	}
	
	
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
			let position = touch.location(in: self)
			if position == point {
				endEditing(true)
				point = .zero
			}
		}
	}
	
	
	

}
