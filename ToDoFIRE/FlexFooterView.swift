//
//  FlexFooterView.swift
//  ToDoFIRE
//
//  Created by Zinko Vyacheslav on 24.10.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit

//extension UIView {
//	class func fromNib<T: UIView>() -> T {
//		return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
//	}
//}

class FlexFooterView: UIView, UITextViewDelegate {

	
	@IBOutlet weak var footerTextView: UITextView!
	@IBOutlet weak var addBttn: UIButton!
	@IBOutlet weak var containerView:UIView!
	
	private var parentLink:TasksView!
	
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		nibSetup()
		print("Меня вызвали!")
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	convenience init(frame: CGRect, parentLink:TasksView) {
		self.init(frame: frame)
		self.parentLink = parentLink
		
		
	}
	
	
	
	
	private func nibSetup(){
		
		Bundle.main.loadNibNamed("BottomPanel", owner: self, options: nil)
		addSubview(containerView)
		containerView.frame = self.bounds
		containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		translatesAutoresizingMaskIntoConstraints = true
		
		
		footerTextView.layer.cornerRadius = 10
		addBttn.layer.cornerRadius = 10
		
		containerView.backgroundColor = #colorLiteral(red: 0.9175293899, green: 0.8922236788, blue: 0.9686274529, alpha: 1)
		containerView.layer.shadowOffset = CGSize(width: 0, height: -2)
		containerView.layer.shadowRadius = 4
		containerView.layer.shadowOpacity = 0

		footerTextView.delegate = self
	}
	

	
	
	/// клик на кн. "+"
	@IBAction func onAddBttnClick(_ sender: UIButton) {
		
		endEditing(true)
		
		guard footerTextView.text != "" else { return }
		
		var str:String = footerTextView.text!
		
		// запись в БД не должна содержать след. символы:    '.' '#' '$' '[' ']'     RegEx =    /\.|\[|\]|\#|\$/g
		let forbiden = [".", "[", "]", "#", "$"]
		for value in forbiden {
			str = str.replacingOccurrences(of: value, with: "!")
		}
		
		footerTextView.text = ""
		
		// неработающая регулярка
		//		let regex = try! NSRegularExpression(pattern: "//.|//[|//]|//#|//$", options: [])
		//		let output = regex.stringByReplacingMatches(in: str, options: [], range: NSRange(location: 0, length: str.count), withTemplate: "!")
		//		print("output = \(output)")
		
		
		parentLink.addTaskToDB(str)
		
	}
	


	
	
	// Отслеживаем переход на след. строку при вводе текста
//	internal func textViewDidChange(_ textView: UITextView) {
//
//		//		let fixedWidth = textView.frame.size.width
//		//		textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
//		//		let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
//		//		var newFrame = textView.frame
//		//		newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
//		//		textView.frame = newFrame
//
//		textView.translatesAutoresizingMaskIntoConstraints = true
//		textView.sizeToFit()
//		textView.isScrollEnabled = false
//
//		textView.frame = CGRect(x: 20, y: 5, width: self.frame.size.width - 25, height: textView.frame.size.height)
//
//	}
	
	

	


	

	
	
	
	
	
	
	
	
}















