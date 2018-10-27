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
//	@IBOutlet weak var textHeightConstrain:NSLayoutConstraint!
	
	private var parentLink:TasksView!
	private var footerTextStartSize:CGSize! 		// начальные размеры текстового поля
	private var selfStartSize:CGSize! 				// начальные размеры фона
	private var tableBottomEdge:CGFloat! 			// начальные размеры таблицы
	
	
	
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
		
		addBttn.layer.cornerRadius = addBttn.layer.bounds.size.width / 2
		
		containerView.backgroundColor = #colorLiteral(red: 0.871609158, green: 0.9240212035, blue: 0.9921568627, alpha: 1)
		containerView.layer.shadowOffset = CGSize(width: 0, height: -2)
		containerView.layer.shadowRadius = 4
		containerView.layer.shadowOpacity = 0

		footerTextView.layer.cornerRadius = 10
		// паддинги для текстового поля
		footerTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		footerTextView.delegate = self
	}
	

	
	
	/// клик на кн. "+"
	@IBAction func onAddBttnClick(_ sender: UIButton?) {
		
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
		
		// неработающая регулярка
		//		let regex = try! NSRegularExpression(pattern: "//.|//[|//]|//#|//$", options: [])
		//		let output = regex.stringByReplacingMatches(in: str, options: [], range: NSRange(location: 0, length: str.count), withTemplate: "!")
		//		print("output = \(output)")
		
		// сохраняем базу
//		print("str = \(str)")
		parentLink.addTaskToDB(str)
	}
	
	


	func textViewDidBeginEditing(_ textView: UITextView) {
		footerTextStartSize = footerTextView.frame.size
		selfStartSize = containerView.frame.size
		tableBottomEdge = parentLink.tableView_user.contentInset.bottom
//		parentLink.tableView_user.isScrollEnabled = false
	}
	func textViewDidEndEditing(_ textView: UITextView) {
		containerView.frame.size = selfStartSize
	}
	
	
	// Отслеживаем переход на след. строку при вводе текста
	internal func textViewDidChange(_ textView: UITextView) {

		// высчитываем новый размер высоты
		let size = CGSize(width: footerTextStartSize.width, height: .infinity)
		let estimatedSize = textView.sizeThatFits(size)
//		textView.frame.size.height = estimatedSize.height
		
		let diff = estimatedSize.height - footerTextStartSize.height

		if parentLink.tableView_user.contentInset.bottom != tableBottomEdge + diff {
			// расширяем таблицу
			parentLink.tableView_user.contentInset.bottom = tableBottomEdge + diff
			// расширяем фон футера
			containerView.frame.size.height = selfStartSize.height + diff
		}
		
		print("estimatedHeight = \(estimatedSize.height)   tableBottomEdge = \(tableBottomEdge!)   diff = \(diff)  bottom = \(parentLink.tableView_user.contentInset.bottom)")
		
		
		//		let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
		//		textView.frame.size = CGSize(width: fixedWidth, height: newSize.height)
		
		// способ Вонга
		// let size = CGSize(width: sp, height: .infinity)
		// let estimatedSize = textView.sizeThatFits(size)
		//
		// textView.constraints.forEach {
		//	(constraint) in
		//		if constraint.firstAttribute == .height {
		//			constraint.constant = estimatedSize.height
		//		}
		//	}
	}
		
	

	


	

	
	
	
	
	
	
	
	
}















