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
	private var dbEventListener:Bool = true // флаг разрешающий отображать приходящие обновления
	private var bigEndian:Int = 0 			// старший индекс ячейки
	
	

	
	
	
	
	
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
			
			// не выполняем обновление если выключен флаг
			if !(self?.dbEventListener)! {
				return
			}
			
			var tempTasks:[Task] = []
			
			for item in snapshot.children{
				let task = Task(snapshot: item as! DataSnapshot)
				tempTasks.append(task)
			}
			
			self?.tasks = tempTasks.sorted{$0.order < $1.order}
			if !(self?.tasks.isEmpty)!{
				self?.bigEndian = (self?.tasks.last?.order)! + 1
			}
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
	}
	
	
	
	
	
	
	@objc private func keyboardWillShow(notification:Notification){
		// получаем инфу о размере клавиатуры
		if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
			tableView_user.contentInset = UIEdgeInsets(top: getUpperBarsHeight(), left: 0, bottom: keyboardSize.height, right: 0)
		}
		mode = .editing
		plusBttn.title = "Done"
		tableView_user.setEditing(false, animated: true)
	}

	
	@objc private func keyboardWillHide(notification:Notification){
		if ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
			if #available(iOS 11.0, *) {
				tableView_user.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
			}
			else{
				tableView_user.contentInset = UIEdgeInsets(top: getUpperBarsHeight(), left: 0, bottom: 0, right: 0)
			}
		}
	}
	
	

	/// конвертируем массив элементов в словарь и отправляем в БД
	private func packAndSend(){
		
		var dict:[String:Any] = [:]
		
		for (index, var value) in tasks.enumerated() {
			value.order = index
			dict[value.title] = converter(cel: value)
		}
		
		bigEndian = dict.count
		
		// отключаем слушатель изменения БД на время отправки
		dbEventListener = false
		
		ref.setValue(dict) {
			[weak self] (error, dbRef) in
			
			if error != nil {
				print("error = \(error!.localizedDescription)")
			}
			self?.dbEventListener = true
			
		}
	}
	
	
	
	/// конвертация в ячейку словаря
	private func converter(cel:Task) -> Any {
		return [
			"title"		: cel.title,
			"userID"	: cel.userID,
			"completed"	: cel.completed,
			"order"		: cel.order
		]
	}
	
	
	
	/// при окончании ввода в последнюю ячейку (футер)
	@objc func textFieldDidChange(_ textField: UITextField) {
		
		guard textField.text != "" else { return }
		
		var str:String = textField.text!
		
		
		// запись в БД не должна содержать след. символы:    '.' '#' '$' '[' ']'     RegEx =    /\.|\[|\]|\#|\$/g
		let forbiden = [".", "[", "]", "#", "$"]
		for value in forbiden {
			str = str.replacingOccurrences(of: value, with: "!")
		}
		
		// неработающая регулярка
//		let regex = try! NSRegularExpression(pattern: "//.|//[|//]|//#|//$", options: [])
//		let output = regex.stringByReplacingMatches(in: str, options: [], range: NSRange(location: 0, length: str.count), withTemplate: "!")
//		print("output = \(output)")
		
		
		// создаем адрес задачи
		let task = Task(title: str, userID: user.uid, order: bigEndian)
		bigEndian += 1
		
		// создаем саму задачу
		let taskRef = ref.child(task.title.lowercased()) // продолжение углубления в структуру данных БД (см. строку 29)
		
		// записываем задачу в БД по адресу
		taskRef.setValue(converter(cel: task))
		
		textField.text = ""
	}
	
	
	/// установка/убирание галочки
	private func toggleComplete(_ cell:UITableViewCell, isCompleted:Bool){
		cell.accessoryType = isCompleted ? .checkmark : .none
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
		// print("imgSize = \(imgSize)")
		UIGraphicsBeginImageContextWithOptions(imgSize, false, UIScreen.main.scale)
		let context = UIGraphicsGetCurrentContext()
		backView.layer.render(in: context!)
		
		// готовая картинка после рендеринга
		let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		
		let del = UITableViewRowAction(style: .default, title: "         ") {
			(action, indexPath) in
			
			// удаляем ячейку из таблицы
			// нужно удалять с анимацией, а значит, сначала удаляем с данных таблицы и самой таблицы, а в комплишинБлоке уже и из БД
			self.savedTaskToDelete = self.tasks[indexPath.row]

			CATransaction.begin()
			tableView.beginUpdates()

			self.tasks.remove(at: indexPath.row)
			tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.top)
			CATransaction.setCompletionBlock {
				self.dbEventListener = false
				self.savedTaskToDelete.ref?.removeValue(completionBlock: {
					[weak self] (error, dbRef) in
					if error != nil {
						print("error = \(error!.localizedDescription)")
					}
					self?.dbEventListener = true
				})
			}

			tableView.endUpdates()
			CATransaction.commit()
			
			
			// удаляем в БД, а в самой таблице удалит слушатель БД
			//  let task = self.tasks[indexPath.row]
			//  task.ref?.removeValue()
		}
		
		del.backgroundColor = UIColor(patternImage: newImage)
		//************************************
		
		return [del]
	}
	
	
	
	private var savedTaskToDelete:Task!
	
	
	
	
	// разрешение удаления/перемещения ячеек
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
		
		packAndSend()
	}
	

	
	// устраняет верхний отступ таблицы, появившийся после установки стиля таблицы на group
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return CGFloat.leastNormalMagnitude
	}
	
	


	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	/// [NOT USED] вычисляем суммарную высоту верхних баров (навбар + статусбар)
	private func getUpperBarsHeight() -> CGFloat {
		// вычисляем высоту навбара + статусбара, чтоб оставить этот паддинг сверху иначе таблица будет под этими барами
		var upperPadding:CGFloat = UIApplication.shared.statusBarFrame.height
		if let nc = navigationController {
			upperPadding += nc.navigationBar.frame.size.height
		}
		// print("upperPadding = \(upperPadding)")
		return upperPadding
	}
	
	
}

















