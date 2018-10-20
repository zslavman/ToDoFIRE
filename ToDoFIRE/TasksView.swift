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
	private var user:UserCustom!
	private var ref:DatabaseReference!
	private var tasks:[Task] = []
	
	
    override func viewDidLoad() {
        super.viewDidLoad()

		// проверка на всяк случай что мы залогинены
		guard let currentUser = Auth.auth().currentUser else { return }
		
		// инициализируем юзера, передав в него его личные данные (разложив которые внутри, получим его email и id)
		user = UserCustom(user: currentUser)
		
		// создаем структуру ссылки, куда будем сохранять данные
		ref = Database.database().reference(withPath: "users") 	// добрались до юзеров в БД
		ref = ref.child(String(user.uid)) 						// добрались до конкретного(текущего) юзера
		ref = ref.child("tasks") 								// добрались до таска
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
			
			self?.tasks = tempTasks
			self?.tableView_user.reloadData()
		}
	}
	
	
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		ref.removeAllObservers()
	}
	
	
	
	
	
	
	@IBAction func onPlusClick(_ sender: UIBarButtonItem) {
		let alertController = UIAlertController(title: "New Task", message: "Add new task", preferredStyle: .alert)
		alertController.addTextField()
		
		let save = UIAlertAction(title: "Save", style: .default) {
			[weak self] _ in
			guard let tf = alertController.textFields?.first, tf.text != "" else { return }
			
			// создаем адрес задачи
			let task = Task(title: tf.text!, userID: (self?.user.uid)!)
			
			// создаем саму задачу
			let taskRef = self?.ref.child(task.title.lowercased()) // продолжение углубления в структуру данных БД (см. строку 29)
			// записываем задачу в БД по адресу
			taskRef?.setValue(task.convertToDict())
		}
		
		let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
		
		alertController.addAction(save)
		alertController.addAction(cancel)
		
		present(alertController, animated: true, completion: nil)
	}
	
	
	
	
	
	@IBAction func onLogoutClick(_ sender: UIBarButtonItem) {
		do {
			try Auth.auth().signOut()
		}
		catch {
			print(error.localizedDescription)
		}
		dismiss(animated: true, completion: nil)
	}
	
	
	
	
	
	
	
	
	
	
	
	
	

	
	/* ===================================================*/
	/* ============= ДЕЙСТВИЯ С ТАБЛИЦЕЙ =================*/
	/* ===================================================*/
	
	// кол-во рядков
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (tasks.count == 0) ? 0 : tasks.count + 1
	}
	
	// создание таблицы
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "my_cell", for: indexPath)
		
		cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
		cell.textLabel?.textColor = #colorLiteral(red: 0.2, green: 0.5607843137, blue: 0.9882352941, alpha: 1)
		
		if indexPath.row < tasks.count{
			cell.textLabel?.text = tasks[indexPath.row].title
			toggleComplete(cell, isCompleted: tasks[indexPath.row].completed)
		}
		else{
			cell.textLabel?.text = "[BUTTON]"
			cell.textLabel?.textColor = #colorLiteral(red: 1, green: 0.5137254902, blue: 0.007843137255, alpha: 1)
		}
		
		// избавляемся от пустых строк
		tableView.tableFooterView = UIView(frame: CGRect.zero)
		tableView.separatorColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
		
		return cell
	}
    
	
	
	// клик по ячейке
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// получаем ячейку по которой кликнули
		guard let cell = tableView_user.cellForRow(at: indexPath), indexPath.row < tasks.count else {
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
		
		if indexPath.row >= tasks.count { return nil }
		
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
		if indexPath.row < tasks.count {
			return true
		}
		return false
	}
	
	
	func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		if indexPath.row < tasks.count {
			return true
		}
		return false
	}
	
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let footer = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 10))
		footer.backgroundColor = #colorLiteral(red: 1, green: 0.5137254902, blue: 0.007843137255, alpha: 1)
		return footer
	}
	
	
	private func toggleComplete(_ cell:UITableViewCell, isCompleted:Bool){
		cell.accessoryType = isCompleted ? .checkmark : .none
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
}



















