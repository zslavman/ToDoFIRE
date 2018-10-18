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
	
	
	

	

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 5
	}
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "my_cell", for: indexPath)
		
		cell.backgroundColor = .clear
		cell.textLabel?.text = "This is cell No \(indexPath.row)"
		cell.textLabel?.textColor = .white
		
		return cell
	}
    

	@IBAction func onPlusClick(_ sender: UIBarButtonItem) {
		
		let alertController = UIAlertController(title: "New Task", message: "Add new task", preferredStyle: .alert)
		alertController.addTextField()
		
		let save = UIAlertAction(title: "Save", style: .default) {
			[weak self] _ in
			guard let tf = alertController.textFields?.first, tf.text != "" else { return }
			
			// создаем адрес задачи
			let task = Task(title: tf.text!, userID: (self?.user.uid)!, email: (self?.user.email)!)
			
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
	
	
	
	
	
	
	
}



















