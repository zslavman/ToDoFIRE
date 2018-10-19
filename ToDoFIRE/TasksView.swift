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
	
	

	

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tasks.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "my_cell", for: indexPath)
		
		cell.backgroundColor = .clear
		cell.textLabel?.text = tasks[indexPath.row].title
		cell.textLabel?.textColor = #colorLiteral(red: 0.2, green: 0.5607843137, blue: 0.9882352941, alpha: 1)
		
		toggleComplete(cell, isCompleted: tasks[indexPath.row].completed)
		
		return cell
	}
    

	
	// редактирование (удаление ячейки таблицы)
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			let task = tasks[indexPath.row]
			task.ref?.removeValue()
		}
	}
	
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// получаем ячейку по которой кликнули
		guard let cell = tableView_user.cellForRow(at: indexPath) else { return }
		let task = tasks[indexPath.row]
		let isCompleted = !task.completed
		
		// рисуем галочку
		toggleComplete(cell, isCompleted: isCompleted)
		// передаем изменения в БД Firebase
		task.ref?.updateChildValues(["completed": isCompleted])
	}
	
	
	
	private func toggleComplete(_ cell:UITableViewCell, isCompleted:Bool){
		cell.accessoryType = isCompleted ? .checkmark : .none
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
	
	
	
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		ref.removeAllObservers()
	}
	
	
	
	
	
}



















