//
//  TasksView.swift
//  ToDoFIRE
//
//  Created by Zinko Vyacheslav on 17.10.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import Firebase

class TasksView: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	
	@IBOutlet weak var tableView_user: UITableView!
	@IBOutlet weak var plusBttn: UIBarButtonItem!
	
	
	
	private var user:UserCustom!
	private var ref:DatabaseReference!
	private var tasks:[Task] = []
	
	enum MODE {
		case editing
		case standby
	}
	
	public var mode:MODE = .standby

	
	
	
    override func viewDidLoad() {
        super.viewDidLoad()

		// проверка на всяк случай что мы залогинены
		guard let currentUser = Auth.auth().currentUser else { return }
		
		// инициализируем юзера, передав в него его личные данные (разложив которые внутри, получим его email и id)
		user = UserCustom(user: currentUser)
		
		// создаем структуру ссылки, куда будем сохранять данные
		ref = Database.database().reference(withPath: "users").child(String(user.uid)).child("tasks")
		//https://todofire-1111e.firebaseio.com/users/2gYjso475GJam57BK4zMW8QOzXtF41/tasks
		
		// слушаем появление и заезжание клавиатуры
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	
	
	
	// по документации Firebase наблюдателей изменения данных в базе нужно ставить именно в этом методе
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		guard let ref = ref else { return }
		
		ref.observe(.value) {
			[weak self] (snapshot) in
			
			var tempTasks:[Task] = []
			
			for item in snapshot.children{
				let task = Task(snapshot: item as! DataSnapshot)
				tempTasks.append(task)
			}
			
			self?.tasks = tempTasks.sorted{$0.order < $1.order}
			self?.tableView_user.reloadData()
		}
	}
	
	
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		ref.removeAllObservers()
	}
	
	@IBAction func onLogoutClick(_ sender: UIBarButtonItem) {
		do {
			try Auth.auth().signOut()
		}
		catch {
			print(error.localizedDescription)
		}
		tableView_user.setEditing(false, animated: false)
		dismiss(animated: true, completion: nil)
	}
	
	
	
	
	@IBAction func onPlusClick(_ sender: UIBarButtonItem) {
		
		if mode == .standby{
			plusBttn.title = "Done"
			mode = .editing
			tableView_user.setEditing(true, animated: true)
		}
		else if mode == .editing{ // когда уже начали редактировать текст в ячейках ИЛИ когда начали редактировать порядок ячеек
			view.endEditing(true)
			plusBttn.title = "Edit"
			mode = .standby
			if tableView_user.isEditing {
				tableView_user.setEditing(false, animated: true)
			}
		}
		
//		let alertController = UIAlertController(title: "New Task", message: "Add new task", preferredStyle: .alert)
//		alertController.addTextField()
//
//		let save = UIAlertAction(title: "Save", style: .default) {
//			[weak self] _ in
//			guard let tf = alertController.textFields?.first, tf.text != "" else { return }
//
//			// создаем адрес задачи
//			let task = Task(title: tf.text!, userID: (self?.user.uid)!)
//
//			// создаем саму задачу
//			let taskRef = self?.ref.child(task.title.lowercased()) // продолжение углубления в структуру данных БД (см. строку 29)
//			// записываем задачу в БД по адресу
//			taskRef?.setValue(task.convertToDict())
//		}
//
//		let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
//
//		alertController.addAction(save)
//		alertController.addAction(cancel)
//
//		present(alertController, animated: true, completion: nil)
	}
	
	
	
	
	

	
	
	
	
	@objc private func keyboardWillShow(notification:Notification){
		// получаем инфу о размере клавиатуры
		if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
			tableView_user.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: keyboardSize.height, right: 0)
		}
		mode = .editing
		plusBttn.title = "Done"
		tableView_user.setEditing(false, animated: true)
	}

	
	@objc private func keyboardWillHide(notification:Notification){
		
		// вычисляем высоту навбара + статусбара, чтоб оставить этот паддинг сверху иначе таблица будет под этими барами
		var upperPadding:CGFloat = UIApplication.shared.statusBarFrame.height
		if let nc = navigationController {
			upperPadding += nc.navigationBar.frame.size.height
		}

		if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
			tableView_user.contentInset = UIEdgeInsets(top: upperPadding, left: 0, bottom: 0, right: 0)
			
		}
	}
	
	
	
	
	
	
	
	

	
	/* ===================================================*/
	/* ============= ДЕЙСТВИЯ С ТАБЛИЦЕЙ =================*/
	/* ===================================================*/
	
	// кол-во рядков
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tasks.count
	}
	
	// создание таблицы
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "my_cell", for: indexPath)
		
		cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
		cell.textLabel?.textColor = #colorLiteral(red: 0.2, green: 0.5607843137, blue: 0.9882352941, alpha: 1)
		cell.selectionStyle = .none
		
		cell.textLabel?.text = tasks[indexPath.row].title
		toggleComplete(cell, isCompleted: tasks[indexPath.row].completed)

		
		// избавляемся от пустых строк
