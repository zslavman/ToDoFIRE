//
//  LoginView.swift
//  ToDoFIRE
//
//  Created by Zinko Vyacheslav on 17.10.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import Firebase

// для организации скрола нужно в сторибоарде написать что вьюшкой управляет класс UIScrollView
class LoginView: UIViewController {

	
	@IBOutlet weak var warning_TF: UILabel!
	@IBOutlet weak var email_TF: UITextField!
	@IBOutlet weak var pass_TF: UITextField!
	private let SEGUE_IDENTIFIER = "gotoTasks"
	private var ref:DatabaseReference!
	
	@IBOutlet weak var loginBttn: UIButton!
	@IBOutlet weak var registerBttn: UIButton!
	
	private var authListener:AuthStateDidChangeListenerHandle!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		ref = Database.database().reference(withPath: "users")
		
		// слушаем появление клавиатуры
		NotificationCenter.default.addObserver(self, selector: #selector(kbDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
		
		// слушаем пропадание клавиатуры
		NotificationCenter.default.addObserver(self, selector: #selector(kbDidHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
		
		// для анимации
		 warning_TF.alpha = 0
		
		// чтоб не вводить логин и пароль в след. раз, проверяем не изменился ли пользователь
		authListener = Auth.auth().addStateDidChangeListener {
			[weak self] (auth, user) in
			if user != nil{
				self?.performSegue(withIdentifier: (self?.SEGUE_IDENTIFIER)!, sender: nil)
			}
		}
		
		loginBttn.layer.cornerRadius = 7
	}
	
	
	
	
	
	// перед тем как вью отобразится на экране
	override func viewWillAppear(_ animated: Bool) {
		email_TF.text = "z@ukr.net"
		pass_TF.text = "123456"
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
		UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn], animations: {
			(self.view as! UIScrollView).contentSize = CGSize(width: self.view.bounds.width, height: self.view.bounds.height)
		}, completion: nil)
	}
	
	
	
	
	

	@IBAction func onLoginClick(_ sender: UIButton) {
		
		view.endEditing(true) // прячем клавиатуру
		
		guard let email = email_TF.text, let password = pass_TF.text, email != "", password != ""
		else {
			showWarningLabel(str: "Incorrect info")
			return
		}
		
		blockButtons()
		
		// удаляем слушатель автозахода, т.к. при авторизации будет двойной вход
		Auth.auth().removeStateDidChangeListener(authListener)
		
		// логинимся
		Auth.auth().signIn(withEmail: email, password: password) {
			[weak self] (user, error) in
			self?.blockButtons(unblock: true)
			if error != nil {
				let strErr = error!.localizedDescription
				self?.showWarningLabel(str: strErr)
				print(strErr)
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
	
	
	
	
	
	
	// будем регистрировать пользователя в этой же вьюшке
	@IBAction func onRegisterClick(_ sender: UIButton) {
		
		view.endEditing(true)
		
		guard let email = email_TF.text, let password = pass_TF.text, email != "", password != ""
			else {
				showWarningLabel(str: "Incorrect info")
				return
		}
		
		blockButtons()
		
		Auth.auth().removeStateDidChangeListener(authListener)
		
		Auth.auth().createUser(withEmail: email, password: password) {
			[weak self] (authResult, error) in // "список захвата"
			
			self?.blockButtons(unblock: true)
			// продолжаем, только если есть юзер и нет ошибок
			guard let user = authResult?.user, error == nil else {
				let strErr = error!.localizedDescription
				print(strErr)
				self?.showWarningLabel(str: strErr)
				return
			}
			// записываем в юзера его емайл
			let userRef = self?.ref.child(user.uid)
			userRef?.setValue(["email": user.email])
		}
	}
	
	
	
	

	
	/// Показывает ошибку, если что-то пошло не так
	///
	/// - Parameter str: текст ошибки
	private func showWarningLabel(str:String){
		// чистим анимацию если уже запущена
		warning_TF.layer.removeAllAnimations()
		warning_TF.alpha = 0
		
		warning_TF.text = str
		
		let animator = UIViewPropertyAnimator(duration: 0.5, curve: .linear) {
			self.warning_TF.alpha = 1
		}
		animator.startAnimation()
		animator.addCompletion {
			(animPosition) in
			if animPosition == .end {
				// Эта хрень НЕ работает!!!!!
				// animator.isReversed = true
				// animator.startAnimation(afterDelay: 2)
				let rewind = UIViewPropertyAnimator(duration: 0.5, curve: .linear){
					self.warning_TF.alpha = 0
				}
				rewind.startAnimation(afterDelay: 3)
			}
		}
		
		// Эта хрень НЕ работает!!!!!
		// let animator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, options: [.curveEaseInOut, .autoreverse], animations:{
			// self.warning_TF.alpha = 1
			// UIView.setAnimationRepeatAutoreverses(true)
		// })
		
		// У этой хрени нет плавного затухания + ее невозможно остановить!!
//		UIView.animate(withDuration: 3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.curveEaseInOut], animations: {
//			[weak self] in
//			self?.warning_TF.alpha = 1
//		}) {
//			[weak self] (complete) in
//			self?.warning_TF.alpha = 0
//		}
		
	}
	

	
	
	/// Блокировка/разблокировка кнопок Регистрация и Вход
	///
	/// - Parameter unblock: true - разблокировка
	private func blockButtons(unblock:Bool = false){
		
		if unblock{
			loginBttn.isEnabled = true
			loginBttn.alpha = 1
			registerBttn.isEnabled = true
			registerBttn.alpha = 1
		}
		else{
			loginBttn.isEnabled = false
			loginBttn.alpha = 0.5
			registerBttn.isEnabled = false
			registerBttn.alpha = 0.5
		}
	}
	
	
	
}






//extension UIScrollView {
//
//	// способ хранить переменную в расширении
//	private struct AssociatedKeys {
//		static var startTouchPosition:CGPoint = .zero
//	}
//
//	private var point: CGPoint? {
//		get {
//			return objc_getAssociatedObject(self, &AssociatedKeys.startTouchPosition) as? CGPoint
//		}
//		set {
//			if let newValue = newValue {
//				//objc_setAssociatedObject(<#T##object: Any##Any#>, <#T##key: UnsafeRawPointer##UnsafeRawPointer#>, <#T##value: Any?##Any?#>, <#T##policy: objc_AssociationPolicy##objc_AssociationPolicy#>)
//				objc_setAssociatedObject(self, &AssociatedKeys.startTouchPosition, newValue as CGPoint?, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//			}
//		}
//	}
//
//
//
//	override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//		if let touch = touches.first {
//			let position = touch.location(in: self)
//			point = position
//			print(position)
//		}
//	}
//
//
//
//	override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//		if let touch = touches.first {
//			let position = touch.location(in: self)
//			if position == point {
//				endEditing(true)
//				point = .zero
//			}
//		}
//	}
//}



































