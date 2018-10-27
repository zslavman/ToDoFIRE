//
//  TasksCell.swift
//  ToDoFIRE
//
//  Created by Zinko Vyacheslav on 27.10.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit

class TasksCell: UITableViewCell, UITextViewDelegate {

	
	@IBOutlet weak var text_TF: UITextView!
	@IBOutlet weak var checkBttn: UIButton!
	public var currentTask:Task!
	
	
	
	
	public func setup(){
		text_TF.delegate = self
		
		backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
		text_TF.textColor = #colorLiteral(red: 0.2, green: 0.5607843137, blue: 0.9882352941, alpha: 1)
		selectionStyle = .none
		
		toggleComplete()
		
		text_TF.text = currentTask.title
		textViewDidChange(text_TF)
	}

	
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
	
	

	
	
	internal func textViewDidChange(_ textView: UITextView) {
		
		// способ Вонга
		let size = CGSize(width: text_TF.frame.width, height: .infinity)
		let sizeThatShouldFitTheContent = textView.sizeThatFits(size)
		
		textView.constraints.forEach {
			(constraint) in
			if constraint.firstAttribute == .height {
				constraint.constant = sizeThatShouldFitTheContent.height
				print("sizeThatShouldFitTheContent = \(sizeThatShouldFitTheContent.height)")
			}
		}
		
//		// высчитываем новый размер высоты
//		let size = CGSize(width: footerTextStartSize.width, height: .infinity)
//		let estimatedSize = textView.sizeThatFits(size)
//		//		textView.frame.size.height = estimatedSize.height
//
//		let diff = estimatedSize.height - footerTextStartSize.height
//
//		if parentLink.tableView_user.contentInset.bottom != tableBottomEdge + diff {
//			// расширяем таблицу
//			parentLink.tableView_user.contentInset.bottom = tableBottomEdge + diff
//			// расширяем фон футера
//			containerView.frame.size.height = selfStartSize.height + diff
//		}
	}
	
	
	@IBAction func onCheckClick(_ sender: Any) {
		currentTask.completed = !currentTask.completed
		toggleComplete()
	}
	
	
	
	
	/// установка/снятие галочки
	private func toggleComplete(){
		if currentTask.completed {
			checkBttn.isSelected = true
			checkBttn.alpha = 1
		}
		else {
			checkBttn.isSelected = false
			checkBttn.alpha = 0.15
		}
		
	}
	
	
	
	
	
	
	
	
	
	
	

}




