//		tableView.tableFooterView = UIView(frame: CGRect.zero)
		tableView.separatorColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
		
		return cell
	}
    
	
	
	// клик по ячейке
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// получаем ячейку по которой кликнули
		guard let cell = tableView_user.cellForRow(at: indexPath) else {
			return
		}
		
		let task = tasks[indexPath.row]
		let isCompleted = !task.completed
		
		// рисуем галочку
		toggleComplete(cell, isCompleted: isCompleted)
		// передаем изменения в БД Firebase
		task.ref?.updateChildValues(["completed": isCompleted])
	}
	
	
	
	// разрешение на перетаскивание строк таблицы (изменение порядка строк)
//	func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//		return true
//	}
	
	
	// добавляем фунуции к ячейке при свайпе влево
	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		
		// УДАЛЕНИЕ ячейки (удаляем в БД, а в самой таблице удалит слушатель БД)
//		let del = UITableViewRowAction(style: .default, title: "Delete") {
//			(action, indexPath) in
//			let task = self.tasks[indexPath.row]
//			task.ref?.removeValue()
//			action.backgroundColor = .green
//		}
//		del.backgroundColor = #colorLiteral(red: 1, green: 0.5137254902, blue: 0.007843137255, alpha: 1)
		
		
		// кастомная кнопка в ячейке
		//************************************
		
		let cellHeight = tableView.cellForRow(at: indexPath)?.frame.size.height ?? 60
		let bttnSize = CGSize(width: 80, height: cellHeight)
		
		// фон кнопки
		let backView = UIView(frame: CGRect(x: 0, y: 0, width: bttnSize.width, height: bttnSize.height))
		backView.backgroundColor = .clear
		
		// картинка кнопки
		let imSize = CGSize(width: 14, height: 16)
		let myImage = UIImageView(frame: CGRect(origin: CGPoint(x: backView.frame.midX - imSize.width/2, y: backView.frame.midY - imSize.height/2 + 5), size: imSize))
		myImage.image = #imageLiteral(resourceName: "firebase_logo")
		backView.addSubview(myImage)
		
		// надпись кнопки
		let label = UILabel(frame: CGRect(x: -1, y: 0, width: bttnSize.width, height: 22))
		label.text = "Delete"
		label.textAlignment = .center
		label.textColor = #colorLiteral(red: 1, green: 0.5137254902, blue: 0.007843137255, alpha: 1)
		label.font = UIFont.systemFont(ofSize: 13)
		backView.addSubview(label)
		
		// рендеринг кнопки
		let imgSize: CGSize = tableView.frame.size
		print("imgSize = \(imgSize)")
		UIGraphicsBeginImageContextWithOptions(imgSize, false, UIScreen.main.scale)
		let context = UIGraphicsGetCurrentContext()
		backView.layer.render(in: context!)
		
		// готовая картинка после рендеринга
		let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		
		let del = UITableViewRowAction(style: .default, title: "         ") {
			(action, indexPath) in
			let task = self.tasks[indexPath.row]
			task.ref?.removeValue()
		}
		
		del.backgroundColor = UIColor(patternImage: newImage)
		
		//************************************
		
		return [del]
	}
	
	
	// разрешение удаления ячеек
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	
	//**********************
	//   Настройки футера  *
	//**********************
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		
		let wid = UIScreen.main.bounds.width
		
		let backView = UIView(frame: CGRect(x: 0, y: 0, width: wid, height: 45))
		backView.backgroundColor = #colorLiteral(red: 0.8607864299, green: 0.8073794393, blue: 0.9686274529, alpha: 1)
		
		let tf = UITextField(frame: CGRect(x: 20, y: 0, width: wid - 20, height: 45))
		tf.text = ""
		tf.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControlEvents.editingDidEnd)
		backView.addSubview(tf)
		
		return backView
	}

	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 45
	}


	// разрешение на перетаскивание строк таблицы (изменение порядка строк)
	func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	// при изменение порядка строк
	func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		
		var movedRow = tasks[sourceIndexPath.row]
		movedRow.order = sourceIndexPath.row

		tasks.remove(at: sourceIndexPath.row)
		tasks.insert(movedRow, at: destinationIndexPath.row)
		
		packToJSON()
		
//		headerRef.setValue(tasks)
	}
	
	
	
	private func packToJSON(){
		
		var newArr:[String:Int] = [:]
		
		for (index, value) in tasks.enumerated() {
			var cel = converter(cel: value)

		}
	}
	
	
	
	
	private func converter(cel:Task) -> Any{
		return [
			"title"		: cel.title,
			"userID"	: cel.userID,
			"completed"	: cel.completed,
			"order"		: cel.order
		]
	}
	
	
	
	// при окончании ввода в последнюю ячейку (футер)
	@objc func textFieldDidChange(_ textField: UITextField) {

		guard textField.text != "" else { return }
		
		let str:String = textField.text!
		
		// создаем адрес задачи
		let task = Task(title: str, userID: user.uid, order: tasks.count)
		
		// создаем саму задачу
		let taskRef = ref.child(task.title.lowercased()) // продолжение углубления в структуру данных БД (см. строку 29)
		
		// записываем задачу в БД по адресу
		taskRef.setValue(task.convertToDict())
		
		textField.text = ""
	}
	
	
	private func toggleComplete(_ cell:UITableViewCell, isCompleted:Bool){
		cell.accessoryType = isCompleted ? .checkmark : .none
	}
	
	


	
	
	
	
}



















