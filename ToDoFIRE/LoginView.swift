//
//  LoginView.swift
//  ToDoFIRE
//
//  Created by Zinko Vyacheslav on 17.10.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import Firebase

// для организации скрола нужно в сторибоарде написать что вьюшкой управляет UIScrollView
class LoginView: UIViewController {

	
	@IBOutlet weak var warning_TF: UILabel!
	@IBOutlet weak var email_TF: UITextField!
	@IBOutlet weak var pass_TF: UITextField!
	private let SEGUE_IDENTIFIER = "gotoTasks"
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// слушаем появление клавиатуры
		NotificationCenter.default.addObserver(self, selector: #selector(kbDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
		
		// слушаем пропадание клавиатуры
		NotificationCenter.default.addObserver(self, selector: #selector(kbDidHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
		
		// для анимации
		 warning_TF.alpha = 0
		
		// чтоб не вводить логин и пароль в след. раз, проверяем не изменился ли пользователь
		Auth.auth().addStateDidChangeListener {
			[weak self] (auth, user) in
			if user != nil{
				self?.performSegue(withIdentifier: (self?.SEGUE_IDENTIFIER)!, sender: nil)
			}
		}
	}
	
	
	
	// перед тем как вью отобразится на экране
	override func viewWillAppear(_ animated: Bool) {
		email_TF.text = ""
		pass_TF.text = ""
	}

	
	@objc private func kbDidShow(notification:Notification){
		guard let userInfo = notification.userInfo else { return } // userInfo - словарь
		let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
		
		// увиличиваем размер (по высоте) контента в скролвью
		(self.view as! UIScrollView).contentSize = CGSize(width: self.view.bounds.width, height: self.view.bounds.height + keyboardFrame.size.height)
		// чтоб индикатор скрола не заходил за клавиатуру
		(self.view as! UIScrollView).scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.size.height, right: 0)
	}
	
	
	
	@objc private func kbDidHide(){
		(self.view as! UIScrollView).contentSize = CGSize(width: self.view.bounds.width, height: self.view.bounds.height)
	}
	
	
	
	

	@IBAction func onLoginClick(_ sender: UIButton) {
		guard let email = email_TF.text, let password = pass_TF.text, email != "", password != ""
		else {
			showWarningLabel(str: "Incorrect info")
			return
		}
		
		// логинимся
		Auth.auth().signIn(withEmail: email, password: password) {
			[weak self] (user, error) in
			if error != nil {
				self?.showWarningLabel(str: "Error occured")
				return
			}
			
			if user != nil { // если найден пользователь
				self?.performSegue(withIdentifier: (self?.SEGUE_IDENTIFIER)!, sender: nil)
				return
			}
			// если нет пользователя
			self?.showWarningLabel(str: "User not found")
		}
		
	}
	

	
	private func showWarningLabel(str:String){
		warning_TF.text = str
		UIView.animate(withDuration: 3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.curveEaseInOut], animations: {
			[weak self] in
			self?.warning_TF.alpha = 1
		}) {
			[weak self] (complete) in
			self?.warning_TF.alpha = 0
		}
		
	}
	
	
	
	
	// будем регистрировать пользователя в этой же вьюшке
	@IBAction func onRegisterClick(_ sender: UIButton) {
		
		guard let email = email_TF.text, let password = pass_TF.text, email != "", password != ""
			else {
				showWarningLabel(str: "Incorrect info")
				return
		}
		
		Auth.auth().createUser(withEmail: email, password: password) {
			(user, error) in // "список захвата"
			if error == nil{
				if user != nil {
					// здесь будет пусто, т.к. после регистрации переходить никуда не нужно
					
				}
				else {
					print("пользователь не создан")
				}
			}
			else {
				print(error?.localizedDescription ?? "что-то пошло не так")
			}
		}
		
	}
	
	
	
	
}


































