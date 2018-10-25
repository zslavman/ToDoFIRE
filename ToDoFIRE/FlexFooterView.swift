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
	@IBOutlet weak var containerView:UIView! // self
	@IBOutlet weak var textHeightConstrain:NSLayoutConstraint!
	
	private var parentLink:TasksView!
	private var storedProperty:CGSize! 		// начальные размеры текстового поля
	private var startHeight:CGFloat = 0 	// начальная высота текстовой строки
	
	
	
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		nibSetup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	convenience init(frame: CGRect, parentLink:TasksView) {
		self.init(frame: frame)
		self.parentLink = parentLink
	}
	
	
	
	
	
	
	private func nibSetup(){
		
		// загружаем XIB
		Bundle.main.loadNibNamed("BottomPanel", owner: self, options: nil)
		addSubview(containerView)
		containerView.frame = self.bounds
		containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		translatesAutoresizingMaskIntoConstraints = true
		
		
		storedProperty = containerView.frame.size
		startHeight = footerTextView.frame.height
		print("storedProperys = \(storedProperty)")
		
		addBttn.layer.cornerRadius = addBttn.layer.bounds.size.width / 2
//		addBttn.layer.contentsScale = 1.5
		
		containerView.backgroundColor = #colorLiteral(red: 0.871609158, green: 0.9240212035, blue: 0.9921568627, alpha: 1)
		containerView.layer.shadowOffset = CGSize(width: 0, height: -2)
		containerView.layer.shadowRadius = 4
		containerView.layer.shadowOpacity = 0

		footerTextView.layer.cornerRadius = 10
		// паддинги для текстового поля
//		footerTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		footerTextView.delegate = self
	}
	

	
	
	/// клик на кн. "+"
	@IBAction func onAddBttnClick(_ sender: UIButton?) {
		
		startHeight = 0
		
		endEditing(true)
		// после этого сработает
		// 1) слушатель заезжания клавы в TasksView, который переключит
		// 2) режим редактирования в .standby + выключит тень этой вьюшки
		
		guard footerTextView.text != "" && footerTextView.text != " " else { return }
		
		var str:String = footerTextView.text!
		
		// запись в БД не должна содержать след. символы:    '.' '#' '$' '[' ']'     RegEx =    /\.|\[|\]|\#|\$/g
		let forbiden = [".", "[", "]", "#", "$"]
		for value in forbiden {
			str = str.replacingOccurrences(of: value, with: "!")
		}
		
		footerTextView.text = ""
		containerView.frame.size = storedProperty
		
		// неработающая регулярка
		//		let regex = try! NSRegularExpression(pattern: "//.|//[|//]|//#|//$", options: [])
		//		let output = regex.stringByReplacingMatches(in: str, options: [], range: NSRange(location: 0, length: str.count), withTemplate: "!")
		//		print("output = \(output)")
		
		// сохраняем базу
		parentLink.addTaskToDB(str)
	}
	
	


	
	
	
	
	// Отслеживаем переход на след. строку при вводе текста
	internal func textViewDidChange(_ textView: UITextView) {

		let fixedWidth = textView.frame.width
		let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
//		textView.frame.size = CGSize(width: fixedWidth, height: newSize.height)
		
//		let newHeight = newSize.height
//		var diff:CGFloat = 0
//
//		if Int(newHeight) != Int(startHeight) {
//			diff = newHeight - startHeight
//			startHeight = newHeight
//
//			// расширяем фон
//			containerView.frame.size.height += diff
//
//			// расширяем занимаемое пространство
//			parentLink.tableView_user.contentInset.bottom += diff
//
//			print("Высота строки = \(textView.frame.size.height)   diff = \(diff)")
//		}
		textHeightConstrain.constant = textView.contentSize.height
		
		print("Width = \(textView.contentSize.width) High = \(textView.contentSize.height)")
	}
	
	
	

	


	

	
	
	
	
	
	
	
	
}















